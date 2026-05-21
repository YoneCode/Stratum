import Link from "next/link";
import { createPublicClient, http } from "viem";
import { arcTestnet } from "@/lib/chain";
import { contracts } from "@/lib/contracts";

const client = createPublicClient({ chain: arcTestnet, transport: http() });

const acpAbi = [
  { name: "jobCounter", type: "function", stateMutability: "view", inputs: [], outputs: [{ name: "", type: "uint256" }] },
  { name: "getJob", type: "function", stateMutability: "view", inputs: [{ name: "jobId", type: "uint256" }], outputs: [{ name: "", type: "tuple", components: [{ name: "id", type: "uint256" }, { name: "client", type: "address" }, { name: "provider", type: "address" }, { name: "evaluator", type: "address" }, { name: "description", type: "string" }, { name: "budget", type: "uint256" }, { name: "expiredAt", type: "uint256" }, { name: "status", type: "uint8" }, { name: "hook", type: "address" }] }] },
] as const;

const STATUS = ["Open", "Funded", "Submitted", "Completed", "Rejected", "Expired"];
const STATUS_COLOR: Record<string, string> = { Open: "text-yellow-400 bg-yellow-400/10", Funded: "text-blue-400 bg-blue-400/10", Submitted: "text-purple-400 bg-purple-400/10", Completed: "text-emerald-400 bg-emerald-400/10", Rejected: "text-red-400 bg-red-400/10", Expired: "text-neutral-500 bg-neutral-800" };

export default async function JobsPage() {
  const acp = contracts.stratumAcp as `0x${string}`;
  let totalJobs = 0n;
  try { totalJobs = await client.readContract({ address: acp, abi: acpAbi, functionName: "jobCounter" }); } catch {}
  const count = Number(totalJobs);
  const jobIds = Array.from({ length: Math.min(count, 10) }, (_, i) => count - i);
  const jobs = (await Promise.all(jobIds.map(async (id) => { try { return await client.readContract({ address: acp, abi: acpAbi, functionName: "getJob", args: [BigInt(id)] }); } catch { return null; } }))).filter(Boolean);

  return (
    <main className="mx-auto max-w-6xl px-6 py-20">
      <div className="flex items-end justify-between border-b border-neutral-800 pb-8">
        <div>
          <p className="text-xs font-mono uppercase tracking-widest text-neutral-500">ERC-8183 Agentic Commerce</p>
          <h1 className="mt-2 text-4xl font-black">Job Board</h1>
          <p className="mt-2 text-neutral-500 text-sm">{count} jobs created · Stratum ACP</p>
        </div>
        <Link href="/jobs/new" className="rounded-lg bg-emerald-400 px-5 py-2.5 text-sm font-bold text-black hover:bg-emerald-300 transition">
          Post Job →
        </Link>
      </div>

      <div className="mt-10 space-y-3">
        {jobs.map((job) => {
          if (!job) return null;
          const status = STATUS[job.status] || "Unknown";
          const colorClass = STATUS_COLOR[status] || "";
          return (
            <a key={Number(job.id)} href={`https://testnet.arcscan.app/address/${acp}`} target="_blank" rel="noopener noreferrer" className="flex items-center justify-between rounded-xl border border-neutral-800 bg-neutral-900/30 px-6 py-4 hover:border-emerald-400/30 transition-colors group">
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-3">
                  <span className="text-xs font-mono text-neutral-700">#{Number(job.id)}</span>
                  <h3 className="text-sm font-semibold text-white truncate group-hover:text-emerald-400 transition-colors">{job.description || "Untitled job"}</h3>
                </div>
                <div className="mt-1 flex gap-4 text-xs text-neutral-600">
                  <span>{Number(job.budget) / 1e6} USDC</span>
                  <span>Client: {job.client.slice(0, 6)}…{job.client.slice(-4)}</span>
                </div>
              </div>
              <span className={`rounded-full px-3 py-1 text-xs font-medium ${colorClass}`}>{status}</span>
            </a>
          );
        })}
        {jobs.length === 0 && <p className="text-neutral-600 text-sm">No jobs yet. Be the first to post one.</p>}
      </div>
    </main>
  );
}
