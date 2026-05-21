// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title  NanopaymentSettlement
/// @notice Receives batched x402 micropayment settlements. The x402 server collects
///         signed EIP-3009 `transferWithAuthorization` messages off-chain, then
///         periodically calls `batchSettle` to move USDC from payers into per-merchant
///         balances. Merchants withdraw at any time.
/// @dev    Flow:
///         1. Client signs EIP-3009 payload off-chain (transferWithAuthorization).
///         2. x402 server validates the sig, serves the response, queues the payment.
///         3. Every N minutes, the server (or a cron bot) calls `batchSettle(...)`.
///         4. This contract calls USDC's `transferWithAuthorization` for each payment,
///            crediting the merchant's balance.
///         5. Merchants call `withdraw()` to collect.
///
///         On Arc Testnet, USDC at 0x3600… supports EIP-3009.
contract NanopaymentSettlement is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    IERC20 public immutable usdc;

    /// @notice Accumulated settled balance per merchant.
    mapping(address => uint256) public balanceOf;

    /// @notice Replay protection: hash of each settled authorization.
    mapping(bytes32 => bool) public settled;

    event PaymentSettled(address indexed from, address indexed merchant, uint256 amount, bytes32 nonce);
    event BatchSettled(uint256 count, uint256 totalAmount);
    event Withdrawn(address indexed merchant, uint256 amount);

    error AlreadySettled();
    error ZeroAmount();
    error InsufficientBalance();
    error LengthMismatch();

    struct Payment {
        address from;
        address merchant;
        uint256 amount;
        uint256 validAfter;
        uint256 validBefore;
        bytes32 nonce;
        bytes signature; // 65 bytes: r + s + v
    }

    constructor(address usdc_, address owner_) Ownable(owner_) {
        usdc = IERC20(usdc_);
    }

    /// @notice Settle a batch of EIP-3009 authorized payments.
    /// @dev    Caller (the x402 server) pays gas. Each payment transfers USDC
    ///         from `from` to this contract and credits `merchant`.
    ///         Silently skips already-settled nonces (idempotent).
    function batchSettle(Payment[] calldata payments) external nonReentrant {
        uint256 total;
        uint256 count;

        for (uint256 i; i < payments.length; ++i) {
            Payment calldata p = payments[i];
            bytes32 settlementId = keccak256(abi.encode(p.from, p.merchant, p.amount, p.nonce));

            if (settled[settlementId]) continue; // idempotent skip
            settled[settlementId] = true;

            // Call EIP-3009 transferWithAuthorization on USDC
            // This transfers from `p.from` to `address(this)` using their signature
            (bool ok,) = address(usdc).call(
                abi.encodeWithSignature(
                    "transferWithAuthorization(address,address,uint256,uint256,uint256,bytes32,bytes)",
                    p.from,
                    address(this),
                    p.amount,
                    p.validAfter,
                    p.validBefore,
                    p.nonce,
                    p.signature
                )
            );

            if (ok) {
                balanceOf[p.merchant] += p.amount;
                total += p.amount;
                count++;
                emit PaymentSettled(p.from, p.merchant, p.amount, p.nonce);
            }
            // If transferWithAuthorization fails (bad sig, expired, etc.), skip silently
        }

        if (count > 0) emit BatchSettled(count, total);
    }

    /// @notice Direct deposit (for testing or manual settlements).
    function deposit(address merchant, uint256 amount) external nonReentrant {
        if (amount == 0) revert ZeroAmount();
        usdc.safeTransferFrom(msg.sender, address(this), amount);
        balanceOf[merchant] += amount;
        emit PaymentSettled(msg.sender, merchant, amount, bytes32(0));
    }

    /// @notice Merchant withdraws their accumulated balance.
    function withdraw(uint256 amount) external nonReentrant {
        if (amount == 0) revert ZeroAmount();
        if (balanceOf[msg.sender] < amount) revert InsufficientBalance();
        balanceOf[msg.sender] -= amount;
        usdc.safeTransfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }

    /// @notice Withdraw full balance.
    function withdrawAll() external nonReentrant {
        uint256 bal = balanceOf[msg.sender];
        if (bal == 0) revert ZeroAmount();
        balanceOf[msg.sender] = 0;
        usdc.safeTransfer(msg.sender, bal);
        emit Withdrawn(msg.sender, bal);
    }
}
