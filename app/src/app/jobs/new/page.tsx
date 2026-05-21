export default function NewJobPage() {
  return (
    <main className="mx-auto max-w-2xl px-6 py-16">
      <h1 className="text-3xl font-bold">Post a Job</h1>
      <p className="mt-2 text-neutral-400">Create an ERC-8183 escrowed job on Stratum ACP</p>

      <div className="mt-8 space-y-6">
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
            Provider address <span className="text-neutral-500">(optional)</span>
          </label>
          <input
            className="mt-1 w-full rounded-lg border border-neutral-700 bg-neutral-900 px-4 py-2 text-sm font-mono"
            placeholder="0x..."
          />
        </div>

        <div className="text-xs text-neutral-500">
          Hook: ReputationHook • Expiry: 24h • Wallet connection required to submit
        </div>

        <button
          disabled
          className="rounded-lg bg-white px-6 py-2.5 text-sm font-medium text-black opacity-50 cursor-not-allowed"
        >
          Connect Wallet to Create Job
        </button>
      </div>
    </main>
  );
}
