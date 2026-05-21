// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

import {IACPHook} from "./interfaces/IACPHook.sol";
import {IAgenticCommerce} from "./interfaces/IAgenticCommerce.sol";
import {IIdentityRegistry} from "./interfaces/IIdentityRegistry.sol";
import {IReputationRegistry} from "./interfaces/IReputationRegistry.sol";

/// @title  StratumReputationHook
/// @notice ERC-8183 IACPHook that writes a positive reputation signal to the
///         ERC-8004 Reputation Registry every time a job completes.
/// @dev    Attached as the `hook` on an ERC-8183 job at creation time.
///         On `afterAction` with selector == `complete(uint256,bytes32,bytes)`,
///         calls `IReputationRegistry.giveFeedback(agentId, 100, 0, "job_completed", …)`.
///
///         Agent ID resolution: ERC-8004 has no reverse mapping (address → agentId).
///         Providers register their agentId on this hook via `registerProvider`.
///         The hook verifies ownership via `IIdentityRegistry.ownerOf`.
///
///         Security (per EIP-8183 §Hook Security):
///         - `onlyACP` modifier ensures hook functions cannot be called by external actors.
///         - Only reacts to `complete` selector in `afterAction`; all other selectors are no-ops.
///         - `beforeAction` is a no-op (does not block any action).
contract StratumReputationHook is IACPHook {
    // ─────────────────────── Constants ────────────────────────────────────────

    /// @dev Selector for `complete(uint256,bytes32,bytes)`.
    bytes4 private constant COMPLETE_SELECTOR = 0xd75bbdf3;

    int128 private constant POSITIVE_SCORE = 100;
    uint8 private constant SCORE_DECIMALS = 0;
    string private constant TAG1 = "job_completed";

    // ─────────────────────── Immutables ───────────────────────────────────────

    IAgenticCommerce public immutable acp;
    IReputationRegistry public immutable reputation;
    IIdentityRegistry public immutable identity;

    // ─────────────────────── State ────────────────────────────────────────────

    /// @notice provider address → ERC-8004 agentId. Must be set before the hook
    ///         can write feedback for that provider.
    mapping(address => uint256) public providerAgentId;

    // ─────────────────────── Events ───────────────────────────────────────────

    event ProviderRegistered(address indexed provider, uint256 indexed agentId);
    event FeedbackWritten(uint256 indexed jobId, uint256 indexed agentId, address indexed client);

    // ─────────────────────── Errors ───────────────────────────────────────────

    error NotACP();
    error NotAgentOwner();
    error ZeroAddress();
    error ZeroAgentId();

    // ─────────────────────── Constructor ──────────────────────────────────────

    constructor(address acp_, address reputation_, address identity_) {
        if (acp_ == address(0) || reputation_ == address(0) || identity_ == address(0)) {
            revert ZeroAddress();
        }
        acp = IAgenticCommerce(acp_);
        reputation = IReputationRegistry(reputation_);
        identity = IIdentityRegistry(identity_);
    }

    // ─────────────────────── Modifiers ────────────────────────────────────────

    modifier onlyACP() {
        if (msg.sender != address(acp)) revert NotACP();
        _;
    }

    // ─────────────────────── Provider registration ────────────────────────────

    /// @notice Link a provider address to their ERC-8004 agentId. Anyone can call
    ///         but the call only succeeds if `IIdentityRegistry.ownerOf(agentId)`
    ///         returns `provider`.
    function registerProvider(address provider, uint256 agentId) external {
        if (provider == address(0)) revert ZeroAddress();
        if (agentId == 0) revert ZeroAgentId();
        // ownerOf reverts if agentId doesn't exist (ERC721NonexistentToken)
        address owner = identity.ownerOf(agentId);
        if (owner != provider) revert NotAgentOwner();

        providerAgentId[provider] = agentId;
        emit ProviderRegistered(provider, agentId);
    }

    // ─────────────────────── IACPHook ─────────────────────────────────────────

    /// @notice No-op. This hook does not gate any actions.
    function beforeAction(uint256, bytes4, bytes calldata) external view onlyACP {}

    /// @notice On `complete`: write positive feedback to ERC-8004 Reputation Registry.
    ///         Silently skips if provider has no registered agentId (non-blocking).
    function afterAction(uint256 jobId, bytes4 selector, bytes calldata) external onlyACP {
        if (selector != COMPLETE_SELECTOR) return;

        IAgenticCommerce.Job memory job = acp.getJob(jobId);
        uint256 agentId = providerAgentId[job.provider];
        if (agentId == 0) return; // provider not registered — skip silently

        reputation.giveFeedback(
            agentId,
            POSITIVE_SCORE,
            SCORE_DECIMALS,
            TAG1,
            "", // tag2
            "", // endpoint
            "", // feedbackURI
            bytes32(0) // feedbackHash
        );

        emit FeedbackWritten(jobId, agentId, job.client);
    }

    // ─────────────────────── ERC-165 ──────────────────────────────────────────

    function supportsInterface(bytes4 interfaceId) external pure override returns (bool) {
        return interfaceId == type(IACPHook).interfaceId || interfaceId == type(IERC165).interfaceId;
    }
}
