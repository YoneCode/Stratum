// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/// @title IACPHook
/// @notice ERC-8183 §Hooks — optional hook contract attached to a Job to extend the
///         Agentic Commerce Protocol without modifying the core escrow contract.
/// @dev    Verbatim transcription from EIP-8183 (Reference Implementation).
///         Source: https://eips.ethereum.org/EIPS/eip-8183
///
///         The `selector` argument identifies which core ACP function fired the hook
///         (e.g. `bytes4(keccak256("fund(uint256,bytes)"))` for `fund`). The `data`
///         argument is the function-specific payload, abi-encoded per the EIP table:
///
///           setProvider : abi.encode(address provider, bytes optParams)
///           setBudget   : abi.encode(uint256 amount, bytes optParams)
///           fund        : optParams (raw bytes)
///           submit      : abi.encode(bytes32 deliverable, bytes optParams)
///           complete    : abi.encode(bytes32 reason, bytes optParams)
///           reject      : abi.encode(bytes32 reason, bytes optParams)
///
///         Note that the deployed reference implementation at
///         0x0747EEf0706327138c69792bF28Cd525089e4583 prefixes each hook-payload with
///         `msg.sender`; consult `AgenticCommerce.sol` in the EIP if exact alignment
///         with the reference impl encoding is required for a specific hook.
///
///         `claimRefund` is intentionally NOT hookable — it is the guaranteed recovery
///         path after `expiredAt` and SHALL NOT be blockable by a malicious hook.
interface IACPHook is IERC165 {
    function beforeAction(uint256 jobId, bytes4 selector, bytes calldata data) external;
    function afterAction(uint256 jobId, bytes4 selector, bytes calldata data) external;
}
