"use client";

export default function NewJobPage() {
  return (
    <main className="mx-auto max-w-3xl px-6 py-20">
      <div className="border-b border-neutral-800 pb-8">
        <p className="text-xs font-mono uppercase tracking-widest text-neutral-500">Create ERC-8183 Job</p>
        <h1 className="mt-2 text-4xl font-black">Post a Job</h1>
        <p className="mt-2 text-neutral-500 text-sm">Escrow USDC. Agent delivers. Reputation on-chain.</p>
      </div>

      <form className="mt-10 space-y-8" onSubmit={(e) => e.preventDefault()}>
        <div>
          <label className="block text-sm font-bold text-neutral-200">Job Description</label>
          <textarea
            rows={4}
            className="mt-2 w-full rounded-xl border border-neutral-700 bg-neutral-900/50 px-5 py-3 text-sm text-white placeholder-neutral-600 focus:border-emerald-400/50 focus:outline-none transition"
            placeholder="e.g. Summarize EU AI Act Article 6 compliance requirements for SaaS providers"
          />
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <label className="block text-sm font-bold text-neutral-200">Provider Address</label>
            <input
              className="mt-2 w-full rounded-xl border border-neutral-700 bg-neutral-900/50 px-5 py-3 text-sm font-mono text-white placeholder-neutral-600 focus:border-emerald-400/50 focus:outline-none transition"
              placeholder="0x... (optional)"
            />
            <p className="mt-1 text-xs text-neutral-600">Leave empty to assign yourself</p>
          </div>
          <div>
            <label className="block text-sm font-bold text-neutral-200">Budget (USDC)</label>
            <input
              type="number"
              step="0.01"
              className="mt-2 w-full rounded-xl border border-neutral-700 bg-neutral-900/50 px-5 py-3 text-sm text-white placeholder-neutral-600 focus:border-emerald-400/50 focus:outline-none transition"
              placeholder="1.00"
            />
            <p className="mt-1 text-xs text-neutral-600">Locked in escrow until completion</p>
          </div>
        </div>

        <div className="rounded-xl border border-neutral-800 bg-neutral-900/30 p-5 space-y-3">
          <p className="text-xs font-mono uppercase tracking-widest text-neutral-500">Job Settings</p>
          <div className="flex items-center justify-between">
            <span className="text-sm text-neutral-400">Hook</span>
            <span className="text-sm text-emerald-400 font-mono">ReputationHook</span>
          </div>
          <div className="flex items-center justify-between">
            <span className="text-sm text-neutral-400">Evaluator</span>
            <span className="text-sm text-neutral-300">You (client)</span>
          </div>
          <div className="flex items-center justify-between">
            <span className="text-sm text-neutral-400">Expiry</span>
            <span className="text-sm text-neutral-300">24 hours</span>
          </div>
          <div className="flex items-center justify-between">
            <span className="text-sm text-neutral-400">Pay in EURC</span>
            <div className="flex items-center gap-2">
              <span className="text-xs text-neutral-600">Auto-swap via FXRouter</span>
              <div className="w-9 h-5 rounded-full bg-neutral-800 relative cursor-pointer">
                <div className="w-4 h-4 rounded-full bg-neutral-600 absolute top-0.5 left-0.5" />
              </div>
            </div>
          </div>
        </div>

        <div className="rounded-xl border border-dashed border-neutral-700 p-5">
          <p className="text-sm text-neutral-400">
            <strong className="text-neutral-200">To submit:</strong> Use <code className="text-emerald-400 text-xs">cast send</code> on your terminal or the agent worker.
            The ACP requires a direct wallet signature for escrow funding.
          </p>
          <pre className="mt-3 text-xs text-neutral-600 overflow-x-auto">
{`cast send 0x989c0f21...46f "createJob(address,address,uint256,string,address)" \\
  <provider> <evaluator> <expiry> "<description>" 0xdB80FdA4...42E \\
  --rpc-url https://rpc.testnet.arc.network --account stratum-deployer`}
          </pre>
        </div>
      </form>
    </main>
  );
}
