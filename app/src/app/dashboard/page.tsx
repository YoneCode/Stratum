"use client";

import { useAccount } from "wagmi";
import { useReadContract, useReadContracts } from "wagmi";
import { parseAbi } from "viem";
import { contracts } from "@/lib/contracts";

const acpAbi = parseAbi([
  "function jobCounter() view returns (uint256)",
  "function getJob(uint256 jobId) view returns ((uint256 id, address client, address provider, address evaluator, string description, uint256 budget, uint256 expiredAt, uint8 status, address hook))",
]);

const STATUS_LABELS = ["Open", "Funded", "Submitted", "Completed", "Rejected", "Expired"];

export default function DashboardPage() {
  const { address, isConnected } = useAccount();
  const acp = contracts.stratumAcp as `0x${string}`;

  const { data: counter } = useReadContract({
    address: acp,
    abi: acpAbi,
    functionName: "jobCounter",
  });

  const jobCount = Number(counter || 0n);
  const jobIds = Array.from({ length: Math.min(jobCount, 20) }, (_, i) => jobCount - i);

  const { data: jobResults } = useReadContracts({
    contracts: jobIds.map((id) => ({
      address: acp,
      abi: acpAbi,
      functionName: "getJob" as const,
      args: [BigInt(id)],
    })),
  });

  const myJobs = (jobResults || [])
    .map((r) => r.result)
    .filter((job): job is NonNullable<typeof job> => {
      if (!job || !address) return false;
      const addr = address.toLowerCase();
      return (
        job.client.toLowerCase() === addr ||
        job.provider.toLowerCase() === addr
      );
    });

  if (!isConnected) {
    return (
      <main className="mx-auto max-w-4xl px-6 py-16">
        <h1 className="text-3xl font-bold">Dashboard</h1>
        <p className="mt-4 text-neutral-400">Connect your wallet to view your jobs and agents.</p>
      </main>
    );
  }

  return (
    <main className="mx-auto max-w-4xl px-6 py-16">
      <h1 className="text-3xl font-bold">Dashboard</h1>
      <p className="mt-2 text-sm text-neutral-500 font-mono">{address}</p>

      <section className="mt-10">
        <h2 className="text-xl font-semibold">Your Jobs ({myJobs.length})</h2>
        <div className="mt-4 space-y-3">
          {myJobs.length === 0 && (
            <p className="text-neutral-500 text-sm">No jobs found for this wallet.</p>
          )}
          {myJobs.map((job) => (
            <div key={Number(job.id)} className="rounded-lg border border-neutral-800 bg-neutral-900 p-4">
              <div className="flex justify-between items-center">
                <span className="text-sm">{job.description || `Job #${Number(job.id)}`}</span>
                <span className="text-xs text-neutral-400">{STATUS_LABELS[job.status]}</span>
              </div>
              <div className="mt-1 text-xs text-neutral-500">
                Budget: {Number(job.budget) / 1e6} USDC
              </div>
            </div>
          ))}
        </div>
      </section>
    </main>
  );
}
