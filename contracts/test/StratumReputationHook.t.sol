// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Test} from "forge-std/Test.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {IERC721Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";

import {IACPHook} from "../src/interfaces/IACPHook.sol";
import {IAgenticCommerce} from "../src/interfaces/IAgenticCommerce.sol";
import {StratumReputationHook} from "../src/StratumReputationHook.sol";
import {MockAgenticCommerce} from "./mocks/MockAgenticCommerce.sol";
import {MockIdentityRegistry} from "./mocks/MockIdentityRegistry.sol";
import {MockReputationRegistry} from "./mocks/MockReputationRegistry.sol";

contract StratumReputationHookTest is Test {
    StratumReputationHook internal hook;
    MockAgenticCommerce internal acp;
    MockIdentityRegistry internal identity;
    MockReputationRegistry internal reputation;

    address internal client = makeAddr("client");
    address internal provider = makeAddr("provider");
    address internal evaluator = makeAddr("evaluator");
    address internal stranger = makeAddr("stranger");

    uint256 internal constant AGENT_ID = 42;
    uint256 internal constant JOB_ID = 1;
    bytes4 internal constant COMPLETE_SEL = bytes4(keccak256("complete(uint256,bytes32,bytes)"));
    bytes4 internal constant FUND_SEL = bytes4(keccak256("fund(uint256,bytes)"));

    function setUp() public {
        acp = new MockAgenticCommerce();
        identity = new MockIdentityRegistry();
        reputation = new MockReputationRegistry();
        hook = new StratumReputationHook(address(acp), address(reputation), address(identity));

        // Set provider as owner of AGENT_ID
        identity.setOwner(AGENT_ID, provider);

        // Seed a completed job
        acp.setJob(JOB_ID, IAgenticCommerce.Job({
            id: JOB_ID,
            client: client,
            provider: provider,
            evaluator: evaluator,
            description: "test",
            budget: 1e6,
            expiredAt: block.timestamp + 7 days,
            status: IAgenticCommerce.JobStatus.Completed,
            hook: address(hook)
        }));
    }

    // ───── Constructor ───────────────────────────────────────────────────────

    function test_Constructor_RevertsOnZeroAcp() public {
        vm.expectRevert(StratumReputationHook.ZeroAddress.selector);
        new StratumReputationHook(address(0), address(reputation), address(identity));
    }

    function test_Constructor_RevertsOnZeroReputation() public {
        vm.expectRevert(StratumReputationHook.ZeroAddress.selector);
        new StratumReputationHook(address(acp), address(0), address(identity));
    }

    function test_Constructor_RevertsOnZeroIdentity() public {
        vm.expectRevert(StratumReputationHook.ZeroAddress.selector);
        new StratumReputationHook(address(acp), address(reputation), address(0));
    }

    function test_Constructor_SetsImmutables() public view {
        assertEq(address(hook.acp()), address(acp));
        assertEq(address(hook.reputation()), address(reputation));
        assertEq(address(hook.identity()), address(identity));
    }

    // ───── registerProvider — reverts ────────────────────────────────────────

    function test_RegisterProvider_RevertsOnZeroProvider() public {
        vm.expectRevert(StratumReputationHook.ZeroAddress.selector);
        hook.registerProvider(address(0), AGENT_ID);
    }

    function test_RegisterProvider_RevertsOnZeroAgentId() public {
        vm.expectRevert(StratumReputationHook.ZeroAgentId.selector);
        hook.registerProvider(provider, 0);
    }

    function test_RegisterProvider_RevertsIfNotOwner() public {
        vm.expectRevert(StratumReputationHook.NotAgentOwner.selector);
        hook.registerProvider(stranger, AGENT_ID); // stranger doesn't own AGENT_ID
    }

    function test_RegisterProvider_RevertsIfAgentDoesNotExist() public {
        vm.expectRevert(
            abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, uint256(999))
        );
        hook.registerProvider(provider, 999);
    }

    // ───── registerProvider — happy ──────────────────────────────────────────

    function test_RegisterProvider_StoresAndEmits() public {
        vm.expectEmit(true, true, true, true);
        emit StratumReputationHook.ProviderRegistered(provider, AGENT_ID);
        hook.registerProvider(provider, AGENT_ID);
        assertEq(hook.providerAgentId(provider), AGENT_ID);
    }

    function test_RegisterProvider_CanUpdate() public {
        identity.setOwner(99, provider);
        hook.registerProvider(provider, AGENT_ID);
        hook.registerProvider(provider, 99);
        assertEq(hook.providerAgentId(provider), 99);
    }

    // ───── beforeAction ──────────────────────────────────────────────────────

    function test_BeforeAction_RevertsIfNotAcp() public {
        vm.prank(stranger);
        vm.expectRevert(StratumReputationHook.NotACP.selector);
        hook.beforeAction(JOB_ID, COMPLETE_SEL, "");
    }

    function test_BeforeAction_NoOpFromAcp() public {
        vm.prank(address(acp));
        hook.beforeAction(JOB_ID, COMPLETE_SEL, ""); // should not revert
    }

    // ───── afterAction — reverts ─────────────────────────────────────────────

    function test_AfterAction_RevertsIfNotAcp() public {
        vm.prank(stranger);
        vm.expectRevert(StratumReputationHook.NotACP.selector);
        hook.afterAction(JOB_ID, COMPLETE_SEL, "");
    }

    // ───── afterAction — happy ───────────────────────────────────────────────

    function test_AfterAction_WriteFeedbackOnComplete() public {
        hook.registerProvider(provider, AGENT_ID);

        vm.prank(address(acp));
        hook.afterAction(JOB_ID, COMPLETE_SEL, "");

        assertEq(reputation.callCount(), 1);
        MockReputationRegistry.FeedbackCall memory fc = reputation.lastCall();
        assertEq(fc.agentId, AGENT_ID);
        assertEq(fc.value, int128(100));
        assertEq(fc.valueDecimals, 0);
        assertEq(fc.tag1, "job_completed");
    }

    function test_AfterAction_EmitsFeedbackWritten() public {
        hook.registerProvider(provider, AGENT_ID);

        vm.expectEmit(true, true, true, true);
        emit StratumReputationHook.FeedbackWritten(JOB_ID, AGENT_ID, client);

        vm.prank(address(acp));
        hook.afterAction(JOB_ID, COMPLETE_SEL, "");
    }

    function test_AfterAction_SkipsIfProviderNotRegistered() public {
        // provider not registered — should not revert, just skip
        vm.prank(address(acp));
        hook.afterAction(JOB_ID, COMPLETE_SEL, "");
        assertEq(reputation.callCount(), 0);
    }

    function test_AfterAction_SkipsNonCompleteSelector() public {
        hook.registerProvider(provider, AGENT_ID);

        vm.prank(address(acp));
        hook.afterAction(JOB_ID, FUND_SEL, "");
        assertEq(reputation.callCount(), 0);
    }

    // ───── supportsInterface ─────────────────────────────────────────────────

    function test_SupportsInterface_IACPHook() public view {
        assertTrue(hook.supportsInterface(type(IACPHook).interfaceId));
    }

    function test_SupportsInterface_IERC165() public view {
        assertTrue(hook.supportsInterface(type(IERC165).interfaceId));
    }

    function test_SupportsInterface_Random() public view {
        assertFalse(hook.supportsInterface(0xdeadbeef));
    }

    // ───── Fuzz ──────────────────────────────────────────────────────────────

    function testFuzz_AfterAction_OnlyCompleteTriggersFeedback(bytes4 sel) public {
        hook.registerProvider(provider, AGENT_ID);
        vm.prank(address(acp));
        hook.afterAction(JOB_ID, sel, "");

        if (sel == COMPLETE_SEL) {
            assertEq(reputation.callCount(), 1);
        } else {
            assertEq(reputation.callCount(), 0);
        }
    }

    function testFuzz_RegisterProvider_RejectsNonOwner(address caller) public {
        vm.assume(caller != provider && caller != address(0));
        vm.expectRevert(StratumReputationHook.NotAgentOwner.selector);
        hook.registerProvider(caller, AGENT_ID);
    }
}
