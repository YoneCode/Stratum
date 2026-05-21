"use client";

import { usePrivy } from "@privy-io/react-auth";

export default function DashboardPage() {
  const { authenticated, user } = usePrivy();
  const address = user?.wallet?.address;

  if (!authenticated) {
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
        <h2 className="text-xl font-semibold">Your Yield</h2>
        <div className="mt-4 rounded-lg border border-neutral-800 bg-neutral-900/50 p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-neutral-400">USYC Balance (YieldVault)</p>
              <p className="mt-1 text-2xl font-bold text-emerald-400">Coming Soon</p>
              <p className="mt-1 text-xs text-neutral-500">Awaiting Circle USYC allowlist approval. Once approved, deposit USDC → earn T-bill yield automatically.</p>
            </div>
            <div className="text-right">
              <p className="text-xs text-neutral-500">Vault</p>
              <a href="https://testnet.arcscan.app/address/0x6c238E2440AcCbD8Ab94b63B887506784c0a7be6" target="_blank" rel="noopener noreferrer" className="text-xs font-mono text-neutral-600 hover:text-emerald-400">
                0x6c23…7be6
              </a>
            </div>
          </div>
        </div>
      </section>

      <section className="mt-10">
        <h2 className="text-xl font-semibold">Your Jobs</h2>
        <p className="mt-2 text-sm text-neutral-500">Jobs where you are client or provider will appear here once you post or accept a job.</p>
      </section>
    </main>
  );
}
