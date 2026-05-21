// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title  FXRouter
/// @notice Wraps the "pay in EURC, escrow in USDC" flow. Users deposit EURC →
///         off-chain backend swaps via StableFX API → USDC arrives in this
///         contract → user can then fund ACP jobs in USDC.
/// @dev    StableFX is an RFQ system (not a direct onchain swap router).
///         The onchain contract:
///         1. Accepts EURC deposits and emits a `SwapRequested` event.
///         2. A trusted relayer (owner) calls `fulfillSwap` once the StableFX
///            API settles, crediting the user's USDC balance.
///         3. User calls `withdrawUsdc` or approves a spender.
///
///         This is the simplest correct architecture given StableFX's RFQ model.
///         Production would add Permit2 for gasless approvals and timeout refunds.
contract FXRouter is ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;

    IERC20 public immutable eurc;
    IERC20 public immutable usdc;

    /// @notice Pending EURC deposits awaiting swap fulfillment.
    mapping(address => uint256) public pendingEurc;
    /// @notice Fulfilled USDC balances ready for withdrawal.
    mapping(address => uint256) public usdcBalance;

    event SwapRequested(address indexed user, uint256 eurcAmount);
    event SwapFulfilled(address indexed user, uint256 eurcAmount, uint256 usdcAmount);
    event UsdcWithdrawn(address indexed user, address indexed to, uint256 amount);

    error ZeroAmount();
    error InsufficientBalance();
    error NoPendingSwap();

    constructor(address eurc_, address usdc_, address owner_) Ownable(owner_) {
        eurc = IERC20(eurc_);
        usdc = IERC20(usdc_);
    }

    /// @notice Deposit EURC to request a swap to USDC. Caller must approve this contract.
    function depositEurc(uint256 eurcAmount) external nonReentrant {
        if (eurcAmount == 0) revert ZeroAmount();
        eurc.safeTransferFrom(msg.sender, address(this), eurcAmount);
        pendingEurc[msg.sender] += eurcAmount;
        emit SwapRequested(msg.sender, eurcAmount);
    }

    /// @notice Called by relayer after StableFX API settles the swap.
    ///         Relayer must have transferred USDC to this contract before calling.
    function fulfillSwap(address user, uint256 eurcAmount, uint256 usdcAmount) external onlyOwner {
        if (pendingEurc[user] < eurcAmount) revert NoPendingSwap();
        pendingEurc[user] -= eurcAmount;
        usdcBalance[user] += usdcAmount;
        emit SwapFulfilled(user, eurcAmount, usdcAmount);
    }

    /// @notice Withdraw settled USDC.
    function withdrawUsdc(uint256 amount, address to) external nonReentrant {
        if (amount == 0) revert ZeroAmount();
        if (usdcBalance[msg.sender] < amount) revert InsufficientBalance();
        usdcBalance[msg.sender] -= amount;
        usdc.safeTransfer(to, amount);
        emit UsdcWithdrawn(msg.sender, to, amount);
    }

    /// @notice Approve a spender (e.g. ACP) to pull USDC from user's balance.
    function approveSpender(address spender, uint256 amount) external nonReentrant {
        if (amount == 0) revert ZeroAmount();
        if (usdcBalance[msg.sender] < amount) revert InsufficientBalance();
        usdcBalance[msg.sender] -= amount;
        usdc.approve(spender, amount);
        emit UsdcWithdrawn(msg.sender, spender, amount);
    }
}
