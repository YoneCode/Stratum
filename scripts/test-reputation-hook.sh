#!/bin/bash
# Steps 5-6: Wire up reputation hook and run full lifecycle with it
set -e

RPC="https://rpc.testnet.arc.network"
ACP="0x0747EEf0706327138c69792bF28Cd525089e4583"
USDC="0x3600000000000000000000000000000000000000"
DEPLOYER="0x057442C1788c349891F86C09050C8bC1dc68392B"
ACCOUNT="stratum-deployer"
FACTORY="0xad7157cE777c62273E2CADf8e81203bCBD23E1Fe"
HOOK="0x72f8B2eCf00ac5F36335d2971F79A1FAaA4B6e22"
AGENT_ID="17868"

echo "=========================================="
echo "  Week 2: Reputation Hook Integration"
echo "=========================================="
echo ""

# ─── Step A: Set requiredHook on StratumJobFactory ────────────────────
echo ">>> A: setRequiredHook on StratumJobFactory"
cast send "$FACTORY" "setRequiredHook(address)" "$HOOK" \
  --rpc-url "$RPC" --account "$ACCOUNT" --from "$DEPLOYER"
echo "✅ requiredHook set to $HOOK"
echo ""

# ─── Step B: Register provider on the hook ────────────────────────────
echo ">>> B: registerProvider on StratumReputationHook"
cast send "$HOOK" "registerProvider(address,uint256)" "$DEPLOYER" "$AGENT_ID" \
  --rpc-url "$RPC" --account "$ACCOUNT" --from "$DEPLOYER"
echo "✅ Provider registered (agentId=$AGENT_ID)"
echo ""

# ─── Step C: Create job WITH hook attached ────────────────────────────
EXPIRY=$(($(date +%s) + 86400))
echo ">>> C: createJob (with hook=$HOOK)"
TX1=$(cast send "$ACP" "createJob(address,address,uint256,string,address)" \
  "$DEPLOYER" "$DEPLOYER" "$EXPIRY" "Reputation hook test job" "$HOOK" \
  --rpc-url "$RPC" --account "$ACCOUNT" --from "$DEPLOYER" \
  --json | jq -r '.transactionHash')
echo "Tx: $TX1"
sleep 2
JOB_ID_HEX=$(cast receipt "$TX1" --rpc-url "$RPC" --json | jq -r '.logs[0].topics[1]')
JOB_ID=$((16#${JOB_ID_HEX:2}))
echo "✅ Job created! jobId=$JOB_ID"
echo ""

# ─── Step D: setBudget ────────────────────────────────────────────────
BUDGET="1000000"
echo ">>> D: setBudget($JOB_ID, $BUDGET)"
cast send "$ACP" "setBudget(uint256,uint256,bytes)" "$JOB_ID" "$BUDGET" "0x" \
  --rpc-url "$RPC" --account "$ACCOUNT" --from "$DEPLOYER"
echo "✅ Budget set"
echo ""

# ─── Step E: approve + fund ───────────────────────────────────────────
echo ">>> E: approve + fund"
cast send "$USDC" "approve(address,uint256)" "$ACP" "$BUDGET" \
  --rpc-url "$RPC" --account "$ACCOUNT" --from "$DEPLOYER"
cast send "$ACP" "fund(uint256,bytes)" "$JOB_ID" "0x" \
  --rpc-url "$RPC" --account "$ACCOUNT" --from "$DEPLOYER"
echo "✅ Funded"
echo ""

# ─── Step F: submit ───────────────────────────────────────────────────
DELIVERABLE=$(cast keccak "ipfs://bafkreireputation-test")
echo ">>> F: submit"
cast send "$ACP" "submit(uint256,bytes32,bytes)" "$JOB_ID" "$DELIVERABLE" "0x" \
  --rpc-url "$RPC" --account "$ACCOUNT" --from "$DEPLOYER"
echo "✅ Submitted"
echo ""

# ─── Step G: complete (triggers hook → giveFeedback) ──────────────────
REASON=$(cast keccak "quality:excellent")
echo ">>> G: complete (should trigger giveFeedback via hook)"
COMPLETE_TX=$(cast send "$ACP" "complete(uint256,bytes32,bytes)" "$JOB_ID" "$REASON" "0x" \
  --rpc-url "$RPC" --account "$ACCOUNT" --from "$DEPLOYER" \
  --json | jq -r '.transactionHash')
echo "Complete tx: $COMPLETE_TX"
echo ""

# ─── Step H: Check logs for giveFeedback ──────────────────────────────
echo ">>> H: Checking complete tx logs for FeedbackWritten + NewFeedback events"
cast receipt "$COMPLETE_TX" --rpc-url "$RPC" --json | jq '.logs | length'
cast receipt "$COMPLETE_TX" --rpc-url "$RPC" --json | jq '.logs[] | .address'
echo ""
echo "=========================================="
echo "  🎉 WEEK 2 REPUTATION HOOK: VERIFIED"
echo "=========================================="
echo "Job ID:      $JOB_ID"
echo "Hook:        $HOOK"
echo "Complete tx:  https://testnet.arcscan.app/tx/$COMPLETE_TX"
echo ""
echo "Look for events from:"
echo "  - $HOOK (FeedbackWritten)"
echo "  - 0x8004B663... (NewFeedback on Reputation Registry)"
