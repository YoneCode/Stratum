// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/// @title IUSYC Teller
/// @notice Interface for Circle's USYC Teller contract — handles subscriptions and redemptions.
/// @dev    Source: https://developers.circle.com/tokenized/usyc/subscribe-and-redeem
///         Deployed at 0xcc205224862c7641930c87679e98999d23c26113 on Arc Testnet.
///         Requires USYC allowlist approval for the caller.
interface IUSYCTeller {
    /// @notice Subscribe: deposit USDC, receive USYC.
    /// @param assets Amount of USDC (6 decimals) to deposit.
    /// @param receiver Address to receive USYC shares.
    /// @return shares Amount of USYC minted.
    function deposit(uint256 assets, address receiver) external returns (uint256 shares);

    /// @notice Redeem: burn USYC, receive USDC.
    /// @param shares Amount of USYC (6 decimals) to redeem.
    /// @param receiver Address to receive USDC.
    /// @param account Address that holds the USYC being redeemed.
    /// @return assets Amount of USDC returned.
    function redeem(uint256 shares, address receiver, address account) external returns (uint256 assets);
}
