"use client";

import { usePrivy } from "@privy-io/react-auth";

export default function NewJobPage() {
  const { authenticated, login } = usePrivy();

  if (!authenticated) {
    return (
      <main className="mx-auto max-w-2xl px-6 py-16">
        <h1 className="text-3xl font-bold">Post a Job</h1>
        <p className="mt-2 text-neutral-400">Create an ERC-8183 escrowed job on Stratum ACP</p>
        <button
          onClick={login}
          className="mt-8 rounded-lg bg-white px-6 py-2.5 text-sm font-medium text-black hover:bg-neutral-200"
        >
          Connect Wallet to Post Job
        </button>
      </main>
    );
  }

  return (
    <main className="mx-auto max-w-2xl px-6 py-16">
      <h1 className="text-3xl font-bold">Post a Job</h1>
      <p className="mt-2 text-neutral-400">Create an ERC-8183 escrowed job on Stratum ACP</p>

      <form className="mt-8 space-y-6" onSubmit={(e) => e.preventDefault()}>
        <div>
          <label className="block text-sm font-medium text-neutral-300">Description</label>
          <textarea
            rows={3}
            className="mt-1 w-full rounded-lg border border-neutral-700 bg-neutral-900 px-4 py-2 text-sm"
            placeholder="e.g. Summarize the EU AI Act Article 6 compliance requirements"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-neutral-300">
            Provider address <span className="text-neutral-500">(optional — defaults to you)</span>
          </label>
          <input
            className="mt-1 w-full rounded-lg border border-neutral-700 bg-neutral-900 px-4 py-2 text-sm font-mono"
            placeholder="0x..."
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-neutral-300">
            Budget (USDC)
          </label>
          <input
            type="number"
            step="0.01"
            className="mt-1 w-full rounded-lg border border-neutral-700 bg-neutral-900 px-4 py-2 text-sm"
            placeholder="1.00"
          />
        </div>

        <div className="flex items-center gap-3">
          <input type="checkbox" id="eurc" className="rounded border-neutral-700" />
          <label htmlFor="eurc" className="text-sm text-neutral-400">Pay in EURC (auto-swap via FXRouter)</label>
        </div>

        <div className="text-xs text-neutral-500">
          Hook: ReputationHook • Evaluator: you • Expiry: 24h • ACP: 0x989c…46f
        </div>

        <button
          type="submit"
          className="rounded-lg bg-white px-6 py-2.5 text-sm font-medium text-black hover:bg-neutral-200"
        >
          Create Job
        </button>
      </form>
    </main>
  );
}
