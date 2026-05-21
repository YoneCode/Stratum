// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Test} from "forge-std/Test.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {NanopaymentSettlement} from "../src/NanopaymentSettlement.sol";
import {MockERC20} from "./mocks/MockERC20.sol";

contract NanopaymentSettlementTest is Test {
    NanopaymentSettlement internal settlement;
    MockERC20 internal usdc;

    address internal owner = makeAddr("owner");
    address internal merchant = makeAddr("merchant");
    address internal payer = makeAddr("payer");

    function setUp() public {
        usdc = new MockERC20("USDC", "USDC", 6);
        settlement = new NanopaymentSettlement(address(usdc), owner);
        usdc.mint(payer, 1000e6);
    }

    // ───── deposit (direct) ──────────────────────────────────────────────────

    function test_Deposit_RevertsOnZero() public {
        vm.prank(payer);
        vm.expectRevert(NanopaymentSettlement.ZeroAmount.selector);
        settlement.deposit(merchant, 0);
    }

    function test_Deposit_CreditsMerchant() public {
        vm.startPrank(payer);
        usdc.approve(address(settlement), 100e6);
        settlement.deposit(merchant, 100e6);
        vm.stopPrank();

        assertEq(settlement.balanceOf(merchant), 100e6);
        assertEq(usdc.balanceOf(address(settlement)), 100e6);
    }

    // ───── withdraw ──────────────────────────────────────────────────────────

    function test_Withdraw_RevertsOnZero() public {
        vm.prank(merchant);
        vm.expectRevert(NanopaymentSettlement.ZeroAmount.selector);
        settlement.withdraw(0);
    }

    function test_Withdraw_RevertsOnInsufficient() public {
        vm.prank(merchant);
        vm.expectRevert(NanopaymentSettlement.InsufficientBalance.selector);
        settlement.withdraw(1e6);
    }

    function test_Withdraw_TransfersToMerchant() public {
        // Setup
        vm.startPrank(payer);
        usdc.approve(address(settlement), 50e6);
        settlement.deposit(merchant, 50e6);
        vm.stopPrank();

        vm.prank(merchant);
        settlement.withdraw(50e6);

        assertEq(usdc.balanceOf(merchant), 50e6);
        assertEq(settlement.balanceOf(merchant), 0);
    }

    // ───── withdrawAll ───────────────────────────────────────────────────────

    function test_WithdrawAll_RevertsOnZeroBalance() public {
        vm.prank(merchant);
        vm.expectRevert(NanopaymentSettlement.ZeroAmount.selector);
        settlement.withdrawAll();
    }

    function test_WithdrawAll_DrainsFull() public {
        vm.startPrank(payer);
        usdc.approve(address(settlement), 75e6);
        settlement.deposit(merchant, 75e6);
        vm.stopPrank();

        vm.prank(merchant);
        settlement.withdrawAll();

        assertEq(usdc.balanceOf(merchant), 75e6);
        assertEq(settlement.balanceOf(merchant), 0);
    }

    // ───── batchSettle (with mock — transferWithAuthorization not on MockERC20) ─

    function test_BatchSettle_EmptyArray() public {
        NanopaymentSettlement.Payment[] memory empty = new NanopaymentSettlement.Payment[](0);
        settlement.batchSettle(empty); // should not revert
    }

    // ───── Fuzz ──────────────────────────────────────────────────────────────

    function testFuzz_DepositAndWithdraw(uint256 amount) public {
        amount = bound(amount, 1, 500e6);
        usdc.mint(payer, amount);

        vm.startPrank(payer);
        usdc.approve(address(settlement), amount);
        settlement.deposit(merchant, amount);
        vm.stopPrank();

        vm.prank(merchant);
        settlement.withdraw(amount);
        assertEq(usdc.balanceOf(merchant), amount);
    }
}
