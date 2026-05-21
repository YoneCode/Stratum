// Agent worker — polls Stratum ACP for new Funded jobs, auto-submits a deliverable.
// This is the "LegalBot" demo worker for Week 2.
//
// Usage: node --env-file=../.env src/worker.js
// Requires DEPLOYER_PRIVATE_KEY in .env (or run from a machine with keystore access).

import { createPublicClient, createWalletClient, http, parseAbi, keccak256, toHex } from "viem";
import { privateKeyToAccount } from "viem/accounts";

// --- Config ---
const RPC_URL = process.env.ARC_TESTNET_RPC_URL || "https://rpc.testnet.arc.network";
const PRIVATE_KEY = process.env.DEPLOYER_PRIVATE_KEY;
const ACP_ADDRESS = "0x989c0f21c712EecF8bD7AB1caf1A8Ba3da88a46f";
const POLL_INTERVAL_MS = 10_000; // 10s

if (!PRIVATE_KEY) {
  console.error("ERROR: DEPLOYER_PRIVATE_KEY not set in environment.");
  process.exit(1);
}

const account = privateKeyToAccount(PRIVATE_KEY);
const chain = {
  id: 5_042_002,
  name: "Arc Testnet",
  nativeCurrency: { name: "USDC", symbol: "USDC", decimals: 6 },
  rpcUrls: { default: { http: [RPC_URL] } },
};

const publicClient = createPublicClient({ chain, transport: http(RPC_URL) });
const walletClient = createWalletClient({ account, chain, transport: http(RPC_URL) });

const acpAbi = parseAbi([
  "function jobCounter() view returns (uint256)",
  "function getJob(uint256 jobId) view returns ((uint256 id, address client, address provider, address evaluator, string description, uint256 budget, uint256 expiredAt, uint8 status, address hook))",
  "function submit(uint256 jobId, bytes32 deliverable, bytes optParams)",
]);

// Track which jobs we've already submitted to
const submitted = new Set();
let lastKnownCounter = 0n;

async function poll() {
  try {
    const counter = await publicClient.readContract({
      address: ACP_ADDRESS,
      abi: acpAbi,
      functionName: "jobCounter",
    });

    if (counter <= lastKnownCounter) return;

    // Check new jobs
    for (let i = lastKnownCounter + 1n; i <= counter; i++) {
      const jobId = Number(i);
      if (submitted.has(jobId)) continue;

      const job = await publicClient.readContract({
        address: ACP_ADDRESS,
        abi: acpAbi,
        functionName: "getJob",
        args: [i],
      });

      // Only submit if:
      // 1. Job is Funded (status == 1)
      // 2. We are the provider
      if (job.status !== 1) continue;
      if (job.provider.toLowerCase() !== account.address.toLowerCase()) continue;

      console.log(`[Worker] Job #${jobId} is Funded and assigned to us. Submitting...`);
      console.log(`  Description: ${job.description}`);
      console.log(`  Budget: ${Number(job.budget) / 1e6} USDC`);

      // Generate a mock deliverable hash
      const deliverable = keccak256(toHex(`stratum-worker-deliverable-job-${jobId}-${Date.now()}`));

      const hash = await walletClient.writeContract({
        address: ACP_ADDRESS,
        abi: acpAbi,
        functionName: "submit",
        args: [i, deliverable, "0x"],
      });

      console.log(`[Worker] ✅ Submitted! Tx: ${hash}`);
      submitted.add(jobId);
    }

    lastKnownCounter = counter;
  } catch (err) {
    console.error("[Worker] Poll error:", err.message || err);
  }
}

// --- Main loop ---
console.log(`[Worker] LegalBot agent worker started`);
console.log(`[Worker] Address: ${account.address}`);
console.log(`[Worker] ACP: ${ACP_ADDRESS}`);
console.log(`[Worker] Polling every ${POLL_INTERVAL_MS / 1000}s...`);
console.log("");

// Initial poll
await poll();

// Continuous polling
setInterval(poll, POLL_INTERVAL_MS);
