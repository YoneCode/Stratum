// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Test} from "forge-std/Test.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {IAgenticCommerce} from "../src/interfaces/IAgenticCommerce.sol";
import {StratumJobFactory} from "../src/StratumJobFactory.sol";
import {MockAgenticCommerce} from "./mocks/MockAgenticCommerce.sol";

/// @notice Comprehensive test suite for StratumJobFactory.
/// @dev    Test groups follow source order: constructor → registerJob →
///         updateJobMetadata → setRequiredHook → views, then fuzz and invariants.
///         Within each group: revert cases (access control, then input validation)
///         before happy path, per `test-foundry` skill.
contract StratumJobFactoryTest is Test {
    StratumJobFactory internal factory;
    MockAgenticCommerce internal acp;

    address internal owner = makeAddr("owner");
    address internal client = makeAddr("client");
    address internal stranger = makeAddr("stranger");
    address internal provider = makeAddr("provider");
    address internal evaluator = makeAddr("evaluator");
    address internal hookA = makeAddr("hookA");
    address internal hookB = makeAddr("hookB");

    uint256 internal constant JOB_ID = 1;
    bytes32 internal constant CATEGORY = keccak256("legal-research");
    string internal constant DESC_URI = "ipfs://bafkreidescription";
    string internal constant CARD_URI = "ipfs://bafkreiagentcard";

    bytes32[] internal tags;

    // ───── Setup ─────────────────────────────────────────────────────────────

    function setUp() public {
        acp = new MockAgenticCommerce();
        factory = new StratumJobFactory(address(acp), owner);
        tags.push(keccak256("law"));
        tags.push(keccak256("eu"));

        // Seed a default open job for tests that need one.
        _seedOpenJob(JOB_ID, client, provider, evaluator, address(0));
    }

    // ───── Helpers ───────────────────────────────────────────────────────────

    function _seedOpenJob(
        uint256 jobId,
        address client_,
        address provider_,
        address evaluator_,
        address hook_
    ) internal {
        acp.setJob(
            jobId,
            IAgenticCommerce.Job({
                id: jobId,
                client: client_,
                provider: provider_,
                evaluator: evaluator_,
                description: "test job",
                budget: 0,
                expiredAt: block.timestamp + 7 days,
                status: IAgenticCommerce.JobStatus.Open,
                hook: hook_
            })
        );
    }

    function _emptyTags() internal pure returns (bytes32[] memory) {
        return new bytes32[](0);
    }

    // ───── Constructor ───────────────────────────────────────────────────────

    function test_Constructor_RevertsWhenAcpZero() public {
        vm.expectRevert(StratumJobFactory.ZeroAddress.selector);
        new StratumJobFactory(address(0), owner);
    }

    function test_Constructor_RevertsWhenOwnerZero() public {
        // OZ Ownable v5 enforces non-zero initial owner with its own custom error.
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableInvalidOwner.selector, address(0)));
        new StratumJobFactory(address(acp), address(0));
    }

    function test_Constructor_SetsAcp() public view {
        assertEq(address(factory.acp()), address(acp));
    }

    function test_Constructor_SetsOwner() public view {
        assertEq(factory.owner(), owner);
    }

    function test_Constructor_RequiredHookDefaultsToZero() public view {
        assertEq(factory.requiredHook(), address(0));
    }

    // ───── registerJob — reverts ─────────────────────────────────────────────

    function test_RegisterJob_RevertsOnAlreadyRegistered() public {
        vm.startPrank(client);
        factory.registerJob(JOB_ID, CATEGORY, tags, DESC_URI, CARD_URI);
        vm.expectRevert(StratumJobFactory.AlreadyRegistered.selector);
        factory.registerJob(JOB_ID, CATEGORY, tags, DESC_URI, CARD_URI);
        vm.stopPrank();
    }

    function test_RegisterJob_RevertsOnEmptyCategory() public {
        vm.prank(client);
        vm.expectRevert(StratumJobFactory.EmptyCategory.selector);
        factory.registerJob(JOB_ID, bytes32(0), tags, DESC_URI, CARD_URI);
    }

    function test_RegisterJob_RevertsOnTooManyTags() public {
        bytes32[] memory many = new bytes32[](factory.MAX_TAGS() + 1);
        vm.prank(client);
        vm.expectRevert(StratumJobFactory.TooManyTags.selector);
        factory.registerJob(JOB_ID, CATEGORY, many, DESC_URI, CARD_URI);
    }

    function test_RegisterJob_RevertsOnLongDescriptionURI() public {
        string memory tooLong = _makeString(factory.MAX_URI_LEN() + 1);
        vm.prank(client);
        vm.expectRevert(StratumJobFactory.UriTooLong.selector);
        factory.registerJob(JOB_ID, CATEGORY, tags, tooLong, CARD_URI);
    }

    function test_RegisterJob_RevertsOnLongAgentCardURI() public {
        string memory tooLong = _makeString(factory.MAX_URI_LEN() + 1);
        vm.prank(client);
        vm.expectRevert(StratumJobFactory.UriTooLong.selector);
        factory.registerJob(JOB_ID, CATEGORY, tags, DESC_URI, tooLong);
    }

    function test_RegisterJob_RevertsWhenJobNotFound() public {
        vm.prank(client);
        vm.expectRevert(StratumJobFactory.JobNotFound.selector);
        factory.registerJob(999, CATEGORY, tags, DESC_URI, CARD_URI);
    }

    function test_RegisterJob_RevertsWhenCallerNotClient() public {
        vm.prank(stranger);
        vm.expectRevert(StratumJobFactory.NotJobClient.selector);
        factory.registerJob(JOB_ID, CATEGORY, tags, DESC_URI, CARD_URI);
    }

    function test_RegisterJob_RevertsOnWrongHookWhenRequired() public {
        // owner pins a required hook
        vm.prank(owner);
        factory.setRequiredHook(hookA);

        // existing job has hook = address(0), not hookA
        vm.prank(client);
        vm.expectRevert(StratumJobFactory.WrongHook.selector);
        factory.registerJob(JOB_ID, CATEGORY, tags, DESC_URI, CARD_URI);
    }

    // ───── registerJob — happy ───────────────────────────────────────────────

    function test_RegisterJob_StoresMetadata() public {
        vm.prank(client);
        factory.registerJob(JOB_ID, CATEGORY, tags, DESC_URI, CARD_URI);

        assertTrue(factory.registered(JOB_ID));
        StratumJobFactory.StratumJobMeta memory m = factory.getJobMeta(JOB_ID);
        assertEq(m.creator, client);
        assertEq(m.category, CATEGORY);
        assertEq(m.descriptionURI, DESC_URI);
        assertEq(m.agentCardURI, CARD_URI);
        assertEq(m.tags.length, tags.length);
        assertEq(m.tags[0], tags[0]);
        assertEq(m.tags[1], tags[1]);
        assertEq(uint256(m.createdAt), block.timestamp);
        assertEq(uint256(m.updatedAt), block.timestamp);
    }

    function test_RegisterJob_EmitsJobRegistered() public {
        vm.expectEmit(true, true, true, true);
        emit StratumJobFactory.JobRegistered(JOB_ID, client, CATEGORY, DESC_URI, CARD_URI);
        vm.prank(client);
        factory.registerJob(JOB_ID, CATEGORY, tags, DESC_URI, CARD_URI);
    }

    function test_RegisterJob_AcceptsEmptyTagsAndURIs() public {
        vm.prank(client);
        factory.registerJob(JOB_ID, CATEGORY, _emptyTags(), "", "");
        StratumJobFactory.StratumJobMeta memory m = factory.getJobMeta(JOB_ID);
        assertEq(m.tags.length, 0);
        assertEq(bytes(m.descriptionURI).length, 0);
    }

    function test_RegisterJob_PassesWhenHookMatchesRequired() public {
        vm.prank(owner);
        factory.setRequiredHook(hookA);
        _seedOpenJob(2, client, provider, evaluator, hookA);

        vm.prank(client);
        factory.registerJob(2, CATEGORY, tags, DESC_URI, CARD_URI);
        assertTrue(factory.registered(2));
    }

    // ───── updateJobMetadata — reverts ───────────────────────────────────────

    function test_UpdateJobMetadata_RevertsOnNotRegistered() public {
        vm.prank(client);
        vm.expectRevert(StratumJobFactory.NotRegistered.selector);
        factory.updateJobMetadata(JOB_ID, CATEGORY, tags, DESC_URI, CARD_URI);
    }

    function test_UpdateJobMetadata_RevertsOnEmptyCategory() public {
        _registerDefault();
        vm.prank(client);
        vm.expectRevert(StratumJobFactory.EmptyCategory.selector);
        factory.updateJobMetadata(JOB_ID, bytes32(0), tags, DESC_URI, CARD_URI);
    }

    function test_UpdateJobMetadata_RevertsOnTooManyTags() public {
        _registerDefault();
        bytes32[] memory many = new bytes32[](factory.MAX_TAGS() + 1);
        vm.prank(client);
        vm.expectRevert(StratumJobFactory.TooManyTags.selector);
        factory.updateJobMetadata(JOB_ID, CATEGORY, many, DESC_URI, CARD_URI);
    }

    function test_UpdateJobMetadata_RevertsWhenCallerNotClient() public {
        _registerDefault();
        vm.prank(stranger);
        vm.expectRevert(StratumJobFactory.NotJobClient.selector);
        factory.updateJobMetadata(JOB_ID, CATEGORY, tags, "ipfs://new", "ipfs://newcard");
    }

    // ───── updateJobMetadata — happy ─────────────────────────────────────────

    function test_UpdateJobMetadata_OverwritesAndBumpsTimestamp() public {
        _registerDefault();
        bytes32 newCategory = keccak256("new-category");
        bytes32[] memory newTags = new bytes32[](1);
        newTags[0] = keccak256("updated");

        skip(1 days);
        vm.expectEmit(true, true, true, true);
        emit StratumJobFactory.JobMetadataUpdated(JOB_ID, newCategory, "ipfs://new", "ipfs://newcard");

        vm.prank(client);
        factory.updateJobMetadata(JOB_ID, newCategory, newTags, "ipfs://new", "ipfs://newcard");

        StratumJobFactory.StratumJobMeta memory m = factory.getJobMeta(JOB_ID);
        assertEq(m.category, newCategory);
        assertEq(m.descriptionURI, "ipfs://new");
        assertEq(m.agentCardURI, "ipfs://newcard");
        assertEq(m.tags.length, 1);
        assertEq(m.tags[0], newTags[0]);
        assertGt(uint256(m.updatedAt), uint256(m.createdAt));
    }

    // ───── setRequiredHook ───────────────────────────────────────────────────

    function test_SetRequiredHook_RevertsForNonOwner() public {
        vm.prank(stranger);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, stranger));
        factory.setRequiredHook(hookA);
    }

    function test_SetRequiredHook_UpdatesAndEmits() public {
        vm.expectEmit(true, true, true, true);
        emit StratumJobFactory.RequiredHookUpdated(hookA);
        vm.prank(owner);
        factory.setRequiredHook(hookA);
        assertEq(factory.requiredHook(), hookA);
    }

    function test_SetRequiredHook_CanBeUnset() public {
        vm.prank(owner);
        factory.setRequiredHook(hookA);
        vm.prank(owner);
        factory.setRequiredHook(address(0));
        assertEq(factory.requiredHook(), address(0));
    }

    // ───── getJobMeta ────────────────────────────────────────────────────────

    function test_GetJobMeta_RevertsOnNotRegistered() public {
        vm.expectRevert(StratumJobFactory.NotRegistered.selector);
        factory.getJobMeta(JOB_ID);
    }

    // ───── Fuzz ──────────────────────────────────────────────────────────────

    function testFuzz_RegisterJob_RandomTagCount(uint8 tagCount) public {
        tagCount = uint8(bound(uint256(tagCount), 0, factory.MAX_TAGS()));
        bytes32[] memory many = new bytes32[](tagCount);
        for (uint256 i; i < tagCount; ++i) {
            many[i] = keccak256(abi.encode("tag", i));
        }
        vm.prank(client);
        factory.registerJob(JOB_ID, CATEGORY, many, DESC_URI, CARD_URI);
        StratumJobFactory.StratumJobMeta memory m = factory.getJobMeta(JOB_ID);
        assertEq(m.tags.length, tagCount);
    }

    function testFuzz_RegisterJob_RejectsNonClient(address caller) public {
        vm.assume(caller != client);
        vm.prank(caller);
        vm.expectRevert(StratumJobFactory.NotJobClient.selector);
        factory.registerJob(JOB_ID, CATEGORY, tags, DESC_URI, CARD_URI);
    }

    // ───── Internal test helpers ─────────────────────────────────────────────

    function _registerDefault() internal {
        vm.prank(client);
        factory.registerJob(JOB_ID, CATEGORY, tags, DESC_URI, CARD_URI);
    }

    /// @dev Build a string of `len` ASCII 'a' bytes.
    function _makeString(uint256 len) internal pure returns (string memory) {
        bytes memory b = new bytes(len);
        for (uint256 i; i < len; ++i) {
            b[i] = 0x61; // ASCII 'a'
        }
        return string(b);
    }
}
