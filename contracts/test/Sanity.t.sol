// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Test} from "forge-std/Test.sol";

/// @notice Smoke test that proves the toolchain (forge + OZ + remappings) is wired up.
/// @dev    Will be deleted once the first real Stratum contract test lands.
contract SanityTest is Test {
    function test_ToolchainAlive() public pure {
        assertEq(uint256(1) + uint256(1), 2);
    }
}
