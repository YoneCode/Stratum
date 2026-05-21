// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @notice Mock USYC Teller: 1:1 exchange rate for simplicity.
contract MockUSYCTeller {
    IERC20 public usdc;
    IERC20 public usyc;

    constructor(address usdc_, address usyc_) {
        usdc = IERC20(usdc_);
        usyc = IERC20(usyc_);
    }

    function deposit(uint256 assets, address receiver) external returns (uint256) {
        usdc.transferFrom(msg.sender, address(this), assets);
        // Mint USYC 1:1 (mock)
        MockMintable(address(usyc)).mint(receiver, assets);
        return assets;
    }

    function redeem(uint256 shares, address receiver, address account) external returns (uint256) {
        usyc.transferFrom(account, address(this), shares);
        // Return USDC 1:1 (mock)
        MockMintable(address(usdc)).mint(receiver, shares);
        return shares;
    }
}

interface MockMintable {
    function mint(address to, uint256 amount) external;
}
