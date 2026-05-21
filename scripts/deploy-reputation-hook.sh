#!/bin/bash
set -e

RPC="https://rpc.testnet.arc.network"
DEPLOYER="0x057442C1788c349891F86C09050C8bC1dc68392B"
ACP="0x0747EEf0706327138c69792bF28Cd525089e4583"
REPUTATION="0x8004B663056A597Dffe9eCcC1965A193B7388713"
IDENTITY="0x8004A818BFB912233c491871b3d84c89A494BD9e"

echo "=== Deploying StratumReputationHook ==="
echo "ACP:        $ACP"
echo "Reputation: $REPUTATION"
echo "Identity:   $IDENTITY"
echo ""

# Deploy using CREATE (forge create is simpler for a single contract)
forge create src/StratumReputationHook.sol:StratumReputationHook \
  --broadcast \
  --rpc-url "$RPC" \
  --account stratum-deployer \
  --from "$DEPLOYER" \
  --constructor-args "$ACP" "$REPUTATION" "$IDENTITY"
