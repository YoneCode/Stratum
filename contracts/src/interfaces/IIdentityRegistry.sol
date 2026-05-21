// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Metadata} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";

/// @title IIdentityRegistry
/// @notice ERC-8004 §Identity Registry — agent identity as ERC-721 with URIStorage extension.
/// @dev    Deployed at 0x8004A818BFB912233c491871b3d84c89A494BD9e on Arc Testnet (chainId 5042002).
///         Source: https://eips.ethereum.org/EIPS/eip-8004
///
///         Each agent is globally identified by a colon-separated triple
///         `{namespace}:{chainId}:{identityRegistry}` (e.g. `eip155:5042002:0x8004A818...`)
///         plus the ERC-721 `tokenId` (referred to as `agentId`).
///
///         The reserved metadata key `agentWallet` controls the address that receives
///         payments on behalf of the agent. It cannot be set via `setMetadata` or the
///         metadata-array `register` overload — use `setAgentWallet` (with EIP-712 / ERC-1271
///         signature proving control of the new wallet). Transfers automatically clear it.
interface IIdentityRegistry is IERC721, IERC721Metadata {
    // ─────────────────────── Types ────────────────────────────────────────────

    struct MetadataEntry {
        string metadataKey;
        bytes metadataValue;
    }

    // ─────────────────────── Events ───────────────────────────────────────────

    event Registered(uint256 indexed agentId, string agentURI, address indexed owner);
    event URIUpdated(uint256 indexed agentId, string newURI, address indexed updatedBy);
    event MetadataSet(
        uint256 indexed agentId,
        string indexed indexedMetadataKey,
        string metadataKey,
        bytes metadataValue
    );

    // ─────────────────────── Registration ─────────────────────────────────────

    /// @notice Register a new agent with no agentURI (set later via setAgentURI).
    function register() external returns (uint256 agentId);

    /// @notice Register a new agent and set its agentURI atomically.
    function register(string calldata agentURI) external returns (uint256 agentId);

    /// @notice Register a new agent with agentURI plus extra on-chain metadata entries.
    /// @dev    The reserved key `agentWallet` is rejected here — use setAgentWallet().
    function register(string calldata agentURI, MetadataEntry[] calldata metadata)
        external
        returns (uint256 agentId);

    /// @notice Update the agentURI for an existing agent. Emits URIUpdated.
    function setAgentURI(uint256 agentId, string calldata newURI) external;

    // ─────────────────────── Metadata ─────────────────────────────────────────

    function getMetadata(uint256 agentId, string calldata metadataKey)
        external
        view
        returns (bytes memory);

    function setMetadata(uint256 agentId, string calldata metadataKey, bytes calldata metadataValue)
        external;

    // ─────────────────────── Agent wallet ─────────────────────────────────────

    function getAgentWallet(uint256 agentId) external view returns (address);

    /// @notice Set the agent's payment wallet. Requires EIP-712 (EOA) or ERC-1271
    ///         (smart contract wallet) signature from `newWallet` proving control.
    function setAgentWallet(
        uint256 agentId,
        address newWallet,
        uint256 deadline,
        bytes calldata signature
    ) external;

    function unsetAgentWallet(uint256 agentId) external;
}
