// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// Minimal Stratum-owned AgenticCommerce.
// Stripped from EIP-8183 reference impl — only the lifecycle + hook whitelist + fees.
// NOT upgradeable (no proxy needed for testnet). Simplifies deployment.

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {ERC165Checker} from "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import {IACPHook} from "../interfaces/IACPHook.sol";

contract AgenticCommerce is ReentrancyGuard {
    using SafeERC20 for IERC20;

    enum JobStatus { Open, Funded, Submitted, Completed, Rejected, Expired }

    struct Job {
        uint256 id;
        address client;
        address provider;
        address evaluator;
        string description;
        uint256 budget;
        uint256 expiredAt;
        JobStatus status;
        address hook;
    }

    IERC20 public immutable paymentToken;
    address public admin;
    uint256 public platformFeeBP;
    address public platformTreasury;
    uint256 public evaluatorFeeBP;

    mapping(uint256 => Job) public jobs;
    uint256 public jobCounter;
    mapping(address => bool) public whitelistedHooks;

    event JobCreated(uint256 indexed jobId, address indexed client, address indexed provider, address evaluator, uint256 expiredAt, address hook);
    event BudgetSet(uint256 indexed jobId, uint256 amount);
    event JobFunded(uint256 indexed jobId, address indexed client, uint256 amount);
    event JobSubmitted(uint256 indexed jobId, address indexed provider, bytes32 deliverable);
    event JobCompleted(uint256 indexed jobId, address indexed evaluator, bytes32 reason);
    event JobRejected(uint256 indexed jobId, address indexed rejector, bytes32 reason);
    event JobExpired(uint256 indexed jobId);
    event PaymentReleased(uint256 indexed jobId, address indexed provider, uint256 amount);
    event Refunded(uint256 indexed jobId, address indexed client, uint256 amount);

    error InvalidJob();
    error WrongStatus();
    error Unauthorized();
    error ZeroAddress();
    error ExpiryTooShort();
    error ProviderNotSet();
    error HookNotWhitelisted();

    modifier onlyAdmin() { if (msg.sender != admin) revert Unauthorized(); _; }

    constructor(address paymentToken_, address treasury_) {
        if (paymentToken_ == address(0) || treasury_ == address(0)) revert ZeroAddress();
        paymentToken = IERC20(paymentToken_);
        platformTreasury = treasury_;
        admin = msg.sender;
        whitelistedHooks[address(0)] = true;
    }

    function setHookWhitelist(address hook, bool status) external onlyAdmin {
        whitelistedHooks[hook] = status;
    }

    function setPlatformFee(uint256 bp, address treasury_) external onlyAdmin {
        platformFeeBP = bp;
        platformTreasury = treasury_;
    }

    function createJob(address provider, address evaluator, uint256 expiredAt, string calldata description, address hook) external nonReentrant returns (uint256) {
        if (evaluator == address(0)) revert ZeroAddress();
        if (expiredAt <= block.timestamp + 5 minutes) revert ExpiryTooShort();
        if (!whitelistedHooks[hook]) revert HookNotWhitelisted();
        if (hook != address(0) && !ERC165Checker.supportsInterface(hook, type(IACPHook).interfaceId)) revert InvalidJob();

        uint256 jobId = ++jobCounter;
        jobs[jobId] = Job(jobId, msg.sender, provider, evaluator, description, 0, expiredAt, JobStatus.Open, hook);
        emit JobCreated(jobId, msg.sender, provider, evaluator, expiredAt, hook);
        return jobId;
    }

    function setBudget(uint256 jobId, uint256 amount, bytes calldata optParams) external nonReentrant {
        Job storage job = jobs[jobId];
        if (job.id == 0) revert InvalidJob();
        if (job.status != JobStatus.Open) revert WrongStatus();
        if (msg.sender != job.provider) revert Unauthorized();
        _beforeHook(job.hook, jobId, msg.sig, abi.encode(msg.sender, amount, optParams));
        job.budget = amount;
        emit BudgetSet(jobId, amount);
        _afterHook(job.hook, jobId, msg.sig, abi.encode(msg.sender, amount, optParams));
    }

    function fund(uint256 jobId, bytes calldata optParams) external nonReentrant {
        Job storage job = jobs[jobId];
        if (job.id == 0) revert InvalidJob();
        if (job.status != JobStatus.Open) revert WrongStatus();
        if (msg.sender != job.client) revert Unauthorized();
        if (job.provider == address(0)) revert ProviderNotSet();
        _beforeHook(job.hook, jobId, msg.sig, abi.encode(msg.sender, optParams));
        job.status = JobStatus.Funded;
        if (job.budget > 0) paymentToken.safeTransferFrom(job.client, address(this), job.budget);
        emit JobFunded(jobId, job.client, job.budget);
        _afterHook(job.hook, jobId, msg.sig, abi.encode(msg.sender, optParams));
    }

    function submit(uint256 jobId, bytes32 deliverable, bytes calldata optParams) external nonReentrant {
        Job storage job = jobs[jobId];
        if (job.id == 0) revert InvalidJob();
        if (job.status != JobStatus.Funded) revert WrongStatus();
        if (msg.sender != job.provider) revert Unauthorized();
        _beforeHook(job.hook, jobId, msg.sig, abi.encode(msg.sender, deliverable, optParams));
        job.status = JobStatus.Submitted;
        emit JobSubmitted(jobId, job.provider, deliverable);
        _afterHook(job.hook, jobId, msg.sig, abi.encode(msg.sender, deliverable, optParams));
    }

    function complete(uint256 jobId, bytes32 reason, bytes calldata optParams) external nonReentrant {
        Job storage job = jobs[jobId];
        if (job.id == 0) revert InvalidJob();
        if (job.status != JobStatus.Submitted) revert WrongStatus();
        if (msg.sender != job.evaluator) revert Unauthorized();
        _beforeHook(job.hook, jobId, msg.sig, abi.encode(msg.sender, reason, optParams));
        job.status = JobStatus.Completed;
        uint256 fee = (job.budget * platformFeeBP) / 10000;
        uint256 net = job.budget - fee;
        if (fee > 0) paymentToken.safeTransfer(platformTreasury, fee);
        if (net > 0) paymentToken.safeTransfer(job.provider, net);
        emit JobCompleted(jobId, job.evaluator, reason);
        emit PaymentReleased(jobId, job.provider, net);
        _afterHook(job.hook, jobId, msg.sig, abi.encode(msg.sender, reason, optParams));
    }

    function reject(uint256 jobId, bytes32 reason, bytes calldata optParams) external nonReentrant {
        Job storage job = jobs[jobId];
        if (job.id == 0) revert InvalidJob();
        if (job.status == JobStatus.Open) { if (msg.sender != job.client) revert Unauthorized(); }
        else if (job.status == JobStatus.Funded || job.status == JobStatus.Submitted) { if (msg.sender != job.evaluator) revert Unauthorized(); }
        else revert WrongStatus();
        _beforeHook(job.hook, jobId, msg.sig, abi.encode(msg.sender, reason, optParams));
        JobStatus prev = job.status;
        job.status = JobStatus.Rejected;
        if ((prev == JobStatus.Funded || prev == JobStatus.Submitted) && job.budget > 0) {
            paymentToken.safeTransfer(job.client, job.budget);
            emit Refunded(jobId, job.client, job.budget);
        }
        emit JobRejected(jobId, msg.sender, reason);
        _afterHook(job.hook, jobId, msg.sig, abi.encode(msg.sender, reason, optParams));
    }

    function claimRefund(uint256 jobId) external nonReentrant {
        Job storage job = jobs[jobId];
        if (job.id == 0) revert InvalidJob();
        if (job.status != JobStatus.Funded && job.status != JobStatus.Submitted) revert WrongStatus();
        if (block.timestamp < job.expiredAt) revert WrongStatus();
        job.status = JobStatus.Expired;
        if (job.budget > 0) { paymentToken.safeTransfer(job.client, job.budget); emit Refunded(jobId, job.client, job.budget); }
        emit JobExpired(jobId);
    }

    function getJob(uint256 jobId) external view returns (Job memory) { return jobs[jobId]; }

    function _beforeHook(address hook, uint256 jobId, bytes4 sel, bytes memory data) internal {
        if (hook != address(0)) IACPHook(hook).beforeAction(jobId, sel, data);
    }
    function _afterHook(address hook, uint256 jobId, bytes4 sel, bytes memory data) internal {
        if (hook != address(0)) IACPHook(hook).afterAction(jobId, sel, data);
    }
}
