// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/// @title IValidationRegistry
/// @notice ERC-8004 §Validation Registry — agents request validation, validator contracts respond.
/// @dev    Deployed at 0x8004Cb1BF31DAf7788923b405b754f57acEB4272 on Arc Testnet (chainId 5042002).
///         Source: https://eips.ethereum.org/EIPS/eip-8004
///
///         Use cases for validators: stake-secured re-execution, zkML verifiers, TEE oracles
///         (e.g. AWS Nitro Enclaves, Phala). Incentives and slashing are out of scope here —
///         they live in the validator-specific protocol. This registry only records requests
///         and responses for on-chain composability.
///
///         `response` is a uint8 (0..100). Use binary encoding (0/100) for pass/fail, or
///         intermediate values for spectrum outcomes (e.g. soft/hard finality via `tag`).
///         `validationResponse` MAY be called multiple times for the same `requestHash`
///         to support progressive validation states.
interface IValidationRegistry {
    // ─────────────────────── Events ───────────────────────────────────────────

    event ValidationRequest(
        address indexed validatorAddress,
        uint256 indexed agentId,
        string requestURI,
        bytes32 indexed requestHash
    );

    event ValidationResponse(
        address indexed validatorAddress,
        uint256 indexed agentId,
        bytes32 indexed requestHash,
        uint8 response,
        string responseURI,
        bytes32 responseHash,
        string tag
    );

    // ─────────────────────── View ─────────────────────────────────────────────

    function getIdentityRegistry() external view returns (address);

    // ─────────────────────── Write ────────────────────────────────────────────

    /// @notice Request validation. MUST be called by the agent owner or operator of `agentId`.
    function validationRequest(
        address validatorAddress,
        uint256 agentId,
        string calldata requestURI,
        bytes32 requestHash
    ) external;

    /// @notice Submit a validation response. MUST be called by the `validatorAddress`
    ///         specified in the original request.
    function validationResponse(
        bytes32 requestHash,
        uint8 response,
        string calldata responseURI,
        bytes32 responseHash,
        string calldata tag
    ) external;

    // ─────────────────────── Read ─────────────────────────────────────────────

    function getValidationStatus(bytes32 requestHash)
        external
        view
        returns (
            address validatorAddress,
            uint256 agentId,
            uint8 response,
            bytes32 responseHash,
            string memory tag,
            uint256 lastUpdate
        );

    function getSummary(
        uint256 agentId,
        address[] calldata validatorAddresses,
        string calldata tag
    ) external view returns (uint64 count, uint8 averageResponse);

    function getAgentValidations(uint256 agentId)
        external
        view
        returns (bytes32[] memory requestHashes);

    function getValidatorRequests(address validatorAddress)
        external
        view
        returns (bytes32[] memory requestHashes);
}
