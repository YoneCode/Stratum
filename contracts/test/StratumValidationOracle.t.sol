// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Test} from "forge-std/Test.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {StratumValidationOracle} from "../src/StratumValidationOracle.sol";
import {MockValidationRegistry} from "./mocks/MockValidationRegistry.sol";

contract StratumValidationOracleTest is Test {
    StratumValidationOracle internal oracleContract;
    MockValidationRegistry internal registry;

    address internal owner = makeAddr("owner");
    address internal oracleEOA = makeAddr("oracle");
    address internal stranger = makeAddr("stranger");

    bytes32 internal constant REQ_HASH = keccak256("test-request");

    function setUp() public {
        registry = new MockValidationRegistry();
        oracleContract = new StratumValidationOracle(address(registry), oracleEOA, owner);
    }

    // ───── Constructor ───────────────────────────────────────────────────────

    function test_Constructor_RevertsOnZeroRegistry() public {
        vm.expectRevert(StratumValidationOracle.ZeroAddress.selector);
        new StratumValidationOracle(address(0), oracleEOA, owner);
    }

    function test_Constructor_RevertsOnZeroOracle() public {
        vm.expectRevert(StratumValidationOracle.ZeroAddress.selector);
        new StratumValidationOracle(address(registry), address(0), owner);
    }

    function test_Constructor_SetsState() public view {
        assertEq(address(oracleContract.validationRegistry()), address(registry));
        assertEq(oracleContract.oracle(), oracleEOA);
        assertEq(oracleContract.owner(), owner);
    }

    // ───── setOracle ─────────────────────────────────────────────────────────

    function test_SetOracle_RevertsForNonOwner() public {
        vm.prank(stranger);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, stranger));
        oracleContract.setOracle(stranger);
    }

    function test_SetOracle_RevertsOnZero() public {
        vm.prank(owner);
        vm.expectRevert(StratumValidationOracle.ZeroAddress.selector);
        oracleContract.setOracle(address(0));
    }

    function test_SetOracle_UpdatesAndEmits() public {
        address newOracle = makeAddr("newOracle");
        vm.expectEmit(true, true, true, true);
        emit StratumValidationOracle.OracleUpdated(oracleEOA, newOracle);
        vm.prank(owner);
        oracleContract.setOracle(newOracle);
        assertEq(oracleContract.oracle(), newOracle);
    }

    // ───── submitValidation — reverts ────────────────────────────────────────

    function test_SubmitValidation_RevertsForNonOracle() public {
        vm.prank(stranger);
        vm.expectRevert(StratumValidationOracle.NotOracle.selector);
        oracleContract.submitValidation(REQ_HASH, 100, "", bytes32(0), "");
    }

    // ───── submitValidation — happy ──────────────────────────────────────────

    function test_SubmitValidation_ForwardsToRegistry() public {
        vm.prank(oracleEOA);
        oracleContract.submitValidation(REQ_HASH, 95, "ipfs://evidence", keccak256("ev"), "tee-nitro");

        MockValidationRegistry.ResponseCall memory c = registry.lastCall();
        assertEq(c.requestHash, REQ_HASH);
        assertEq(c.response, 95);
        assertEq(c.responseURI, "ipfs://evidence");
        assertEq(c.responseHash, keccak256("ev"));
        assertEq(c.tag, "tee-nitro");
    }

    function test_SubmitValidation_EmitsEvent() public {
        vm.expectEmit(true, true, true, true);
        emit StratumValidationOracle.ValidationSubmitted(REQ_HASH, 100);
        vm.prank(oracleEOA);
        oracleContract.submitValidation(REQ_HASH, 100, "", bytes32(0), "");
    }

    // ───── Fuzz ──────────────────────────────────────────────────────────────

    function testFuzz_SubmitValidation_AnyResponse(uint8 response) public {
        vm.prank(oracleEOA);
        oracleContract.submitValidation(REQ_HASH, response, "", bytes32(0), "stub");
        assertEq(registry.lastCall().response, response);
    }

    function testFuzz_SubmitValidation_RejectsNonOracle(address caller) public {
        vm.assume(caller != oracleEOA);
        vm.prank(caller);
        vm.expectRevert(StratumValidationOracle.NotOracle.selector);
        oracleContract.submitValidation(REQ_HASH, 50, "", bytes32(0), "");
    }
}
