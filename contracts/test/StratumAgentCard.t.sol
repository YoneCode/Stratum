// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Test} from "forge-std/Test.sol";
import {IERC721Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";

import {StratumAgentCard} from "../src/StratumAgentCard.sol";
import {MockIdentityRegistry} from "./mocks/MockIdentityRegistry.sol";

/// @notice Tests for StratumAgentCard.
/// @dev    Source-ordered groups: constructor → linkAgent → updateAgentMetadata
///         → getAgentMeta → fuzz. Within each group: reverts (access then input)
///         before happy paths, per `test-foundry` skill.
contract StratumAgentCardTest is Test {
    StratumAgentCard internal card;
    MockIdentityRegistry internal identity;

    address internal alice = makeAddr("alice");
    address internal bob = makeAddr("bob");
    address internal stranger = makeAddr("stranger");

    uint256 internal constant AGENT_ID = 7;
    bytes32 internal constant CATEGORY = keccak256("trading");

    bytes32[] internal tags;

    // ───── Setup ─────────────────────────────────────────────────────────────

    function setUp() public {
        identity = new MockIdentityRegistry();
        card = new StratumAgentCard(address(identity));

        identity.setOwner(AGENT_ID, alice);
        identity.setTokenURI(AGENT_ID, "ipfs://bafkreiagentcard");

        tags.push(keccak256("arbitrage"));
        tags.push(keccak256("eu"));
    }

    function _emptyTags() internal pure returns (bytes32[] memory) {
        return new bytes32[](0);
    }

    function _linkDefault() internal {
        vm.prank(alice);
        card.linkAgent(AGENT_ID, CATEGORY, tags);
    }

    // ───── Constructor ───────────────────────────────────────────────────────

    function test_Constructor_RevertsWhenIdentityZero() public {
        vm.expectRevert(StratumAgentCard.ZeroAddress.selector);
        new StratumAgentCard(address(0));
    }

    function test_Constructor_SetsIdentity() public view {
        assertEq(address(card.identity()), address(identity));
    }

    // ───── linkAgent — reverts ───────────────────────────────────────────────

    function test_LinkAgent_RevertsOnAlreadyLinked() public {
        _linkDefault();
        vm.prank(alice);
        vm.expectRevert(StratumAgentCard.AlreadyLinked.selector);
        card.linkAgent(AGENT_ID, CATEGORY, tags);
    }

    function test_LinkAgent_RevertsOnEmptyCategory() public {
        vm.prank(alice);
        vm.expectRevert(StratumAgentCard.EmptyCategory.selector);
        card.linkAgent(AGENT_ID, bytes32(0), tags);
    }

    function test_LinkAgent_RevertsOnTooManyTags() public {
        bytes32[] memory many = new bytes32[](card.MAX_TAGS() + 1);
        vm.prank(alice);
        vm.expectRevert(StratumAgentCard.TooManyTags.selector);
        card.linkAgent(AGENT_ID, CATEGORY, many);
    }

    function test_LinkAgent_RevertsWhenAgentDoesNotExist() public {
        vm.prank(alice);
        vm.expectRevert(
            abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, uint256(99))
        );
        card.linkAgent(99, CATEGORY, tags);
    }

    function test_LinkAgent_RevertsWhenCallerNotOwner() public {
        vm.prank(stranger);
        vm.expectRevert(StratumAgentCard.NotAgentOwner.selector);
        card.linkAgent(AGENT_ID, CATEGORY, tags);
    }

    // ───── linkAgent — happy ─────────────────────────────────────────────────

    function test_LinkAgent_StoresMetadata() public {
        vm.prank(alice);
        card.linkAgent(AGENT_ID, CATEGORY, tags);

        assertTrue(card.linked(AGENT_ID));
        StratumAgentCard.StratumAgentMeta memory m = card.getAgentMeta(AGENT_ID);
        assertEq(m.linker, alice);
        assertEq(m.category, CATEGORY);
        assertEq(m.tags.length, tags.length);
        assertEq(m.tags[0], tags[0]);
        assertEq(m.tags[1], tags[1]);
        assertEq(uint256(m.linkedAt), block.timestamp);
        assertEq(uint256(m.updatedAt), block.timestamp);
    }

    function test_LinkAgent_EmitsAgentLinked() public {
        vm.expectEmit(true, true, true, true);
        emit StratumAgentCard.AgentLinked(AGENT_ID, alice, CATEGORY);
        vm.prank(alice);
        card.linkAgent(AGENT_ID, CATEGORY, tags);
    }

    function test_LinkAgent_AcceptsEmptyTags() public {
        vm.prank(alice);
        card.linkAgent(AGENT_ID, CATEGORY, _emptyTags());
        StratumAgentCard.StratumAgentMeta memory m = card.getAgentMeta(AGENT_ID);
        assertEq(m.tags.length, 0);
    }

    // ───── updateAgentMetadata — reverts ─────────────────────────────────────

    function test_UpdateAgentMetadata_RevertsOnNotLinked() public {
        vm.prank(alice);
        vm.expectRevert(StratumAgentCard.NotLinked.selector);
        card.updateAgentMetadata(AGENT_ID, CATEGORY, tags);
    }

    function test_UpdateAgentMetadata_RevertsOnEmptyCategory() public {
        _linkDefault();
        vm.prank(alice);
        vm.expectRevert(StratumAgentCard.EmptyCategory.selector);
        card.updateAgentMetadata(AGENT_ID, bytes32(0), tags);
    }

    function test_UpdateAgentMetadata_RevertsOnTooManyTags() public {
        _linkDefault();
        bytes32[] memory many = new bytes32[](card.MAX_TAGS() + 1);
        vm.prank(alice);
        vm.expectRevert(StratumAgentCard.TooManyTags.selector);
        card.updateAgentMetadata(AGENT_ID, CATEGORY, many);
    }

    function test_UpdateAgentMetadata_RevertsWhenCallerNotCurrentOwner() public {
        _linkDefault();
        // Bob is not the owner — should revert even though alice was the linker.
        vm.prank(bob);
        vm.expectRevert(StratumAgentCard.NotAgentOwner.selector);
        card.updateAgentMetadata(AGENT_ID, CATEGORY, tags);
    }

    // ───── updateAgentMetadata — happy ───────────────────────────────────────

    function test_UpdateAgentMetadata_OverwritesAndBumpsTimestamp() public {
        _linkDefault();
        skip(1 days);

        bytes32 newCategory = keccak256("legal");
        bytes32[] memory newTags = new bytes32[](1);
        newTags[0] = keccak256("review");

        vm.expectEmit(true, true, true, true);
        emit StratumAgentCard.AgentMetadataUpdated(AGENT_ID, newCategory);

        vm.prank(alice);
        card.updateAgentMetadata(AGENT_ID, newCategory, newTags);

        StratumAgentCard.StratumAgentMeta memory m = card.getAgentMeta(AGENT_ID);
        assertEq(m.category, newCategory);
        assertEq(m.tags.length, 1);
        assertEq(m.tags[0], newTags[0]);
        assertGt(uint256(m.updatedAt), uint256(m.linkedAt));
        // linker is preserved across updates
        assertEq(m.linker, alice);
    }

    function test_UpdateAgentMetadata_NewOwnerCanRewriteAfterTransfer() public {
        _linkDefault();
        // Simulate ERC-721 transfer: bob is now the agent's owner.
        identity.setOwner(AGENT_ID, bob);

        bytes32 newCategory = keccak256("research");
        vm.prank(bob);
        card.updateAgentMetadata(AGENT_ID, newCategory, _emptyTags());

        StratumAgentCard.StratumAgentMeta memory m = card.getAgentMeta(AGENT_ID);
        assertEq(m.category, newCategory);
        // The linker field intentionally still records alice — historical attribution.
        assertEq(m.linker, alice);
    }

    function test_UpdateAgentMetadata_OldOwnerLocksOutAfterTransfer() public {
        _linkDefault();
        // Simulate transfer: alice no longer owns.
        identity.setOwner(AGENT_ID, bob);

        vm.prank(alice);
        vm.expectRevert(StratumAgentCard.NotAgentOwner.selector);
        card.updateAgentMetadata(AGENT_ID, CATEGORY, tags);
    }

    // ───── getAgentMeta ──────────────────────────────────────────────────────

    function test_GetAgentMeta_RevertsOnNotLinked() public {
        vm.expectRevert(StratumAgentCard.NotLinked.selector);
        card.getAgentMeta(AGENT_ID);
    }

    // ───── Fuzz ──────────────────────────────────────────────────────────────

    function testFuzz_LinkAgent_RandomTagCount(uint8 tagCount) public {
        tagCount = uint8(bound(uint256(tagCount), 0, card.MAX_TAGS()));
        bytes32[] memory many = new bytes32[](tagCount);
        for (uint256 i; i < tagCount; ++i) {
            many[i] = keccak256(abi.encode("tag", i));
        }
        vm.prank(alice);
        card.linkAgent(AGENT_ID, CATEGORY, many);
        StratumAgentCard.StratumAgentMeta memory m = card.getAgentMeta(AGENT_ID);
        assertEq(m.tags.length, tagCount);
    }

    function testFuzz_LinkAgent_RejectsNonOwner(address caller) public {
        vm.assume(caller != alice);
        vm.prank(caller);
        vm.expectRevert(StratumAgentCard.NotAgentOwner.selector);
        card.linkAgent(AGENT_ID, CATEGORY, tags);
    }
}
