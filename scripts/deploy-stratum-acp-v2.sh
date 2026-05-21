#!/bin/bash
# Deploy Stratum's own AgenticCommerce (non-upgradeable, we own admin).
set -e

RPC="https://rpc.testnet.arc.network"
DEPLOYER="0x057442C1788c349891F86C09050C8bC1dc68392B"
USDC="0x3600000000000000000000000000000000000000"

echo "=== Deploying Stratum AgenticCommerce ==="

forge create src/vendor/AgenticCommerce.sol:AgenticCommerce \
  --broadcast \
  --rpc-url "$RPC" \
  --account stratum-deployer \
  --from "$DEPLOYER" \
  --constructor-args "$USDC" "$DEPLOYER"
