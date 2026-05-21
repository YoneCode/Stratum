#!/bin/bash
set -e
RPC="https://rpc.testnet.arc.network"
DEPLOYER="0x057442C1788c349891F86C09050C8bC1dc68392B"
USDC="0x3600000000000000000000000000000000000000"

echo "=== Deploying NanopaymentSettlement ==="
forge create src/NanopaymentSettlement.sol:NanopaymentSettlement \
  --broadcast --rpc-url "$RPC" --account stratum-deployer --from "$DEPLOYER" \
  --constructor-args "$USDC" "$DEPLOYER"
