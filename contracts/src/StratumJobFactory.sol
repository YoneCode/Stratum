// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

import {IAgenticCommerce} from "./interfaces/IAgenticCommerce.sol";

/// @title  StratumJobFactory
/// @notice Stratum-flavoured metadata sidecar for jobs created in the ERC-8183
///         Agentic Commerce reference contract. Adds `category`, `tags`, and
///         IPFS pointers (`descriptionURI`, `agentCardURI`) so the Stratum UI and
///         indexer can browse / filter / curate jobs without changing the
///         underlying ACP escrow primitive.
/// @dev    DESIGN — sidecar, not proxy.
///
///         The ERC-8183 reference impl gates every lifecycle action on `msg.sender`:
///         `setBudget` provider-only, `fund` client-only, `submit` provider-only,
///         `complete` / `reject` evaluator-only. If this factory called `createJob`,
///         it would become the immutable `client` and the real user could never
///         fund from their balance. So Stratum cannot wrap the lifecycle — only
///         the metadata around it.
///
///         User flow:
///           1. User calls `IAgenticCommerce(0x0747EEf0…).createJob(...)` directly,
///              receives `jobId`.
///           2. User calls `StratumJobFactory.registerJob(jobId, category, tags,
///              descriptionURI, agentCardURI)` to bind Stratum metadata.
///           3. Lifecycle (`setBudget`, `fund`, `submit`, `complete`) continues
///              against the ACP contract.
///
///         The optional `requiredHook` lets the owner force every Stratum-registered
///         job to have a specific hook attached at creation (set in Week 2 to the
///         deployed `StratumReputationHook` so completion always writes feedback to
///         ERC-8004). Defaults to `address(0)` (no enforcement).
///
///         This contract is intentionally read-mostly: it never custodies funds
///         and never makes external calls beyond a single view (`acp.getJob`).
contract StratumJobFactory is Ownable2Step {
    // ─────────────────────── Constants ────────────────────────────────────────

    uint256 public constant MAX_TAGS = 16;
    uint256 public constant MAX_URI_LEN = 256;

    // ─────────────────────── Types ────────────────────────────────────────────

    struct StratumJobMeta {
        // slot 0: 20 + 4 + 4 = 28 bytes (4 bytes padding)
        address creator;
        uint32 createdAt;
        uint32 updatedAt;
        // slot 1
        bytes32 category;
        // dynamic
        string descriptionURI;
        string agentCardURI;
        bytes32[] tags;
    }

    // ─────────────────────── Immutables ───────────────────────────────────────

    IAgenticCommerce public immutable acp;

    // ─────────────────────── State ────────────────────────────────────────────

    mapping(uint256 jobId => StratumJobMeta) private _meta;
    mapping(uint256 jobId => bool) public registered;
    address public requiredHook;

    // ─────────────────────── Events ───────────────────────────────────────────

    event JobRegistered(
        uint256 indexed jobId,
        address indexed creator,
        bytes32 indexed category,
        string descriptionURI,
        string agentCardURI
    );

    event JobMetadataUpdated(
        uint256 indexed jobId,
        bytes32 indexed category,
        string descriptionURI,
        string agentCardURI
    );

    event RequiredHookUpdated(address indexed hook);

    // ─────────────────────── Errors ───────────────────────────────────────────

    error AlreadyRegistered();
    error EmptyCategory();
    error JobNotFound();
    error NotJobClient();
    error NotRegistered();
    error TooManyTags();
    error UriTooLong();
    error WrongHook();
    error ZeroAddress();

    // ─────────────────────── Constructor ──────────────────────────────────────

    constructor(address acp_, address initialOwner) Ownable(initialOwner) {
        if (acp_ == address(0)) revert ZeroAddress();
        acp = IAgenticCommerce(acp_);
    }

    // ─────────────────────── Admin ────────────────────────────────────────────

    /// @notice Pin (or clear) the hook every Stratum-registered job MUST have at
    ///         the ACP layer. `address(0)` disables enforcement.
    /// @dev    Can be set to a future `StratumReputationHook` once it is deployed
    ///         and whitelisted on the ACP contract by the ACP admin.
    function setRequiredHook(address hook) external onlyOwner {
        requiredHook = hook;
        emit RequiredHookUpdated(hook);
    }

    // ─────────────────────── Registration ─────────────────────────────────────

    /// @notice Bind Stratum metadata to an existing ERC-8183 job.
    /// @dev    Caller MUST be `job.client`. If `requiredHook` is non-zero, the
    ///         job MUST have been created with `hook == requiredHook`.
    function registerJob(
        uint256 jobId,
        bytes32 category,
        bytes32[] calldata tags,
        string calldata descriptionURI,
        string calldata agentCardURI
    ) external {
        // — Checks —
        if (registered[jobId]) revert AlreadyRegistered();
        _validateInputs(category, tags, descriptionURI, agentCardURI);

        IAgenticCommerce.Job memory job = acp.getJob(jobId);
        if (job.id == 0) revert JobNotFound();
        if (job.client != msg.sender) revert NotJobClient();

        address rh = requiredHook;
        if (rh != address(0) && job.hook != rh) revert WrongHook();

        // — Effects —
        registered[jobId] = true;
        StratumJobMeta storage m = _meta[jobId];
        m.creator = msg.sender;
        m.createdAt = uint32(block.timestamp);
        m.updatedAt = uint32(block.timestamp);
        m.category = category;
        m.descriptionURI = descriptionURI;
        m.agentCardURI = agentCardURI;
        // copy calldata array into storage element-by-element
        bytes32[] storage stored = m.tags;
        uint256 len = tags.length;
        for (uint256 i; i < len; ++i) {
            stored.push(tags[i]);
        }

        emit JobRegistered(jobId, msg.sender, category, descriptionURI, agentCardURI);
    }

    /// @notice Replace the Stratum metadata bound to an already-registered job.
    /// @dev    Caller MUST be `job.client` (re-checked against ACP, in case the
    ///         underlying job's client somehow changed — defensive read).
    function updateJobMetadata(
        uint256 jobId,
        bytes32 category,
        bytes32[] calldata tags,
        string calldata descriptionURI,
        string calldata agentCardURI
    ) external {
        // — Checks —
        if (!registered[jobId]) revert NotRegistered();
        _validateInputs(category, tags, descriptionURI, agentCardURI);

        IAgenticCommerce.Job memory job = acp.getJob(jobId);
        if (job.client != msg.sender) revert NotJobClient();

        // — Effects —
        StratumJobMeta storage m = _meta[jobId];
        m.category = category;
        m.descriptionURI = descriptionURI;
        m.agentCardURI = agentCardURI;
        m.updatedAt = uint32(block.timestamp);

        // overwrite tags: clear then push
        delete m.tags;
        bytes32[] storage stored = m.tags;
        uint256 len = tags.length;
        for (uint256 i; i < len; ++i) {
            stored.push(tags[i]);
        }

        emit JobMetadataUpdated(jobId, category, descriptionURI, agentCardURI);
    }

    // ─────────────────────── Views ────────────────────────────────────────────

    function getJobMeta(uint256 jobId) external view returns (StratumJobMeta memory) {
        if (!registered[jobId]) revert NotRegistered();
        return _meta[jobId];
    }

    // ─────────────────────── Internal ─────────────────────────────────────────

    function _validateInputs(
        bytes32 category,
        bytes32[] calldata tags,
        string calldata descriptionURI,
        string calldata agentCardURI
    ) private pure {
        if (category == bytes32(0)) revert EmptyCategory();
        if (tags.length > MAX_TAGS) revert TooManyTags();
        if (
            bytes(descriptionURI).length > MAX_URI_LEN
                || bytes(agentCardURI).length > MAX_URI_LEN
        ) revert UriTooLong();
    }
}
