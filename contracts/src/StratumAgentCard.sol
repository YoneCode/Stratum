// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IIdentityRegistry} from "./interfaces/IIdentityRegistry.sol";

/// @title  StratumAgentCard
/// @notice Stratum-flavoured metadata sidecar for agents already registered in
///         the ERC-8004 Identity Registry. Stores `category` and `tags` so the
///         Stratum UI and indexer can browse / filter / curate agents without
///         modifying the upstream registry.
/// @dev    DESIGN — sidecar, not proxy.
///
///         The ERC-8004 Identity Registry is an ERC-721 with URIStorage extension.
///         A call to `IIdentityRegistry.register(string)` mints the agent NFT to
///         `msg.sender`. If this contract proxied `register`, the agent would be
///         owned by Stratum instead of the user. So users register their agent
///         directly with ERC-8004 (e.g. via Circle Developer-Controlled Wallets,
///         see arc-dapp.md §11.2), then call `linkAgent(agentId, category, tags)`
///         here to bind Stratum metadata.
///
///         "AgentCard JSON validation" (per `arc-dapp.md §7`) is intentionally
///         left off-chain. A contract cannot parse JSON. The `agentURI` itself is
///         already enforced by ERC-8004 (via `tokenURI`); Stratum's frontend and
///         indexer perform schema validation against the AgentCard JSON
///         (https://eips.ethereum.org/EIPS/eip-8004) before allowing the user to
///         call `linkAgent`. On-chain, we only enforce ownership: caller MUST be
///         the current owner of the ERC-721 agent token. Re-checked on every
///         update so an NFT transfer correctly re-gates write access.
///
///         No fund custody, no Ownable surface in this iteration. KYB tier and
///         verification badges are deferred to a v0.2 elevator (arc-dapp.md §4.9).
contract StratumAgentCard {
    // ─────────────────────── Constants ────────────────────────────────────────

    uint256 public constant MAX_TAGS = 16;

    // ─────────────────────── Types ────────────────────────────────────────────

    struct StratumAgentMeta {
        // slot 0: 20 + 4 + 4 = 28 bytes (4 padding)
        address linker;
        uint32 linkedAt;
        uint32 updatedAt;
        // slot 1
        bytes32 category;
        // dynamic
        bytes32[] tags;
    }

    // ─────────────────────── Immutables ───────────────────────────────────────

    IIdentityRegistry public immutable identity;

    // ─────────────────────── State ────────────────────────────────────────────

    mapping(uint256 agentId => StratumAgentMeta) private _meta;
    mapping(uint256 agentId => bool) public linked;

    // ─────────────────────── Events ───────────────────────────────────────────

    event AgentLinked(uint256 indexed agentId, address indexed linker, bytes32 indexed category);
    event AgentMetadataUpdated(uint256 indexed agentId, bytes32 indexed category);

    // ─────────────────────── Errors ───────────────────────────────────────────

    error AlreadyLinked();
    error EmptyCategory();
    error NotAgentOwner();
    error NotLinked();
    error TooManyTags();
    error ZeroAddress();

    // ─────────────────────── Constructor ──────────────────────────────────────

    constructor(address identity_) {
        if (identity_ == address(0)) revert ZeroAddress();
        identity = IIdentityRegistry(identity_);
    }

    // ─────────────────────── Linking ──────────────────────────────────────────

    /// @notice Bind Stratum metadata to an existing ERC-8004 agent.
    /// @dev    Caller MUST be `IIdentityRegistry.ownerOf(agentId)`.
    /// @param agentId  ERC-8004 agent NFT token id.
    /// @param category Non-zero classification key (e.g. `keccak256("trading")`).
    /// @param tags     Up to `MAX_TAGS` free-form labels for filtering.
    function linkAgent(uint256 agentId, bytes32 category, bytes32[] calldata tags) external {
        // — Checks —
        if (linked[agentId]) revert AlreadyLinked();
        _validateInputs(category, tags);

        // ownerOf reverts with ERC721NonexistentToken if the agent does not exist.
        address agentOwner = identity.ownerOf(agentId);
        if (agentOwner != msg.sender) revert NotAgentOwner();

        // — Effects —
        linked[agentId] = true;
        StratumAgentMeta storage m = _meta[agentId];
        m.linker = msg.sender;
        m.linkedAt = uint32(block.timestamp);
        m.updatedAt = uint32(block.timestamp);
        m.category = category;
        bytes32[] storage stored = m.tags;
        uint256 len = tags.length;
        for (uint256 i; i < len; ++i) {
            stored.push(tags[i]);
        }

        emit AgentLinked(agentId, msg.sender, category);
    }

    /// @notice Replace the Stratum metadata bound to a previously-linked agent.
    /// @dev    Caller MUST be the *current* `ownerOf(agentId)` — re-checked
    ///         every call so an NFT transfer re-gates write access. The original
    ///         `linker` field is preserved as historical attribution.
    function updateAgentMetadata(uint256 agentId, bytes32 category, bytes32[] calldata tags)
        external
    {
        // — Checks —
        if (!linked[agentId]) revert NotLinked();
        _validateInputs(category, tags);

        address agentOwner = identity.ownerOf(agentId);
        if (agentOwner != msg.sender) revert NotAgentOwner();

        // — Effects —
        StratumAgentMeta storage m = _meta[agentId];
        m.category = category;
        m.updatedAt = uint32(block.timestamp);
        delete m.tags;
        bytes32[] storage stored = m.tags;
        uint256 len = tags.length;
        for (uint256 i; i < len; ++i) {
            stored.push(tags[i]);
        }

        emit AgentMetadataUpdated(agentId, category);
    }

    // ─────────────────────── Views ────────────────────────────────────────────

    function getAgentMeta(uint256 agentId) external view returns (StratumAgentMeta memory) {
        if (!linked[agentId]) revert NotLinked();
        return _meta[agentId];
    }

    // ─────────────────────── Internal ─────────────────────────────────────────

    function _validateInputs(bytes32 category, bytes32[] calldata tags) private pure {
        if (category == bytes32(0)) revert EmptyCategory();
        if (tags.length > MAX_TAGS) revert TooManyTags();
    }
}
