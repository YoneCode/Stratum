// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Test} from "forge-std/Test.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {FXRouter} from "../src/FXRouter.sol";
import {MockERC20} from "./mocks/MockERC20.sol";

contract FXRouterTest is Test {
    FXRouter internal router;
    MockERC20 internal eurc;
    MockERC20 internal usdc;

    address internal owner = makeAddr("owner");
    address internal alice = makeAddr("alice");
    address internal stranger = makeAddr("stranger");

    function setUp() public {
        eurc = new MockERC20("EURC", "EURC", 6);
        usdc = new MockERC20("USDC", "USDC", 6);
        router = new FXRouter(address(eurc), address(usdc), owner);

        eurc.mint(alice, 1000e6);
        usdc.mint(address(router), 1000e6); // pre-fund for fulfillments
    }

    // ───── depositEurc ───────────────────────────────────────────────────────

    function test_DepositEurc_RevertsOnZero() public {
        vm.prank(alice);
        vm.expectRevert(FXRouter.ZeroAmount.selector);
        router.depositEurc(0);
    }

    function test_DepositEurc_TransfersAndEmits() public {
        vm.startPrank(alice);
        eurc.approve(address(router), 100e6);
        vm.expectEmit(true, true, true, true);
        emit FXRouter.SwapRequested(alice, 100e6);
        router.depositEurc(100e6);
        vm.stopPrank();

        assertEq(router.pendingEurc(alice), 100e6);
        assertEq(eurc.balanceOf(alice), 900e6);
    }

    // ───── fulfillSwap ───────────────────────────────────────────────────────

    function test_FulfillSwap_RevertsForNonOwner() public {
        vm.prank(stranger);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, stranger));
        router.fulfillSwap(alice, 100e6, 92e6);
    }

    function test_FulfillSwap_RevertsOnNoPending() public {
        vm.prank(owner);
        vm.expectRevert(FXRouter.NoPendingSwap.selector);
        router.fulfillSwap(alice, 100e6, 92e6);
    }

    function test_FulfillSwap_CreditsUser() public {
        vm.startPrank(alice);
        eurc.approve(address(router), 100e6);
        router.depositEurc(100e6);
        vm.stopPrank();

        vm.prank(owner);
        router.fulfillSwap(alice, 100e6, 92e6);

        assertEq(router.pendingEurc(alice), 0);
        assertEq(router.usdcBalance(alice), 92e6);
    }

    // ───── withdrawUsdc ──────────────────────────────────────────────────────

    function test_WithdrawUsdc_RevertsOnZero() public {
        vm.prank(alice);
        vm.expectRevert(FXRouter.ZeroAmount.selector);
        router.withdrawUsdc(0, alice);
    }

    function test_WithdrawUsdc_RevertsOnInsufficient() public {
        vm.prank(alice);
        vm.expectRevert(FXRouter.InsufficientBalance.selector);
        router.withdrawUsdc(1e6, alice);
    }

    function test_WithdrawUsdc_TransfersToRecipient() public {
        // Setup: deposit + fulfill
        vm.startPrank(alice);
        eurc.approve(address(router), 100e6);
        router.depositEurc(100e6);
        vm.stopPrank();
        vm.prank(owner);
        router.fulfillSwap(alice, 100e6, 92e6);

        vm.prank(alice);
        router.withdrawUsdc(92e6, alice);

        assertEq(usdc.balanceOf(alice), 92e6);
        assertEq(router.usdcBalance(alice), 0);
    }

    // ───── Fuzz ──────────────────────────────────────────────────────────────

    function testFuzz_DepositAndFulfill(uint256 amount) public {
        amount = bound(amount, 1, 500e6);
        eurc.mint(alice, amount);

        vm.startPrank(alice);
        eurc.approve(address(router), amount);
        router.depositEurc(amount);
        vm.stopPrank();

        uint256 usdcOut = (amount * 92) / 100; // mock 0.92 rate
        vm.prank(owner);
        router.fulfillSwap(alice, amount, usdcOut);

        assertEq(router.usdcBalance(alice), usdcOut);
    }
}
