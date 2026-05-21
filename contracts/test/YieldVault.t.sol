// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Test} from "forge-std/Test.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {YieldVault} from "../src/YieldVault.sol";
import {MockERC20} from "./mocks/MockERC20.sol";
import {MockUSYCTeller} from "./mocks/MockUSYCTeller.sol";

contract YieldVaultTest is Test {
    YieldVault internal vault;
    MockERC20 internal usdc;
    MockERC20 internal usyc;
    MockUSYCTeller internal teller;

    address internal owner = makeAddr("owner");
    address internal alice = makeAddr("alice");
    address internal spender = makeAddr("spender");

    function setUp() public {
        usdc = new MockERC20("USDC", "USDC", 6);
        usyc = new MockERC20("USYC", "USYC", 6);
        teller = new MockUSYCTeller(address(usdc), address(usyc));
        vault = new YieldVault(address(usdc), address(usyc), address(teller), owner);

        usdc.mint(alice, 1000e6);
    }

    // ───── Constructor ───────────────────────────────────────────────────────

    function test_Constructor_RevertsOnZero() public {
        vm.expectRevert(YieldVault.ZeroAddress.selector);
        new YieldVault(address(0), address(usyc), address(teller), owner);
    }

    // ───── deposit — reverts ─────────────────────────────────────────────────

    function test_Deposit_RevertsOnZero() public {
        vm.prank(alice);
        vm.expectRevert(YieldVault.ZeroAmount.selector);
        vault.deposit(0);
    }

    // ───── deposit — happy ───────────────────────────────────────────────────

    function test_Deposit_SubscribesAndCredits() public {
        vm.startPrank(alice);
        usdc.approve(address(vault), 100e6);
        uint256 received = vault.deposit(100e6);
        vm.stopPrank();

        assertEq(received, 100e6);
        assertEq(vault.balanceOf(alice), 100e6);
        assertEq(usdc.balanceOf(alice), 900e6);
    }

    // ───── redeem ────────────────────────────────────────────────────────────

    function test_Redeem_RevertsOnZero() public {
        vm.prank(alice);
        vm.expectRevert(YieldVault.ZeroAmount.selector);
        vault.redeem(0);
    }

    function test_Redeem_RevertsOnInsufficient() public {
        vm.prank(alice);
        vm.expectRevert(YieldVault.InsufficientBalance.selector);
        vault.redeem(1e6);
    }

    function test_Redeem_ReturnsUsdc() public {
        vm.startPrank(alice);
        usdc.approve(address(vault), 100e6);
        vault.deposit(100e6);
        uint256 usdcBack = vault.redeem(50e6);
        vm.stopPrank();

        assertEq(usdcBack, 50e6);
        assertEq(vault.balanceOf(alice), 50e6);
    }

    // ───── redeemAndApprove ──────────────────────────────────────────────────

    function test_RedeemAndApprove_Works() public {
        vm.startPrank(alice);
        usdc.approve(address(vault), 100e6);
        vault.deposit(100e6);
        uint256 usdcBack = vault.redeemAndApprove(100e6, spender);
        vm.stopPrank();

        assertEq(usdcBack, 100e6);
        assertEq(vault.balanceOf(alice), 0);
        assertEq(usdc.allowance(address(vault), spender), 100e6);
    }

    function test_RedeemAndApprove_RevertsOnZeroSpender() public {
        vm.startPrank(alice);
        usdc.approve(address(vault), 100e6);
        vault.deposit(100e6);
        vm.expectRevert(YieldVault.ZeroAddress.selector);
        vault.redeemAndApprove(100e6, address(0));
        vm.stopPrank();
    }
}
