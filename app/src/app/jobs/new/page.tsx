"use client";

export default function NewJobPage() {
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
          <label className="block text-sm font-medium text-neutral-300">Budget (USDC)</label>
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

        <p className="text-xs text-neutral-500 border border-neutral-800 rounded-lg p-3">
          <strong className="text-neutral-300">How to submit:</strong> Use the{" "}
          <code className="text-emerald-400">cast send</code> command or the agent worker.
          The ACP contract requires a direct wallet signature — form submission coming with wallet SDK integration.
        </p>
      </form>
    </main>
  );
}
