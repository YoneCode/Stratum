"use client";

export default function NewJobPage() {
  return (
    <main className="mx-auto max-w-3xl px-6 py-20">
      <div className="border-b border-neutral-800 pb-8">
        <p className="text-xs font-mono uppercase tracking-widest text-neutral-500">Create ERC-8183 Job</p>
        <h1 className="mt-2 text-4xl font-black">Post a Job</h1>
        <p className="mt-2 text-sm text-neutral-500">Connect wallet via the header button, then fill in the form below.</p>
      </div>

      <form className="mt-10 space-y-8" onSubmit={(e) => e.preventDefault()}>
        <div>
          <label htmlFor="job-description" className="block text-sm font-bold text-neutral-200">Job Description</label>
          <textarea id="job-description" name="description" rows={4} className="mt-2 w-full rounded-xl border border-neutral-700 bg-neutral-900/50 px-5 py-3 text-sm text-white placeholder-neutral-600 focus:border-emerald-400/50 focus:outline-none transition" placeholder="e.g. Summarize EU AI Act Article 6 compliance requirements" />
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <label htmlFor="provider-address" className="block text-sm font-bold text-neutral-200">Provider Address</label>
            <input id="provider-address" name="provider" className="mt-2 w-full rounded-xl border border-neutral-700 bg-neutral-900/50 px-5 py-3 text-sm font-mono text-white placeholder-neutral-600 focus:border-emerald-400/50 focus:outline-none transition" placeholder="0x..." />
          </div>
          <div>
            <label htmlFor="budget" className="block text-sm font-bold text-neutral-200">Budget (USDC)</label>
            <input id="budget" name="budget" type="number" step="0.01" className="mt-2 w-full rounded-xl border border-neutral-700 bg-neutral-900/50 px-5 py-3 text-sm text-white placeholder-neutral-600 focus:border-emerald-400/50 focus:outline-none transition" placeholder="1.00" />
          </div>
        </div>

        <div className="rounded-xl border border-neutral-800 bg-neutral-900/30 p-5 space-y-3">
          <p className="text-xs font-mono uppercase tracking-widest text-neutral-500">Job Configuration</p>
          <div className="flex items-center justify-between"><span className="text-sm text-neutral-400">Hook</span><span className="text-sm text-emerald-400 font-mono">ReputationHook</span></div>
          <div className="flex items-center justify-between"><span className="text-sm text-neutral-400">Evaluator</span><span className="text-sm text-neutral-300">You (client)</span></div>
          <div className="flex items-center justify-between"><span className="text-sm text-neutral-400">Expiry</span><span className="text-sm text-neutral-300">24 hours</span></div>
          <div className="flex items-center justify-between"><span className="text-sm text-neutral-400">ACP</span><span className="text-sm font-mono text-neutral-600">0x989c…46f</span></div>
        </div>

        <button type="submit" className="w-full rounded-xl bg-emerald-400 py-3.5 text-sm font-bold text-black hover:bg-emerald-300 transition">
          Create Job on Arc Testnet
        </button>
      </form>
    </main>
  );
}
