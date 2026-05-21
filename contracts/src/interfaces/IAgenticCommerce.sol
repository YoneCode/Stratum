// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/// @title IAgenticCommerce
/// @notice ERC-8183 — job escrow with evaluator attestation.
/// @dev    Mirrors the deployed reference implementation at
///         0x0747EEf0706327138c69792bF28Cd525089e4583 on Arc Testnet (chainId 5042002).
///         Source: https://eips.ethereum.org/EIPS/eip-8183 (Reference Implementation §AgenticCommerce.sol)
///
///         State machine: Open → Funded → Submitted → Terminal{Completed | Rejected | Expired}.
///
///         IMPORTANT — three signature reconciliations vs arc-dapp.md §2.4:
///           1. `fund` is `fund(uint256,bytes)` (no `expectedBudget`); matches the
///              reference impl, not the EIP spec text.
///           2. `setProvider` is `setProvider(uint256,address)` (no `optParams`);
///              matches the reference impl.
///           3. `setBudget` MUST be called by the *provider* in the reference impl
///              (the EIP spec text allows client-or-provider). The deployed contract
///              enforces provider-only.
interface IAgenticCommerce {
    // ─────────────────────── Types ────────────────────────────────────────────

    enum JobStatus {
        Open,
        Funded,
        Submitted,
        Completed,
        Rejected,
        Expired
    }

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

    // ─────────────────────── Events ───────────────────────────────────────────

    event JobCreated(
        uint256 indexed jobId,
        address indexed client,
        address indexed provider,
        address evaluator,
        uint256 expiredAt,
        address hook
    );
    event ProviderSet(uint256 indexed jobId, address indexed provider);
    event BudgetSet(uint256 indexed jobId, uint256 amount);
    event JobFunded(uint256 indexed jobId, address indexed client, uint256 amount);
    event JobSubmitted(uint256 indexed jobId, address indexed provider, bytes32 deliverable);
    event JobCompleted(uint256 indexed jobId, address indexed evaluator, bytes32 reason);
    event JobRejected(uint256 indexed jobId, address indexed rejector, bytes32 reason);
    event JobExpired(uint256 indexed jobId);
    event PaymentReleased(uint256 indexed jobId, address indexed provider, uint256 amount);
    event EvaluatorFeePaid(uint256 indexed jobId, address indexed evaluator, uint256 amount);
    event Refunded(uint256 indexed jobId, address indexed client, uint256 amount);
    event HookWhitelistUpdated(address indexed hook, bool status);

    // ─────────────────────── Lifecycle ────────────────────────────────────────

    function createJob(
        address provider,
        address evaluator,
        uint256 expiredAt,
        string calldata description,
        address hook
    ) external returns (uint256 jobId);

    function setProvider(uint256 jobId, address provider) external;

    function setBudget(uint256 jobId, uint256 amount, bytes calldata optParams) external;

    function fund(uint256 jobId, bytes calldata optParams) external;

    function submit(uint256 jobId, bytes32 deliverable, bytes calldata optParams) external;

    function complete(uint256 jobId, bytes32 reason, bytes calldata optParams) external;

    function reject(uint256 jobId, bytes32 reason, bytes calldata optParams) external;

    function claimRefund(uint256 jobId) external;

    // ─────────────────────── Views ────────────────────────────────────────────

    function getJob(uint256 jobId) external view returns (Job memory);
    function paymentToken() external view returns (address);
    function platformFeeBP() external view returns (uint256);
    function evaluatorFeeBP() external view returns (uint256);
    function platformTreasury() external view returns (address);
    function jobCounter() external view returns (uint256);
    function whitelistedHooks(address hook) external view returns (bool);
    function jobHasBudget(uint256 jobId) external view returns (bool);
}
