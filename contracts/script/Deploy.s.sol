// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";

import {StratumJobFactory} from "../src/StratumJobFactory.sol";
import {StratumAgentCard} from "../src/StratumAgentCard.sol";

/// @title  Stratum Week 1 deployment script
/// @notice Deploys `StratumJobFactory` + `StratumAgentCard` to Arc Testnet,
///         wiring them up against the live ERC-8183 reference contract and the
///         live ERC-8004 Identity Registry from `arc-dapp.md §2.3–2.4`.
///
/// @dev    USAGE (recommended — keystore, not plaintext key):
///
///           forge script script/Deploy.s.sol:Deploy \
///             --rpc-url https://rpc.testnet.arc.network \
///             --account stratum-deployer \
///             --sender 0xYOUR_DEPLOYER_ADDRESS \
///             --broadcast
///
///         Drop `--broadcast` to do a dry-run simulation without spending USDC.
///
///         Optional env overrides (otherwise defaults to live Arc Testnet addresses):
///           ACP_ADDRESS         — ERC-8183 reference contract
///           IDENTITY_REGISTRY   — ERC-8004 Identity Registry
///           FACTORY_OWNER       — initial owner for `StratumJobFactory.requiredHook`
///                                 (defaults to deployer; pass a multisig for prod)
contract Deploy is Script {
    /// @dev Live primitives on Arc Testnet (chainId 5042002).
    ///      Source: arc-dapp.md §2.3–2.4 (verified 2026-05-20).
    address internal constant ACP_DEFAULT = 0x0747EEf0706327138c69792bF28Cd525089e4583;
    address internal constant IDENTITY_DEFAULT = 0x8004A818BFB912233c491871b3d84c89A494BD9e;

    uint256 internal constant ARC_TESTNET_CHAIN_ID = 5_042_002;

    function run() external returns (StratumJobFactory factory, StratumAgentCard agentCard) {
        address acp = vm.envOr("ACP_ADDRESS", ACP_DEFAULT);
        address identity = vm.envOr("IDENTITY_REGISTRY", IDENTITY_DEFAULT);

        address deployer = msg.sender;
        address factoryOwner = vm.envOr("FACTORY_OWNER", deployer);

        // Hard guard against deploying to the wrong network.
        // Forge will populate block.chainid from the --rpc-url's eth_chainId.
        require(block.chainid == ARC_TESTNET_CHAIN_ID, "Deploy: wrong chain (need Arc Testnet 5042002)");

        console2.log("=== Stratum Week 1 deploy ===");
        console2.log("Deployer       :", deployer);
        console2.log("Chain ID       :", block.chainid);
        console2.log("ACP (8183)     :", acp);
        console2.log("Identity (8004):", identity);
        console2.log("Factory owner  :", factoryOwner);
        console2.log("");

        vm.startBroadcast();
        factory = new StratumJobFactory(acp, factoryOwner);
        agentCard = new StratumAgentCard(identity);
        vm.stopBroadcast();

        console2.log("=== Deployed ===");
        console2.log("StratumJobFactory:", address(factory));
        console2.log("StratumAgentCard :", address(agentCard));
        console2.log("");
        console2.log("Next steps:");
        console2.log("  1. Copy the addresses into app/lib/contracts.ts -> stratumTestnet");
        console2.log("  2. Update PROGRESS.md Deployed-Contracts table with txhash + arcscan link");
        console2.log("  3. Verify on https://testnet.arcscan.app");
    }
}
