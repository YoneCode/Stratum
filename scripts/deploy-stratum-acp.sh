#!/bin/bash
# Deploy a Stratum-owned ERC-8183 proxy reusing the shared implementation.
set -e

RPC="https://rpc.testnet.arc.network"
DEPLOYER="0x057442C1788c349891F86C09050C8bC1dc68392B"
USDC="0x3600000000000000000000000000000000000000"
IMPL="0xa316fd02827242d537f84730f8a37d0ba5fd351a"

echo "=== Deploying Stratum-owned AgenticCommerce proxy ==="
echo "Implementation: $IMPL"
echo "Payment token:  $USDC"
echo "Treasury/Admin: $DEPLOYER"
echo ""

# Encode initialize(address paymentToken_, address treasury_)
INIT_DATA=$(cast calldata "initialize(address,address)" "$USDC" "$DEPLOYER")
echo "Init calldata: $INIT_DATA"
echo ""

echo ">>> Deploying ERC1967Proxy"
forge create lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol:ERC1967Proxy \
  --broadcast \
  --rpc-url "$RPC" \
  --account stratum-deployer \
  --from "$DEPLOYER" \
  --constructor-args "$IMPL" "$INIT_DATA"
