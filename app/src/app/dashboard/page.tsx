export default function DashboardPage() {
  return (
    <main className="mx-auto max-w-4xl px-6 py-16">
      <h1 className="text-3xl font-bold">Dashboard</h1>

      <section className="mt-10">
        <h2 className="text-xl font-semibold">Yield (USYC)</h2>
        <div className="mt-4 rounded-lg border border-neutral-800 bg-neutral-900/50 p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-2xl font-bold text-emerald-400">Coming Soon</p>
              <p className="mt-2 text-sm text-neutral-400">
                Awaiting Circle USYC allowlist approval. Once approved, the YieldVault
                activates automatically — deposit USDC, earn T-bill yield, one-click redeem to fund jobs.
              </p>
            </div>
            <div className="text-right">
              <p className="text-xs text-neutral-500">YieldVault</p>
              <a href="https://testnet.arcscan.app/address/0x6c238E2440AcCbD8Ab94b63B887506784c0a7be6" target="_blank" rel="noopener noreferrer" className="text-xs font-mono text-neutral-600 hover:text-emerald-400">
                0x6c23…7be6
              </a>
            </div>
          </div>
        </div>
      </section>

      <section className="mt-10">
        <h2 className="text-xl font-semibold">Your Jobs</h2>
        <p className="mt-2 text-sm text-neutral-500">
          Connect wallet via{" "}
          <a href="https://privy.io" target="_blank" rel="noopener noreferrer" className="text-emerald-400 hover:underline">Privy</a>
          {" "}to view your jobs. Wallet integration loading separately to avoid extension conflicts.
        </p>
      </section>
    </main>
  );
}
