#!/bin/bash
# Register 2 more agents (fxquoter + summarizer) on ERC-8004 + link on StratumAgentCard
set -e

RPC="https://rpc.testnet.arc.network"
IDENTITY="0x8004A818BFB912233c491871b3d84c89A494BD9e"
AGENT_CARD="0xeE9a8Cb064b789071c15a6c5aBB25D570871E0eB"
DEPLOYER="0x057442C1788c349891F86C09050C8bC1dc68392B"
ACCOUNT="stratum-deployer"

register_and_link() {
  local NAME="$1"
  local JSON_FILE="$2"
  local CATEGORY="$3"
  local TAG1="$4"
  local TAG2="$5"

  echo "=== Registering $NAME ==="
  local B64=$(cat "$JSON_FILE" | base64 -w0)
  local URI="data:application/json;base64,${B64}"

  # Register on ERC-8004
  local TX=$(cast send "$IDENTITY" "register(string)" "$URI" \
    --rpc-url "$RPC" --account "$ACCOUNT" --from "$DEPLOYER" \
    --json | jq -r '.transactionHash')
  sleep 2

  # Extract agentId from Transfer event (topic[3])
  local AGENT_ID_HEX=$(cast receipt "$TX" --rpc-url "$RPC" --json | jq -r '.logs[0].topics[3]')
  local AGENT_ID=$((16#${AGENT_ID_HEX:2}))
  echo "✅ $NAME registered: agentId=$AGENT_ID (tx: $TX)"

  # Link on StratumAgentCard
  local CAT_HASH=$(cast keccak "$CATEGORY")
  local T1=$(cast keccak "$TAG1")
  local T2=$(cast keccak "$TAG2")

  cast send "$AGENT_CARD" "linkAgent(uint256,bytes32,bytes32[])" \
    "$AGENT_ID" "$CAT_HASH" "[$T1,$T2]" \
    --rpc-url "$RPC" --account "$ACCOUNT" --from "$DEPLOYER"
  echo "✅ $NAME linked on StratumAgentCard"
  echo ""
}

register_and_link "FXQuoter" "/home/stratum/stratum/agents/agent-cards/fxquoter.json" "fx-oracle" "forex" "usdc-eurc"
register_and_link "Summarizer" "/home/stratum/stratum/agents/agent-cards/summarizer.json" "summarization" "nlp" "documents"

echo "🎉 All agents registered!"
