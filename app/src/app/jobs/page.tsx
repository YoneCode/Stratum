import Link from "next/link";
import { createPublicClient, http, parseAbiItem } from "viem";
import { arcTestnet } from "@/lib/chain";
import { contracts } from "@/lib/contracts";

const client = createPublicClient({
  chain: arcTestnet,
  transport: http(),
});

const getJobAbi = [
  {
    name: "getJob",
    type: "function",
    stateMutability: "view",
    inputs: [{ name: "jobId", type: "uint256" }],
    outputs: [
      {
        name: "",
        type: "tuple",
        components: [
          { name: "id", type: "uint256" },
          { name: "client", type: "address" },
          { name: "provider", type: "address" },
          { name: "evaluator", type: "address" },
          { name: "description", type: "string" },
          { name: "budget", type: "uint256" },
          { name: "expiredAt", type: "uint256" },
          { name: "status", type: "uint8" },
          { name: "hook", type: "address" },
        ],
      },
    ],
  },
  {
    name: "jobCounter",
    type: "function",
    stateMutability: "view",
    inputs: [],
    outputs: [{ name: "", type: "uint256" }],
  },
] as const;

const STATUS_LABELS = ["Open", "Funded", "Submitted", "Completed", "Rejected", "Expired"];
const STATUS_COLORS: Record<string, string> = {
  Open: "text-yellow-400",
  Funded: "text-blue-400",
  Submitted: "text-purple-400",
  Completed: "text-green-400",
  Rejected: "text-red-400",
  Expired: "text-neutral-500",
};

export default async function JobsPage() {
  const acp = contracts.stratumAcp as `0x${string}`;

  let totalJobs = 0n;
  try {
    totalJobs = await client.readContract({ address: acp, abi: getJobAbi, functionName: "jobCounter" });
  } catch {}

  const jobIds = [];
  const count = Number(totalJobs);
  for (let i = count; i >= Math.max(1, count - 9); i--) {
    jobIds.push(i);
  }

  const jobs = await Promise.all(
    jobIds.map(async (id) => {
      try {
        const job = await client.readContract({ address: acp, abi: getJobAbi, functionName: "getJob", args: [BigInt(id)] });
        return job;
      } catch { return null; }
    })
  );

  return (
    <main className="mx-auto max-w-4xl px-6 py-16">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">Job Board</h1>
          <p className="mt-2 text-neutral-400">
            ERC-8183 jobs on Stratum ACP • {count} total
          </p>
        </div>
        <Link
          href="/jobs/new"
          className="rounded-lg bg-white px-4 py-2 text-sm font-medium text-black transition hover:bg-neutral-200"
        >
          Post Job
        </Link>
      </div>

      <div className="mt-8 space-y-4">
        {jobs.filter(Boolean).map((job) => {
          if (!job) return null;
          const status = STATUS_LABELS[job.status] || "Unknown";
          return (
            <div
              key={Number(job.id)}
              className="rounded-lg border border-neutral-800 bg-neutral-900 p-6"
            >
              <div className="flex items-start justify-between">
                <div className="flex-1">
                  <h2 className="font-medium">{job.description || `Job #${Number(job.id)}`}</h2>
                  <div className="mt-2 flex gap-4 text-xs text-neutral-500">
                    <span>Budget: {Number(job.budget) / 1e6} USDC</span>
                    <span>Client: {job.client.slice(0, 6)}…{job.client.slice(-4)}</span>
                  </div>
                </div>
                <span className={`text-sm font-medium ${STATUS_COLORS[status] || ""}`}>
                  {status}
                </span>
              </div>
            </div>
          );
        })}
      </div>
    </main>
  );
}
