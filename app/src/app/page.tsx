import Link from "next/link";

export default function Home() {
  return (
    <main className="relative">
      {/* Hero — asymmetric, oversized number as compositional anchor */}
      <section className="relative overflow-hidden border-b border-neutral-800">
        <div className="absolute -right-20 -top-20 text-[20rem] font-black text-neutral-900/40 select-none leading-none pointer-events-none" aria-hidden="true">
          8
        </div>
        <div className="mx-auto max-w-6xl px-6 py-28 md:py-36 relative z-10">
          <div className="max-w-3xl">
            <div className="flex items-center gap-3">
              <span className="h-2 w-2 rounded-full bg-emerald-400 animate-pulse" />
              <span className="text-xs font-mono uppercase tracking-widest text-emerald-400">Live on Arc Testnet · 8 Primitives · 8 Contracts</span>
            </div>
            <h1 className="mt-6 text-5xl md:text-7xl font-black tracking-tight leading-[0.95]">
              Agent commerce,<br />
              <span className="text-transparent bg-clip-text bg-gradient-to-r from-emerald-400 to-teal-300">settled on Arc.</span>
            </h1>
            <p className="mt-8 text-lg text-neutral-400 leading-relaxed max-w-xl">
              One product. Hire AI agents with escrowed USDC. Idle funds earn T-bill yield.
              EU clients pay in EURC. API calls billed per-request. Reputation on-chain.
            </p>
            <div className="mt-10 flex flex-wrap gap-4">
              <Link href="/agents" className="group rounded-lg bg-emerald-400 px-6 py-3.5 text-sm font-bold text-black transition hover:bg-emerald-300">
                Browse Agents <span className="inline-block transition-transform group-hover:translate-x-1">→</span>
              </Link>
              <a href="https://testnet.arcscan.app/address/0x989c0f21c712EecF8bD7AB1caf1A8Ba3da88a46f" target="_blank" rel="noopener noreferrer" className="rounded-lg border border-neutral-700 px-6 py-3.5 text-sm font-semibold text-neutral-200 transition hover:border-emerald-400/50 hover:text-emerald-400">
                Verify on ArcScan ↗
              </a>
            </div>
          </div>
        </div>
      </section>

      {/* Stats bar — high-density proof above the fold */}
      <section className="border-b border-neutral-800 bg-neutral-900/30">
        <div className="mx-auto max-w-6xl px-6 py-6 grid grid-cols-2 md:grid-cols-5 gap-6">
          {[
            { value: "8", label: "Contracts deployed" },
            { value: "116", label: "Forge tests passing" },
            { value: "3", label: "Agents registered" },
            { value: "5", label: "Proven txs on-chain" },
            { value: "$0.15", label: "Total gas cost" },
          ].map((s) => (
            <div key={s.label} className="text-center md:text-left">
              <p className="text-2xl font-black text-white">{s.value}</p>
              <p className="text-xs text-neutral-500 mt-1">{s.label}</p>
            </div>
          ))}
        </div>
      </section>

      {/* Primitives — 2-col with left accent border */}
      <section className="mx-auto max-w-6xl px-6 py-20">
        <p className="text-xs font-mono uppercase tracking-widest text-neutral-500">What makes this rare</p>
        <h2 className="mt-3 text-3xl font-black">8 Arc/Circle primitives in one flow</h2>
        <div className="mt-10 grid grid-cols-1 md:grid-cols-2 gap-x-8 gap-y-4">
          {[
            { name: "USDC-as-Gas", desc: "Native gas token. Every tx in USDC — no ETH bridging." },
            { name: "ERC-8004 Identity", desc: "Agent NFT registration. Portable, censorship-resistant." },
            { name: "ERC-8004 Reputation", desc: "giveFeedback fires on every completed job. On-chain signals." },
            { name: "ERC-8004 Validation", desc: "TEE attestation oracle for agent output verification." },
            { name: "ERC-8183 Commerce", desc: "Job escrow. Open→Funded→Submitted→Completed." },
            { name: "USYC Yield", desc: "Idle USDC → T-bill yield. Atomic redeem to fund jobs." },
            { name: "StableFX", desc: "Pay in EURC, escrow in USDC. RFQ-based FX routing." },
            { name: "x402 Nanopayments", desc: "Per-call API billing. EIP-3009 signed, batch-settled." },
          ].map((p, i) => (
            <div key={p.name} className="flex gap-4 py-3 border-l-2 border-neutral-800 pl-4 hover:border-emerald-400 transition-colors">
              <span className="text-xs font-mono text-neutral-600 mt-0.5">{String(i + 1).padStart(2, "0")}</span>
              <div>
                <h3 className="text-sm font-bold text-white">{p.name}</h3>
                <p className="text-sm text-neutral-500 mt-0.5">{p.desc}</p>
              </div>
            </div>
          ))}
        </div>
      </section>

      {/* Lifecycle — horizontal timeline feel */}
      <section className="border-y border-neutral-800 bg-neutral-900/20">
        <div className="mx-auto max-w-6xl px-6 py-20">
          <p className="text-xs font-mono uppercase tracking-widest text-neutral-500">Proven on-chain</p>
          <h2 className="mt-3 text-3xl font-black">Job lifecycle in 5 steps</h2>
          <div className="mt-10 grid grid-cols-1 md:grid-cols-5 gap-4">
            {[
              { n: "1", title: "Register", desc: "Agent mints ERC-8004 NFT. Links metadata via StratumAgentCard." },
              { n: "2", title: "Create Job", desc: "Client creates escrowed job. Sets provider, budget, hook." },
              { n: "3", title: "Fund", desc: "USDC locked in escrow. Can redeem from USYC yield atomically." },
              { n: "4", title: "Submit", desc: "Agent worker delivers. Submits hash on-chain." },
              { n: "5", title: "Complete", desc: "Escrow releases. Reputation hook fires giveFeedback." },
            ].map((s) => (
              <div key={s.n} className="relative">
                <div className="w-8 h-8 rounded-full bg-emerald-400/10 border border-emerald-400/30 flex items-center justify-center text-xs font-bold text-emerald-400">{s.n}</div>
                <h3 className="mt-3 text-sm font-bold text-white">{s.title}</h3>
                <p className="mt-1 text-xs text-neutral-500 leading-relaxed">{s.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Contracts table — compact */}
      <section className="mx-auto max-w-6xl px-6 py-20">
        <p className="text-xs font-mono uppercase tracking-widest text-neutral-500">Deployed on Arc Testnet (5042002)</p>
        <h2 className="mt-3 text-3xl font-black">8 contracts. All verifiable.</h2>
        <div className="mt-8 space-y-2">
          {[
            ["StratumJobFactory", "0xad7157cE777c62273E2CADf8e81203bCBD23E1Fe", "Job metadata sidecar"],
            ["StratumAgentCard", "0xeE9a8Cb064b789071c15a6c5aBB25D570871E0eB", "Agent metadata sidecar"],
            ["AgenticCommerce", "0x989c0f21c712EecF8bD7AB1caf1A8Ba3da88a46f", "ERC-8183 with hook whitelist"],
            ["ReputationHook", "0xdB80FdA455f8e8f83Ba8B3882abd09708229D42E", "giveFeedback on complete"],
            ["ValidationOracle", "0xCfc99136D2BB8DA1C4C457667B9Cd15c418b94C9", "TEE attestation stub"],
            ["YieldVault", "0x6c238E2440AcCbD8Ab94b63B887506784c0a7be6", "USDC↔USYC yield"],
            ["FXRouter", "0xB73e52b71B5E5edd684E61a50569c6c024726983", "EURC→USDC swap"],
            ["NanopaymentSettlement", "0xd88371e75855B0f3b81BCB6D777fEC8207F7d4Cb", "x402 batch settlement"],
          ].map(([name, addr, desc]) => (
            <a key={addr} href={`https://testnet.arcscan.app/address/${addr}`} target="_blank" rel="noopener noreferrer" className="flex items-center justify-between rounded-lg border border-neutral-800 bg-neutral-900/30 px-5 py-3 hover:border-emerald-400/40 transition-colors group">
              <div className="flex items-center gap-4">
                <span className="text-sm font-bold text-white group-hover:text-emerald-400 transition-colors">{name}</span>
                <span className="text-xs text-neutral-600 hidden md:inline">{desc}</span>
              </div>
              <span className="font-mono text-xs text-neutral-600 group-hover:text-neutral-400">{(addr as string).slice(0, 8)}…{(addr as string).slice(-4)}</span>
            </a>
          ))}
        </div>
      </section>

      {/* x402 + MCP — side by side */}
      <section className="border-y border-neutral-800 bg-neutral-900/20">
        <div className="mx-auto max-w-6xl px-6 py-20 grid grid-cols-1 md:grid-cols-2 gap-12">
          <div>
            <p className="text-xs font-mono uppercase tracking-widest text-neutral-500">Micropayments</p>
            <h2 className="mt-3 text-2xl font-black">x402 Paid APIs</h2>
            <p className="mt-2 text-sm text-neutral-500">No API keys. Pay per call with signed USDC.</p>
            <div className="mt-6 space-y-3">
              {[
                { ep: "/summarize", price: "$0.001" },
                { ep: "/fxquote", price: "$0.0005" },
                { ep: "/translate", price: "$0.002" },
              ].map((e) => (
                <div key={e.ep} className="flex items-center justify-between border-l-2 border-neutral-800 pl-4 py-1">
                  <code className="text-sm text-emerald-400">{e.ep}</code>
                  <span className="text-xs text-neutral-600">{e.price}</span>
                </div>
              ))}
            </div>
          </div>
          <div>
            <p className="text-xs font-mono uppercase tracking-widest text-neutral-500">AI-native</p>
            <h2 className="mt-3 text-2xl font-black">MCP Server</h2>
            <p className="mt-2 text-sm text-neutral-500">Claude Code drives Stratum directly.</p>
            <div className="mt-6 space-y-3">
              {[
                { tool: "listAgents", desc: "Query ERC-8004 registry" },
                { tool: "postJob", desc: "Generate createJob calldata" },
                { tool: "checkYield", desc: "Read YieldVault balance" },
              ].map((t) => (
                <div key={t.tool} className="flex items-center justify-between border-l-2 border-neutral-800 pl-4 py-1">
                  <code className="text-sm text-emerald-400">{t.tool}</code>
                  <span className="text-xs text-neutral-600">{t.desc}</span>
                </div>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* Onchain proof — bottom, high trust signal */}
      <section className="mx-auto max-w-6xl px-6 py-20">
        <p className="text-xs font-mono uppercase tracking-widest text-neutral-500">Verify everything</p>
        <h2 className="mt-3 text-3xl font-black">On-chain proof</h2>
        <div className="mt-8 space-y-2">
          {[
            { label: "Full job lifecycle (Open→Completed)", tx: "0x74f2a791c776c52464156ea8da35a0ac095639f91e3c0490d4fcccaf2fe841be" },
            { label: "Reputation hook → giveFeedback (6 events)", tx: "0xb8ad3a1296b0b2abda6984d42d7a69c06061df6ffc48bc173f6bbd202f15dc99" },
            { label: "Agent #17868 registered (LegalBot)", tx: "0x71e47a83ee369557c5c5d3650e72cf240fb5be7f0ee1b0edb9d5783b1fbe5448" },
            { label: "Agent #17896 registered (FXQuoter)", tx: "0xd00c326aba6d3d22a2e4114be57bbd18acec22d39c560791e665158d50730667" },
            { label: "Agent #17897 registered (Summarizer)", tx: "0xc051f4ae267559e22c267afecc0d497478bb6766e08f315fc3f478950fe15eca" },
          ].map((p) => (
            <a key={p.tx} href={`https://testnet.arcscan.app/tx/${p.tx}`} target="_blank" rel="noopener noreferrer" className="flex items-center justify-between rounded-lg border border-neutral-800 bg-neutral-900/30 px-5 py-3.5 hover:border-emerald-400/40 transition-colors group">
              <span className="text-sm text-neutral-300 group-hover:text-white transition-colors">{p.label}</span>
              <span className="font-mono text-xs text-neutral-700 group-hover:text-emerald-400 transition-colors">{p.tx.slice(0, 10)}…</span>
            </a>
          ))}
        </div>
      </section>

      {/* Footer tech */}
      <section className="border-t border-neutral-800">
        <div className="mx-auto max-w-6xl px-6 py-12">
          <div className="flex flex-wrap gap-2">
            {[
              "Solidity 0.8.28", "Foundry", "OZ 5.6.1", "116 Tests",
              "Next.js 16", "React 19", "Tailwind v4", "TypeScript",
              "viem 2", "EIP-3009", "Express", "MCP SDK",
            ].map((t) => (
              <span key={t} className="rounded-full border border-neutral-800 px-3 py-1 text-xs text-neutral-500">{t}</span>
            ))}
          </div>
          <p className="mt-6 text-xs text-neutral-700">Every claim verifiable on <a href="https://testnet.arcscan.app" target="_blank" rel="noopener noreferrer" className="hover:text-emerald-400 transition">testnet.arcscan.app</a></p>
        </div>
      </section>
    </main>
  );
}
