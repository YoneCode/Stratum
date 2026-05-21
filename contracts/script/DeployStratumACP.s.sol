// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

/// @notice Deploy a Stratum-owned AgenticCommerce proxy reusing the shared impl.
contract DeployStratumACP is Script {
    address constant IMPL = 0xA316fd02827242D537F84730F8a37D0BA5fd351a;
    address constant USDC = 0x3600000000000000000000000000000000000000;

    function run() external {
        address deployer = msg.sender;
        bytes memory initData = abi.encodeWithSignature(
            "initialize(address,address)", USDC, deployer
        );

        console2.log("Impl:", IMPL);
        console2.log("Init data length:", initData.length);

        vm.startBroadcast();
        ERC1967Proxy proxy = new ERC1967Proxy(IMPL, initData);
        vm.stopBroadcast();

        console2.log("Stratum ACP proxy:", address(proxy));
    }
}
