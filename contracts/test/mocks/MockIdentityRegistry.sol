// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IERC721Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";

/// @notice Minimal mock of ERC-8004 Identity Registry exposing only the surface
///         that `StratumAgentCard` consumes (`ownerOf`, `tokenURI`).
/// @dev    Reverts with the canonical OZ 5.x `ERC721NonexistentToken` error for
///         unknown token IDs so tests can match the same revert that the live
///         ERC-8004 contract would produce.
contract MockIdentityRegistry {
    mapping(uint256 agentId => address) private _owners;
    mapping(uint256 agentId => string) private _uris;

    function setOwner(uint256 agentId, address owner) external {
        _owners[agentId] = owner;
    }

    function setTokenURI(uint256 agentId, string calldata uri) external {
        _uris[agentId] = uri;
    }

    function ownerOf(uint256 agentId) external view returns (address) {
        address o = _owners[agentId];
        if (o == address(0)) revert IERC721Errors.ERC721NonexistentToken(agentId);
        return o;
    }

    function tokenURI(uint256 agentId) external view returns (string memory) {
        if (_owners[agentId] == address(0)) revert IERC721Errors.ERC721NonexistentToken(agentId);
        return _uris[agentId];
    }
}
