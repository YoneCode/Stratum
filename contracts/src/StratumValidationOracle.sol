// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IValidationRegistry} from "./interfaces/IValidationRegistry.sol";

/// @title  StratumValidationOracle (stub)
/// @notice Accepts TEE attestation results from a trusted oracle EOA and forwards
///         them to the ERC-8004 Validation Registry. The oracle is expected to be
///         an AWS Nitro Enclave or Phala Cloud worker that verifies agent outputs
///         off-chain and signs the result.
/// @dev    V0.1 stub: single trusted oracle, no stake, no slashing.
///         V0.2 will add real TEE attestation parsing + multi-validator committee.
contract StratumValidationOracle is Ownable {
    // ─────────────────────── Immutables ───────────────────────────────────────

    IValidationRegistry public immutable validationRegistry;

    // ─────────────────────── State ────────────────────────────────────────────

    address public oracle;

    // ─────────────────────── Events ───────────────────────────────────────────

    event OracleUpdated(address indexed oldOracle, address indexed newOracle);
    event ValidationSubmitted(bytes32 indexed requestHash, uint8 response);

    // ─────────────────────── Errors ───────────────────────────────────────────

    error NotOracle();
    error ZeroAddress();

    // ─────────────────────── Constructor ──────────────────────────────────────

    constructor(address validationRegistry_, address oracle_, address owner_) Ownable(owner_) {
        if (validationRegistry_ == address(0) || oracle_ == address(0)) revert ZeroAddress();
        validationRegistry = IValidationRegistry(validationRegistry_);
        oracle = oracle_;
    }

    // ─────────────────────── Admin ────────────────────────────────────────────

    function setOracle(address newOracle) external onlyOwner {
        if (newOracle == address(0)) revert ZeroAddress();
        emit OracleUpdated(oracle, newOracle);
        oracle = newOracle;
    }

    // ─────────────────────── Oracle actions ───────────────────────────────────

    /// @notice Submit a validation response to ERC-8004. Only callable by the oracle.
    /// @param requestHash The hash identifying the original validation request.
    /// @param response 0-100 (0=fail, 100=pass).
    /// @param responseURI Optional URI pointing to off-chain evidence.
    /// @param responseHash Keccak256 of the responseURI content (or bytes32(0) for IPFS).
    /// @param tag Free-form label (e.g. "tee-nitro", "soft-finality").
    function submitValidation(
        bytes32 requestHash,
        uint8 response,
        string calldata responseURI,
        bytes32 responseHash,
        string calldata tag
    ) external {
        if (msg.sender != oracle) revert NotOracle();

        validationRegistry.validationResponse(requestHash, response, responseURI, responseHash, tag);
        emit ValidationSubmitted(requestHash, response);
    }
}
