#!/bin/bash
set -e

RPC="https://rpc.testnet.arc.network"
AGENT_CARD="0xeE9a8Cb064b789071c15a6c5aBB25D570871E0eB"
DEPLOYER="0x057442C1788c349891F86C09050C8bC1dc68392B"
AGENT_ID="17868"

# category = keccak256("legal-research")
CATEGORY=$(cast keccak "legal-research")

# tags = [keccak256("law"), keccak256("eu")]
TAG1=$(cast keccak "law")
TAG2=$(cast keccak "eu")

echo "=== Linking agent $AGENT_ID on StratumAgentCard ==="
echo "Category: $CATEGORY"
echo "Tags: [$TAG1, $TAG2]"
echo ""

cast send "$AGENT_CARD" "linkAgent(uint256,bytes32,bytes32[])" \
  "$AGENT_ID" \
  "$CATEGORY" \
  "[$TAG1,$TAG2]" \
  --rpc-url "$RPC" \
  --account stratum-deployer \
  --from "$DEPLOYER"
