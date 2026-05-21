#!/bin/bash
set -e
RPC="https://rpc.testnet.arc.network"
DEPLOYER="0x057442C1788c349891F86C09050C8bC1dc68392B"
VALIDATION_REGISTRY="0x8004Cb1BF31DAf7788923b405b754f57acEB4272"

echo "=== Deploying StratumValidationOracle (stub) ==="
forge create src/StratumValidationOracle.sol:StratumValidationOracle \
  --broadcast \
  --rpc-url "$RPC" \
  --account stratum-deployer \
  --from "$DEPLOYER" \
  --constructor-args "$VALIDATION_REGISTRY" "$DEPLOYER" "$DEPLOYER"
