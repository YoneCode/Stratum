#!/bin/bash
# Full ERC-8183 job lifecycle: createJob → setBudget → fund → submit → complete
# Run: ~/stratum/scripts/job-lifecycle.sh
# Requires: keystore "stratum-deployer" with USDC balance on Arc Testnet
set -e

RPC="https://rpc.testnet.arc.network"
ACP="0x0747EEf0706327138c69792bF28Cd525089e4583"
USDC="0x3600000000000000000000000000000000000000"
DEPLOYER="0x057442C1788c349891F86C09050C8bC1dc68392B"
ACCOUNT="stratum-deployer"

# Job params
PROVIDER="$DEPLOYER"      # deployer is also the provider (self-service demo)
EVALUATOR="$DEPLOYER"     # deployer is also the evaluator (client-completes pattern)
EXPIRY=$(($(date +%s) + 86400))  # 24h from now
DESCRIPTION="LegalBot: summarize EU AI Act Article 6"
HOOK="0x0000000000000000000000000000000000000000"  # no hook yet (Week 2 adds reputation hook)
BUDGET="1000000"          # 1 USDC (6 decimals)
DELIVERABLE=$(cast keccak "ipfs://bafkreideliverablesample")

echo "=========================================="
echo "  Stratum — Full Job Lifecycle (Arc Testnet)"
echo "=========================================="
echo "ACP:       $ACP"
echo "Deployer:  $DEPLOYER"
echo "Provider:  $PROVIDER"
echo "Evaluator: $EVALUATOR"
echo "Expiry:    $EXPIRY ($(date -d @$EXPIRY 2>/dev/null || date -r $EXPIRY 2>/dev/null || echo 'N/A'))"
echo "Budget:    $BUDGET (1 USDC)"
echo ""

# ─── Step 1: createJob ───────────────────────────────────────────────
echo ">>> Step 1: createJob"
TX1=$(cast send "$ACP" \
  "createJob(address,address,uint256,string,address)(uint256)" \
  "$PROVIDER" "$EVALUATOR" "$EXPIRY" "$DESCRIPTION" "$HOOK" \
  --rpc-url "$RPC" --account "$ACCOUNT" --from "$DEPLOYER" \
  --json | tee /dev/stderr | jq -r '.transactionHash')
echo "Tx: $TX1"
echo ""

# Extract jobId from logs (JobCreated event, topic[1] = jobId)
sleep 2
JOB_ID_HEX=$(cast receipt "$TX1" --rpc-url "$RPC" --json | jq -r '.logs[0].topics[1]')
JOB_ID=$((16#${JOB_ID_HEX:2}))
echo "✅ Job created! jobId = $JOB_ID (hex: $JOB_ID_HEX)"
echo ""

# ─── Step 2: setBudget (called by provider) ──────────────────────────
echo ">>> Step 2: setBudget($JOB_ID, $BUDGET)"
cast send "$ACP" \
  "setBudget(uint256,uint256,bytes)" \
  "$JOB_ID" "$BUDGET" "0x" \
  --rpc-url "$RPC" --account "$ACCOUNT" --from "$DEPLOYER"
echo "✅ Budget set to $BUDGET"
echo ""

# ─── Step 3: approve USDC + fund ─────────────────────────────────────
echo ">>> Step 3a: approve USDC"
cast send "$USDC" \
  "approve(address,uint256)" \
  "$ACP" "$BUDGET" \
  --rpc-url "$RPC" --account "$ACCOUNT" --from "$DEPLOYER"
echo "✅ USDC approved"
echo ""

echo ">>> Step 3b: fund($JOB_ID)"
cast send "$ACP" \
  "fund(uint256,bytes)" \
  "$JOB_ID" "0x" \
  --rpc-url "$RPC" --account "$ACCOUNT" --from "$DEPLOYER"
echo "✅ Job funded! Status → Funded"
echo ""

# ─── Step 4: submit (called by provider) ─────────────────────────────
echo ">>> Step 4: submit($JOB_ID, deliverable)"
cast send "$ACP" \
  "submit(uint256,bytes32,bytes)" \
  "$JOB_ID" "$DELIVERABLE" "0x" \
  --rpc-url "$RPC" --account "$ACCOUNT" --from "$DEPLOYER"
echo "✅ Work submitted! Status → Submitted"
echo ""

# ─── Step 5: complete (called by evaluator) ──────────────────────────
REASON=$(cast keccak "quality:excellent")
echo ">>> Step 5: complete($JOB_ID, reason)"
cast send "$ACP" \
  "complete(uint256,bytes32,bytes)" \
  "$JOB_ID" "$REASON" "0x" \
  --rpc-url "$RPC" --account "$ACCOUNT" --from "$DEPLOYER"
echo "✅ Job completed! Status → Completed. Escrow released to provider."
echo ""

echo "=========================================="
echo "  🎉 FULL LIFECYCLE COMPLETE"
echo "=========================================="
echo "Job ID:    $JOB_ID"
echo "Create tx: $TX1"
echo "Explorer:  https://testnet.arcscan.app/tx/$TX1"
echo ""
echo "Status transitions: Open → Funded → Submitted → Completed ✓"
echo "Week 1 exit criterion: MET"
