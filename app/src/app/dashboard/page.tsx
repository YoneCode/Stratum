export default function DashboardPage() {
  return (
    <main className="mx-auto max-w-6xl px-6 py-20">
      <div className="border-b border-neutral-800 pb-8">
        <p className="text-xs font-mono uppercase tracking-widest text-neutral-500">Your Account</p>
        <h1 className="mt-2 text-4xl font-black">Dashboard</h1>
      </div>

      <div className="mt-10 grid grid-cols-1 md:grid-cols-2 gap-6">
        <div className="rounded-xl border border-neutral-800 bg-neutral-900/30 p-6">
          <div className="flex items-center gap-2">
            <span className="h-2 w-2 rounded-full bg-yellow-400 animate-pulse" />
            <p className="text-xs font-mono uppercase tracking-widest text-yellow-400">Coming Soon</p>
          </div>
          <h2 className="mt-4 text-xl font-black text-white">USYC Yield</h2>
          <p className="mt-2 text-sm text-neutral-500">Awaiting Circle allowlist. Activates automatically once approved.</p>
          <a href="https://testnet.arcscan.app/address/0x6c238E2440AcCbD8Ab94b63B887506784c0a7be6" target="_blank" rel="noopener noreferrer" className="mt-4 inline-block text-xs font-mono text-neutral-700 hover:text-emerald-400 transition">YieldVault ↗</a>
        </div>

        <div className="rounded-xl border border-neutral-800 bg-neutral-900/30 p-6">
          <p className="text-xs font-mono uppercase tracking-widest text-neutral-500">FX Router</p>
          <h2 className="mt-4 text-xl font-black text-white">EURC → USDC</h2>
          <p className="mt-2 text-sm text-neutral-500">Deposit EURC → StableFX swaps → fund jobs in USDC.</p>
          <a href="https://testnet.arcscan.app/address/0xB73e52b71B5E5edd684E61a50569c6c024726983" target="_blank" rel="noopener noreferrer" className="mt-4 inline-block text-xs font-mono text-neutral-700 hover:text-emerald-400 transition">FXRouter ↗</a>
        </div>

        <div className="rounded-xl border border-neutral-800 bg-neutral-900/30 p-6">
          <p className="text-xs font-mono uppercase tracking-widest text-neutral-500">Your Agents</p>
          <h2 className="mt-4 text-xl font-black text-white">3 Registered</h2>
          <div className="mt-3 space-y-1 text-sm">
            <div className="flex justify-between"><span className="text-neutral-300">LegalBot</span><span className="text-xs font-mono text-neutral-700">#17868</span></div>
            <div className="flex justify-between"><span className="text-neutral-300">FXQuoter</span><span className="text-xs font-mono text-neutral-700">#17896</span></div>
            <div className="flex justify-between"><span className="text-neutral-300">Summarizer</span><span className="text-xs font-mono text-neutral-700">#17897</span></div>
          </div>
        </div>

        <div className="rounded-xl border border-neutral-800 bg-neutral-900/30 p-6">
          <p className="text-xs font-mono uppercase tracking-widest text-neutral-500">Nanopayments</p>
          <h2 className="mt-4 text-xl font-black text-white">x402 Revenue</h2>
          <div className="mt-3 space-y-1 text-xs text-neutral-600">
            <div className="flex justify-between"><span>/summarize</span><span>$0.001/call</span></div>
            <div className="flex justify-between"><span>/fxquote</span><span>$0.0005/call</span></div>
            <div className="flex justify-between"><span>/translate</span><span>$0.002/call</span></div>
          </div>
          <a href="https://testnet.arcscan.app/address/0xd88371e75855B0f3b81BCB6D777fEC8207F7d4Cb" target="_blank" rel="noopener noreferrer" className="mt-4 inline-block text-xs font-mono text-neutral-700 hover:text-emerald-400 transition">Settlement ↗</a>
        </div>
      </div>
    </main>
  );
}
