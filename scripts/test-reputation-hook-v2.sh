#!/bin/bash
# Redeploy StratumReputationHook pointing at Stratum's own ACP, then run full lifecycle.
set -e

RPC="https://rpc.testnet.arc.network"
DEPLOYER="0x057442C1788c349891F86C09050C8bC1dc68392B"
ACCOUNT="stratum-deployer"
USDC="0x3600000000000000000000000000000000000000"
STRATUM_ACP="0x989c0f21c712EecF8bD7AB1caf1A8Ba3da88a46f"
REPUTATION="0x8004B663056A597Dffe9eCcC1965A193B7388713"
IDENTITY="0x8004A818BFB912233c491871b3d84c89A494BD9e"
AGENT_ID="17868"

echo "=========================================="
echo "  Week 2: Full Hook Integration"
echo "=========================================="
echo ""

# ─── 1: Deploy new hook pointing at Stratum ACP ──────────────────────
echo ">>> 1: Deploy StratumReputationHook (ACP=$STRATUM_ACP)"
HOOK_RESULT=$(forge create src/StratumReputationHook.sol:StratumReputationHook \
  --broadcast \
  --rpc-url "$RPC" \
  --account "$ACCOUNT" \
  --from "$DEPLOYER" \
  --constructor-args "$STRATUM_ACP" "$REPUTATION" "$IDENTITY" 2>&1)
echo "$HOOK_RESULT"
HOOK=$(echo "$HOOK_RESULT" | grep "Deployed to:" | awk '{print $3}')
echo "Hook: $HOOK"
echo ""

# ─── 2: Whitelist hook on Stratum ACP ────────────────────────────────
echo ">>> 2: Whitelist hook on Stratum ACP"
cast send "$STRATUM_ACP" "setHookWhitelist(address,bool)" "$HOOK" true \
  --rpc-url "$RPC" --account "$ACCOUNT" --from "$DEPLOYER"
echo "✅ Hook whitelisted"
echo ""

# ─── 3: Register provider on hook ────────────────────────────────────
echo ">>> 3: Register provider (agentId=$AGENT_ID)"
cast send "$HOOK" "registerProvider(address,uint256)" "$DEPLOYER" "$AGENT_ID" \
  --rpc-url "$RPC" --account "$ACCOUNT" --from "$DEPLOYER"
echo "✅ Provider registered"
echo ""

# ─── 4: Create job with hook ─────────────────────────────────────────
EXPIRY=$(($(date +%s) + 86400))
echo ">>> 4: createJob (hook=$HOOK)"
TX=$(cast send "$STRATUM_ACP" "createJob(address,address,uint256,string,address)" \
  "$DEPLOYER" "$DEPLOYER" "$EXPIRY" "Reputation hook test" "$HOOK" \
  --rpc-url "$RPC" --account "$ACCOUNT" --from "$DEPLOYER" \
  --json | jq -r '.transactionHash')
sleep 2
JOB_ID_HEX=$(cast receipt "$TX" --rpc-url "$RPC" --json | jq -r '.logs[0].topics[1]')
JOB_ID=$((16#${JOB_ID_HEX:2}))
echo "✅ Job $JOB_ID created (tx: $TX)"
echo ""

# ─── 5: setBudget ────────────────────────────────────────────────────
BUDGET="1000000"
echo ">>> 5: setBudget($JOB_ID, 1 USDC)"
cast send "$STRATUM_ACP" "setBudget(uint256,uint256,bytes)" "$JOB_ID" "$BUDGET" "0x" \
  --rpc-url "$RPC" --account "$ACCOUNT" --from "$DEPLOYER"
echo "✅ Budget set"
echo ""

# ─── 6: approve + fund ───────────────────────────────────────────────
echo ">>> 6: approve + fund"
cast send "$USDC" "approve(address,uint256)" "$STRATUM_ACP" "$BUDGET" \
  --rpc-url "$RPC" --account "$ACCOUNT" --from "$DEPLOYER"
cast send "$STRATUM_ACP" "fund(uint256,bytes)" "$JOB_ID" "0x" \
  --rpc-url "$RPC" --account "$ACCOUNT" --from "$DEPLOYER"
echo "✅ Funded"
echo ""

# ─── 7: submit ───────────────────────────────────────────────────────
DELIVERABLE=$(cast keccak "ipfs://bafkreideliverable-hook-test")
echo ">>> 7: submit"
cast send "$STRATUM_ACP" "submit(uint256,bytes32,bytes)" "$JOB_ID" "$DELIVERABLE" "0x" \
  --rpc-url "$RPC" --account "$ACCOUNT" --from "$DEPLOYER"
echo "✅ Submitted"
echo ""

# ─── 8: complete (triggers hook → giveFeedback) ──────────────────────
REASON=$(cast keccak "quality:excellent")
echo ">>> 8: complete (should trigger giveFeedback)"
COMPLETE_TX=$(cast send "$STRATUM_ACP" "complete(uint256,bytes32,bytes)" "$JOB_ID" "$REASON" "0x" \
  --rpc-url "$RPC" --account "$ACCOUNT" --from "$DEPLOYER" \
  --json | jq -r '.transactionHash')
echo "Complete tx: $COMPLETE_TX"
echo ""

# ─── 9: Check logs ───────────────────────────────────────────────────
echo ">>> 9: Checking events in complete tx"
sleep 2
LOGS=$(cast receipt "$COMPLETE_TX" --rpc-url "$RPC" --json | jq '.logs')
echo "$LOGS" | jq '.[].address'
NUM_LOGS=$(echo "$LOGS" | jq 'length')
echo ""
echo "=========================================="
echo "  🎉 COMPLETE — $NUM_LOGS events in tx"
echo "=========================================="
echo "Job:         $JOB_ID"
echo "Hook:        $HOOK"
echo "Stratum ACP: $STRATUM_ACP"
echo "Complete tx:  https://testnet.arcscan.app/tx/$COMPLETE_TX"
echo ""
echo "Expected event addresses:"
echo "  - $STRATUM_ACP (JobCompleted + PaymentReleased)"
echo "  - $HOOK (FeedbackWritten)"
echo "  - $REPUTATION (NewFeedback)"
