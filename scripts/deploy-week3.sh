#!/bin/bash
set -e
RPC="https://rpc.testnet.arc.network"
DEPLOYER="0x057442C1788c349891F86C09050C8bC1dc68392B"
USDC="0x3600000000000000000000000000000000000000"
USYC="0xe9185F0c5F296Ed1797AaE4238D26CCaBEadb86C"
TELLER="0xcc205224862c7641930c87679e98999d23c26113"
EURC="0x89B50855Aa3bE2F677cD6303Cec089B5F319D72a"

echo "=== Deploying YieldVault ==="
forge create src/YieldVault.sol:YieldVault \
  --broadcast --rpc-url "$RPC" --account stratum-deployer --from "$DEPLOYER" \
  --constructor-args "$USDC" "$USYC" "$TELLER" "$DEPLOYER"

echo ""
echo "=== Deploying FXRouter ==="
forge create src/FXRouter.sol:FXRouter \
  --broadcast --rpc-url "$RPC" --account stratum-deployer --from "$DEPLOYER" \
  --constructor-args "$EURC" "$USDC" "$DEPLOYER"
