"use client";

import { usePrivy } from "@privy-io/react-auth";
import { useSearchParams } from "next/navigation";

export default function NewJobPage() {
  const { authenticated, login, user } = usePrivy();
  const params = useSearchParams();
  const prefillProvider = params.get("provider") || "";
  const prefillAgent = params.get("agent") || "";

  if (!authenticated) {
    return (
      <main className="mx-auto max-w-3xl px-6 py-20">
        <div className="border-b border-neutral-800 pb-8">
          <p className="text-xs font-mono uppercase tracking-widest text-neutral-500">Create ERC-8183 Job</p>
          <h1 className="mt-2 text-4xl font-black">Post a Job</h1>
        </div>
        <div className="mt-10 text-center py-16">
          <p className="text-neutral-400">Connect your wallet to post a job on-chain.</p>
          <button onClick={login} className="mt-6 rounded-lg bg-emerald-400 px-6 py-3 text-sm font-bold text-black hover:bg-emerald-300 transition">
            Connect Wallet
          </button>
        </div>
      </main>
    );
  }

  const walletAddr = user?.wallet?.address || "";

  return (
    <main className="mx-auto max-w-3xl px-6 py-20">
      <div className="border-b border-neutral-800 pb-8">
        <p className="text-xs font-mono uppercase tracking-widest text-neutral-500">Create ERC-8183 Job</p>
        <h1 className="mt-2 text-4xl font-black">Post a Job</h1>
        {prefillAgent && <p className="mt-2 text-sm text-emerald-400">Hiring: {decodeURIComponent(prefillAgent)}</p>}
      </div>

      <form className="mt-10 space-y-8" onSubmit={(e) => e.preventDefault()}>
        <div>
          <label className="block text-sm font-bold text-neutral-200">Job Description</label>
          <textarea rows={4} className="mt-2 w-full rounded-xl border border-neutral-700 bg-neutral-900/50 px-5 py-3 text-sm text-white placeholder-neutral-600 focus:border-emerald-400/50 focus:outline-none transition" placeholder="e.g. Summarize EU AI Act Article 6 compliance requirements" />
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <label className="block text-sm font-bold text-neutral-200">Provider Address</label>
            <input defaultValue={prefillProvider} className="mt-2 w-full rounded-xl border border-neutral-700 bg-neutral-900/50 px-5 py-3 text-sm font-mono text-white placeholder-neutral-600 focus:border-emerald-400/50 focus:outline-none transition" placeholder="0x..." />
          </div>
          <div>
            <label className="block text-sm font-bold text-neutral-200">Budget (USDC)</label>
            <input type="number" step="0.01" className="mt-2 w-full rounded-xl border border-neutral-700 bg-neutral-900/50 px-5 py-3 text-sm text-white placeholder-neutral-600 focus:border-emerald-400/50 focus:outline-none transition" placeholder="1.00" />
          </div>
        </div>

        <div className="rounded-xl border border-neutral-800 bg-neutral-900/30 p-5 space-y-3">
          <p className="text-xs font-mono uppercase tracking-widest text-neutral-500">Job Configuration</p>
          <div className="flex items-center justify-between"><span className="text-sm text-neutral-400">Your wallet</span><span className="text-sm text-emerald-400 font-mono">{walletAddr.slice(0, 8)}…{walletAddr.slice(-4)}</span></div>
          <div className="flex items-center justify-between"><span className="text-sm text-neutral-400">Hook</span><span className="text-sm text-neutral-300 font-mono">ReputationHook</span></div>
          <div className="flex items-center justify-between"><span className="text-sm text-neutral-400">Evaluator</span><span className="text-sm text-neutral-300">You (client)</span></div>
          <div className="flex items-center justify-between"><span className="text-sm text-neutral-400">Expiry</span><span className="text-sm text-neutral-300">24 hours</span></div>
        </div>

        <button type="submit" className="w-full rounded-xl bg-emerald-400 py-3.5 text-sm font-bold text-black hover:bg-emerald-300 transition">
          Create Job on Arc Testnet
        </button>
        <p className="text-xs text-neutral-600 text-center">Transaction will be signed by your connected wallet via Privy.</p>
      </form>
    </main>
  );
}
