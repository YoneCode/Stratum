export default function DashboardPage() {
  return (
    <main className="mx-auto max-w-6xl px-6 py-20">
      <div className="border-b border-neutral-800 pb-8">
        <p className="text-xs font-mono uppercase tracking-widest text-neutral-500">Your Account</p>
        <h1 className="mt-2 text-4xl font-black">Dashboard</h1>
      </div>

      <div className="mt-10 grid grid-cols-1 md:grid-cols-2 gap-6">
        {/* Yield */}
        <div className="rounded-xl border border-neutral-800 bg-neutral-900/30 p-6">
          <div className="flex items-center gap-2">
            <span className="h-2 w-2 rounded-full bg-yellow-400 animate-pulse" />
            <p className="text-xs font-mono uppercase tracking-widest text-yellow-400">Coming Soon</p>
          </div>
          <h2 className="mt-4 text-xl font-black text-white">USYC Yield</h2>
          <p className="mt-2 text-sm text-neutral-500 leading-relaxed">
            Awaiting Circle USYC allowlist approval. Once approved, the YieldVault
            activates automatically — no code changes needed.
          </p>
          <div className="mt-4 space-y-2 text-xs text-neutral-600">
            <div className="flex justify-between"><span>Deposit</span><span>USDC → USYC (T-bill yield)</span></div>
            <div className="flex justify-between"><span>Redeem</span><span>USYC → USDC (instant)</span></div>
            <div className="flex justify-between"><span>Fund Job</span><span>redeemAndApprove (one-click)</span></div>
          </div>
          <a href="https://testnet.arcscan.app/address/0x6c238E2440AcCbD8Ab94b63B887506784c0a7be6" target="_blank" rel="noopener noreferrer" className="mt-4 inline-block text-xs font-mono text-neutral-700 hover:text-emerald-400 transition">
            YieldVault: 0x6c23…7be6 ↗
          </a>
        </div>

        {/* FX */}
        <div className="rounded-xl border border-neutral-800 bg-neutral-900/30 p-6">
          <p className="text-xs font-mono uppercase tracking-widest text-neutral-500">FX Router</p>
          <h2 className="mt-4 text-xl font-black text-white">EURC → USDC</h2>
          <p className="mt-2 text-sm text-neutral-500 leading-relaxed">
            EU clients deposit EURC. StableFX API swaps to USDC via RFQ.
            Settled balance available for job funding.
          </p>
          <div className="mt-4 space-y-2 text-xs text-neutral-600">
            <div className="flex justify-between"><span>Deposit</span><span>EURC → SwapRequested event</span></div>
            <div className="flex justify-between"><span>Relayer</span><span>Fills via StableFX API</span></div>
            <div className="flex justify-between"><span>Withdraw</span><span>USDC to wallet or ACP</span></div>
          </div>
          <a href="https://testnet.arcscan.app/address/0xB73e52b71B5E5edd684E61a50569c6c024726983" target="_blank" rel="noopener noreferrer" className="mt-4 inline-block text-xs font-mono text-neutral-700 hover:text-emerald-400 transition">
            FXRouter: 0xB73e…6983 ↗
          </a>
        </div>

        {/* Agents */}
        <div className="rounded-xl border border-neutral-800 bg-neutral-900/30 p-6">
          <p className="text-xs font-mono uppercase tracking-widest text-neutral-500">Your Agents</p>
          <h2 className="mt-4 text-xl font-black text-white">3 Registered</h2>
          <div className="mt-4 space-y-2">
            {[
              { name: "LegalBot v1.0", id: 17868 },
              { name: "FXQuoter v1.0", id: 17896 },
              { name: "Summarizer v1.0", id: 17897 },
            ].map((a) => (
              <div key={a.id} className="flex items-center justify-between text-sm">
                <span className="text-neutral-300">{a.name}</span>
                <span className="text-xs font-mono text-neutral-700">#{a.id}</span>
              </div>
            ))}
          </div>
        </div>

        {/* x402 */}
        <div className="rounded-xl border border-neutral-800 bg-neutral-900/30 p-6">
          <p className="text-xs font-mono uppercase tracking-widest text-neutral-500">Nanopayments</p>
          <h2 className="mt-4 text-xl font-black text-white">x402 Revenue</h2>
          <p className="mt-2 text-sm text-neutral-500">
            Per-call micropayments from API consumers. Batch-settled to NanopaymentSettlement contract.
          </p>
          <div className="mt-4 space-y-2 text-xs text-neutral-600">
            <div className="flex justify-between"><span>/summarize</span><span>$0.001/call</span></div>
            <div className="flex justify-between"><span>/fxquote</span><span>$0.0005/call</span></div>
            <div className="flex justify-between"><span>/translate</span><span>$0.002/call</span></div>
          </div>
          <a href="https://testnet.arcscan.app/address/0xd88371e75855B0f3b81BCB6D777fEC8207F7d4Cb" target="_blank" rel="noopener noreferrer" className="mt-4 inline-block text-xs font-mono text-neutral-700 hover:text-emerald-400 transition">
            Settlement: 0xd883…d4Cb ↗
          </a>
        </div>
      </div>
    </main>
  );
}
