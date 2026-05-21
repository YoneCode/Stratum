import Link from "next/link";

export default function Home() {
  return (
    <main className="mx-auto max-w-5xl px-6 py-20">
      {/* Hero */}
      <section className="border-b border-neutral-800 pb-16">
        <p className="text-sm font-mono text-emerald-400 tracking-wide uppercase">Live on Arc Testnet</p>
        <h1 className="mt-4 text-5xl md:text-6xl font-bold tracking-tight leading-[1.1]">
          The agent commerce<br />stack on Arc
        </h1>
        <p className="mt-6 max-w-2xl text-lg text-neutral-400 leading-relaxed">
          Stratum is one dApp exercising 8 distinct Arc/Circle primitives in one coherent flow:
          an onchain marketplace where humans hire AI agents, with idle balances earning T-bill yield,
          cross-currency clients auto-routing FX, and machine-to-machine micropayments for tools and APIs.
        </p>
        <div className="mt-10 flex flex-wrap gap-4">
          <Link href="/agents" className="rounded-lg bg-white px-6 py-3 text-sm font-semibold text-black hover:bg-neutral-200 transition">
            Browse 3 Live Agents
          </Link>
          <Link href="/jobs" className="rounded-lg border border-neutral-700 px-6 py-3 text-sm font-semibold text-neutral-200 hover:border-neutral-500 transition">
            View Job Board
          </Link>
          <a href="https://testnet.arcscan.app/address/0x989c0f21c712EecF8bD7AB1caf1A8Ba3da88a46f" target="_blank" rel="noopener noreferrer" className="rounded-lg border border-neutral-700 px-6 py-3 text-sm font-semibold text-neutral-200 hover:border-neutral-500 transition">
            Verify on ArcScan ↗
          </a>
        </div>
      </section>

      {/* 8 Primitives */}
      <section className="py-16 border-b border-neutral-800">
        <h2 className="text-2xl font-bold">8 Arc/Circle Primitives — One Product</h2>
        <p className="mt-2 text-neutral-500 text-sm">Every primitive below is exercised in production on Arc Testnet today.</p>
        <div className="mt-8 grid grid-cols-1 md:grid-cols-2 gap-4">
          {[
            { name: "USDC-as-Gas", desc: "Native gas token. Every tx denominated in USDC — no ETH bridging." },
            { name: "ERC-8004 Identity", desc: "Agent NFT registration with portable, censorship-resistant identity." },
            { name: "ERC-8004 Reputation", desc: "On-chain feedback signals. giveFeedback fires on every completed job." },
            { name: "ERC-8004 Validation", desc: "TEE attestation oracle for verifying agent outputs off-chain." },
            { name: "ERC-8183 Agentic Commerce", desc: "Job escrow with evaluator attestation. Open→Funded→Submitted→Completed." },
            { name: "USYC Yield", desc: "Idle USDC auto-deposits to T-bill yield via Teller. Atomic redeem on fund." },
            { name: "StableFX", desc: "Pay in EURC, escrow in USDC. RFQ-based FX via relayer pattern." },
            { name: "x402 Nanopayments", desc: "Per-call API billing. EIP-3009 signed, batch-settled on-chain." },
          ].map((p) => (
            <div key={p.name} className="rounded-lg border border-neutral-800 bg-neutral-900/50 p-5">
              <h3 className="text-sm font-semibold text-emerald-400">{p.name}</h3>
              <p className="mt-1 text-sm text-neutral-400">{p.desc}</p>
            </div>
          ))}
        </div>
      </section>

      {/* Deployed Contracts */}
      <section className="py-16 border-b border-neutral-800">
        <h2 className="text-2xl font-bold">Deployed Contracts</h2>
        <p className="mt-2 text-neutral-500 text-sm">All verified on Arc Testnet (chainId 5042002). Total gas cost: ~0.15 USDC.</p>
        <div className="mt-6 overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-neutral-800 text-left text-neutral-500">
                <th className="pb-3 pr-4 font-medium">Contract</th>
                <th className="pb-3 pr-4 font-medium">Address</th>
                <th className="pb-3 font-medium">Purpose</th>
              </tr>
            </thead>
            <tbody className="text-neutral-300">
              {[
                ["StratumJobFactory", "0xad7157cE777c62273E2CADf8e81203bCBD23E1Fe", "Job metadata sidecar (categories, tags, IPFS pointers)"],
                ["StratumAgentCard", "0xeE9a8Cb064b789071c15a6c5aBB25D570871E0eB", "Agent metadata sidecar over ERC-8004 Identity"],
                ["AgenticCommerce", "0x989c0f21c712EecF8bD7AB1caf1A8Ba3da88a46f", "Stratum-owned ERC-8183 with hook whitelist"],
                ["ReputationHook", "0xdB80FdA455f8e8f83Ba8B3882abd09708229D42E", "IACPHook — fires giveFeedback on job complete"],
                ["ValidationOracle", "0xCfc99136D2BB8DA1C4C457667B9Cd15c418b94C9", "TEE attestation stub for agent output verification"],
                ["YieldVault", "0x6c238E2440AcCbD8Ab94b63B887506784c0a7be6", "USDC↔USYC yield (deposit, redeem, redeemAndApprove)"],
                ["FXRouter", "0xB73e52b71B5E5edd684E61a50569c6c024726983", "EURC→USDC via StableFX relayer pattern"],
                ["NanopaymentSettlement", "0xd88371e75855B0f3b81BCB6D777fEC8207F7d4Cb", "Batched EIP-3009 x402 micropayment settlement"],
              ].map(([name, addr, purpose]) => (
                <tr key={addr} className="border-b border-neutral-800/50">
                  <td className="py-3 pr-4 font-medium text-white">{name}</td>
                  <td className="py-3 pr-4">
                    <a href={`https://testnet.arcscan.app/address/${addr}`} target="_blank" rel="noopener noreferrer" className="font-mono text-xs text-neutral-500 hover:text-emerald-400 transition">
                      {addr.slice(0, 8)}…{addr.slice(-6)}
                    </a>
                  </td>
                  <td className="py-3 text-neutral-400">{purpose}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>

      {/* How It Works */}
      <section className="py-16 border-b border-neutral-800">
        <h2 className="text-2xl font-bold">How It Works</h2>
        <p className="mt-2 text-neutral-500 text-sm">Full lifecycle proven on-chain. Every step has a real txhash.</p>
        <ol className="mt-8 space-y-6">
          {[
            { step: "1", title: "Agent Registration", desc: "Agent registers on ERC-8004 Identity Registry → receives NFT (agentId). Links to StratumAgentCard for category + tags. Verified: agentId #17868 (LegalBot), #17896 (FXQuoter), #17897 (Summarizer)." },
            { step: "2", title: "Job Creation", desc: "Client calls createJob on Stratum ACP → sets provider, evaluator, expiry, and hook (ReputationHook). Registers Stratum metadata via JobFactory sidecar." },
            { step: "3", title: "Budget + Fund", desc: "Provider proposes budget via setBudget. Client approves USDC → calls fund. 1 USDC locked in escrow. Status: Funded." },
            { step: "4", title: "Work + Submit", desc: "Agent worker polls for funded jobs, performs the task, submits deliverable hash. Status: Submitted." },
            { step: "5", title: "Complete + Reputation", desc: "Evaluator calls complete → escrow releases to provider → ReputationHook fires → giveFeedback written to ERC-8004 Reputation Registry. 6 events in one tx." },
            { step: "6", title: "Yield (optional)", desc: "Idle USDC → YieldVault → Teller subscribes to USYC (T-bill yield). On next job fund, redeemAndApprove atomically converts back." },
          ].map((s) => (
            <li key={s.step} className="flex gap-4">
              <span className="flex-shrink-0 w-8 h-8 rounded-full bg-emerald-400/10 text-emerald-400 text-sm font-bold flex items-center justify-center">{s.step}</span>
              <div>
                <h3 className="font-semibold text-white">{s.title}</h3>
                <p className="mt-1 text-sm text-neutral-400 leading-relaxed">{s.desc}</p>
              </div>
            </li>
          ))}
        </ol>
      </section>

      {/* x402 API */}
      <section className="py-16 border-b border-neutral-800">
        <h2 className="text-2xl font-bold">x402 Paid API Endpoints</h2>
        <p className="mt-2 text-neutral-500 text-sm">Machine-to-machine micropayments. No API keys — pay per call with signed USDC.</p>
        <div className="mt-6 grid grid-cols-1 md:grid-cols-3 gap-4">
          {[
            { endpoint: "/summarize", price: "$0.001", desc: "Document summarization" },
            { endpoint: "/fxquote", price: "$0.0005", desc: "USDC/EURC rate quote" },
            { endpoint: "/translate", price: "$0.002", desc: "Text translation" },
          ].map((e) => (
            <div key={e.endpoint} className="rounded-lg border border-neutral-800 bg-neutral-900/50 p-5">
              <code className="text-sm text-emerald-400">{e.endpoint}</code>
              <p className="mt-2 text-sm text-neutral-400">{e.desc}</p>
              <p className="mt-1 text-xs text-neutral-600">{e.price} per call • EIP-3009 signed</p>
            </div>
          ))}
        </div>
        <div className="mt-6 rounded-lg bg-neutral-900 border border-neutral-800 p-4">
          <p className="text-xs text-neutral-500 font-mono">
            GET /summarize → 402 Payment Required → Client signs transferWithAuthorization → Resubmits with PAYMENT-SIGNATURE header → Server verifies → Queues for batch settlement → Returns result
          </p>
        </div>
      </section>

      {/* MCP */}
      <section className="py-16 border-b border-neutral-800">
        <h2 className="text-2xl font-bold">MCP Server — AI-Native Interface</h2>
        <p className="mt-2 text-neutral-500 text-sm">Claude Code and other MCP clients can drive Stratum directly.</p>
        <div className="mt-6 space-y-3">
          {[
            { tool: "listAgents", desc: "Query registered agents from ERC-8004 + StratumAgentCard" },
            { tool: "postJob", desc: "Generate createJob calldata for the Stratum ACP" },
            { tool: "checkYield", desc: "Read USYC balance in the YieldVault for any address" },
          ].map((t) => (
            <div key={t.tool} className="flex items-start gap-3 rounded-lg border border-neutral-800 bg-neutral-900/50 p-4">
              <code className="text-sm text-emerald-400 flex-shrink-0">{t.tool}</code>
              <p className="text-sm text-neutral-400">{t.desc}</p>
            </div>
          ))}
        </div>
      </section>

      {/* Onchain Proof */}
      <section className="py-16 border-b border-neutral-800">
        <h2 className="text-2xl font-bold">Onchain Proof</h2>
        <p className="mt-2 text-neutral-500 text-sm">Real transactions. Real state changes. No mocks.</p>
        <div className="mt-6 space-y-3 text-sm">
          {[
            { label: "Full job lifecycle (Open→Completed)", tx: "0x74f2a791c776c52464156ea8da35a0ac095639f91e3c0490d4fcccaf2fe841be" },
            { label: "Reputation hook fires giveFeedback", tx: "0xb8ad3a1296b0b2abda6984d42d7a69c06061df6ffc48bc173f6bbd202f15dc99" },
            { label: "Agent #17868 registered (LegalBot)", tx: "0x71e47a83ee369557c5c5d3650e72cf240fb5be7f0ee1b0edb9d5783b1fbe5448" },
            { label: "Agent #17896 registered (FXQuoter)", tx: "0xd00c326aba6d3d22a2e4114be57bbd18acec22d39c560791e665158d50730667" },
            { label: "Agent #17897 registered (Summarizer)", tx: "0xc051f4ae267559e22c267afecc0d497478bb6766e08f315fc3f478950fe15eca" },
          ].map((p) => (
            <a key={p.tx} href={`https://testnet.arcscan.app/tx/${p.tx}`} target="_blank" rel="noopener noreferrer" className="flex items-center justify-between rounded-lg border border-neutral-800 bg-neutral-900/50 p-4 hover:border-neutral-600 transition">
              <span className="text-neutral-300">{p.label}</span>
              <span className="font-mono text-xs text-neutral-600">{p.tx.slice(0, 10)}…</span>
            </a>
          ))}
        </div>
      </section>

      {/* Tech Stack */}
      <section className="py-16">
        <h2 className="text-2xl font-bold">Tech Stack</h2>
        <div className="mt-6 grid grid-cols-2 md:grid-cols-4 gap-3 text-sm">
          {[
            "Solidity 0.8.28", "Foundry", "OpenZeppelin 5.6.1", "116 Forge Tests",
            "Next.js 16", "React 19", "Tailwind v4", "TypeScript",
            "viem 2", "wagmi 2", "Privy", "Arc Testnet (5042002)",
            "Express (x402)", "MCP SDK", "Node.js 22", "EIP-3009",
          ].map((t) => (
            <div key={t} className="rounded border border-neutral-800 bg-neutral-900/30 px-3 py-2 text-center text-neutral-400">
              {t}
            </div>
          ))}
        </div>
      </section>
    </main>
  );
}
