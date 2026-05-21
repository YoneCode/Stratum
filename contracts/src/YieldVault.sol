// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IUSYCTeller} from "./interfaces/IUSYCTeller.sol";

/// @title  YieldVault
/// @notice ERC-4626-ish wrapper: users deposit USDC → vault subscribes to USYC
///         via the Teller → idle balances earn T-bill yield. On `redeemAndApprove`,
///         atomically redeems USYC → USDC and approves a spender (e.g. the ACP
///         for job funding).
/// @dev    NOT a full ERC-4626 (no share token minting). Instead it tracks per-user
///         USYC balances internally. This is simpler and avoids the complexity of
///         share-price oracles for a testnet demo. Production would use a proper
///         ERC-4626 vault with yield distribution.
///
///         Requires the vault address to be USYC-allowlisted by Circle.
contract YieldVault is ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;

    IERC20 public immutable usdc;
    IERC20 public immutable usyc;
    IUSYCTeller public immutable teller;

    /// @notice Per-user USYC share balance held by this vault.
    mapping(address => uint256) public balanceOf;

    event Deposited(address indexed user, uint256 usdcAmount, uint256 usycReceived);
    event Redeemed(address indexed user, uint256 usycAmount, uint256 usdcReceived);
    event RedeemedAndApproved(address indexed user, address indexed spender, uint256 usdcAmount);

    error ZeroAmount();
    error InsufficientBalance();
    error ZeroAddress();

    constructor(address usdc_, address usyc_, address teller_, address owner_) Ownable(owner_) {
        if (usdc_ == address(0) || usyc_ == address(0) || teller_ == address(0)) revert ZeroAddress();
        usdc = IERC20(usdc_);
        usyc = IERC20(usyc_);
        teller = IUSYCTeller(teller_);
    }

    /// @notice Deposit USDC → subscribe to USYC via Teller. Caller must approve this vault.
    function deposit(uint256 usdcAmount) external nonReentrant returns (uint256 usycReceived) {
        if (usdcAmount == 0) revert ZeroAmount();

        usdc.safeTransferFrom(msg.sender, address(this), usdcAmount);
        usdc.approve(address(teller), usdcAmount);
        usycReceived = teller.deposit(usdcAmount, address(this));
        balanceOf[msg.sender] += usycReceived;

        emit Deposited(msg.sender, usdcAmount, usycReceived);
    }

    /// @notice Redeem USYC → USDC, send to caller.
    function redeem(uint256 usycAmount) external nonReentrant returns (uint256 usdcReceived) {
        if (usycAmount == 0) revert ZeroAmount();
        if (balanceOf[msg.sender] < usycAmount) revert InsufficientBalance();

        balanceOf[msg.sender] -= usycAmount;
        usyc.approve(address(teller), usycAmount);
        usdcReceived = teller.redeem(usycAmount, msg.sender, address(this));

        emit Redeemed(msg.sender, usycAmount, usdcReceived);
    }

    /// @notice Atomic redeem + approve: redeems USYC → USDC, then approves
    ///         `spender` to pull `usdcAmount` of USDC from this vault.
    ///         Used for one-click "fund job from yield" flow.
    function redeemAndApprove(uint256 usycAmount, address spender) external nonReentrant returns (uint256 usdcReceived) {
        if (usycAmount == 0) revert ZeroAmount();
        if (spender == address(0)) revert ZeroAddress();
        if (balanceOf[msg.sender] < usycAmount) revert InsufficientBalance();

        balanceOf[msg.sender] -= usycAmount;
        usyc.approve(address(teller), usycAmount);
        usdcReceived = teller.redeem(usycAmount, address(this), address(this));

        // Approve spender (e.g. ACP contract) to pull the USDC
        usdc.approve(spender, usdcReceived);

        emit RedeemedAndApproved(msg.sender, spender, usdcReceived);
    }
}
