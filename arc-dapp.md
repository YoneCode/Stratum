# Stratum — Arc-Native Agent Commerce Stack

> **Status:** Production-grade spec for solo VPS builder.
> **Cost to ship MVP:** $0 (testnet + free tiers).
> **Goal:** Top 0.01% Arc builder. Maximize Office Hours selection, Discord Creator role, ecosystem-grant visibility, and any retroactive ARC airdrop allocation (60% of 10B ARC supply is earmarked for ecosystem).

---

## 0. Honest Summary

Stratum is **one dApp** that exercises **8 distinct Arc/Circle primitives** in one coherent flow: an onchain marketplace where humans hire AI agents, with idle balances earning T-bill yield, cross-currency clients auto-routing FX, and machine-to-machine micropayments for tools/APIs.

Every contract address listed here is **live on Arc testnet today**. Every SDK call comes from official Circle/Arc docs (sources in §16). The 4 MVP layers (ERC-8004, ERC-8183, USYC, StableFX, x402) all have working code samples in official docs. ArcaneVM (confidential layer) is **deferred to v0.2** because its tooling isn't yet shipped.

This is the complete blueprint. Hand it to Claude Code on your VPS to execute.

---

## 1. Why This Wins

### 1.1 Office Hours filter (the highest-signal selection)
The form's questions are scoring criteria:
- *"What contract addresses have you deployed?"* → real onchain footprint required.
- *"How does this relate to Arc/USDC/Circle?"* → multi-primitive usage required.
- *Category options* include **AI agents** — Arc's #1 strategic narrative.
- *Live 5-10 min presentation* filters out anon farmers.

Stratum hits **8 primitives** vs typical 1-2.

### 1.2 What 99% of farmers do (noise to ignore)
Add network → faucet → deploy hello-world via Zkcodex → mint NFT via Omnihub → register InfinityName domain. Discord **"Creator" role** is gated on *"meaningful projects or quality educational content"* — none of the above counts.

### 1.3 What 0.01% can build (Arc's unique primitives)
| Primitive | Why rare elsewhere |
|---|---|
| ERC-8004 + ERC-8183 | DRAFT EIPs Aug 2025; canonical contracts only on Arc |
| ArcaneVM | Synchronous public+confidential composability — unique |
| USYC | Allowlist-gated; ~zero consumer apps wrap it |
| StableFX as primitive | Onchain FX router at protocol level |
| Gateway + x402 | Brand new; few non-Circle services |
| USDC-as-gas | Only Arc has native USDC gas |

Stratum uses 5/6 in MVP, the 6th in v0.2.

### 1.4 Ecosystem reality
`arc.io/ecosystem` lists ~120 names: institutions (BlackRock, Goldman, JPM, HSBC, BNY), stablecoin issuers (Bridge, Noah, Copperx), infra (Chainlink, LayerZero, Alchemy, QuickNode), wallets (MetaMask, Privy, Ledger). **Zero indie consumer dApps.** Only first-party sample is "Arc P2P payments." Open field for solo builders.

---

## 2. Verified Facts

### 2.1 Network
- Chain ID `5042002` · RPC `https://rpc.testnet.arc.network` · Explorer `https://testnet.arcscan.app` · Faucet `https://faucet.circle.com`
- Gas token: **USDC** · Sub-second deterministic finality

### 2.2 Tokens
| Asset | Address | Notes |
|---|---|---|
| USDC | `0x3600000000000000000000000000000000000000` | Native gas; precompile-style address |
| EURC | `0x89B50855Aa3bE2F677cD6303Cec089B5F319D72a` | Faucet available |
| USYC (yield) | `0xe9185F0c5F296Ed1797AaE4238D26CCaBEadb86C` | **Allowlist required** — Circle Support ticket, 24-48h |
| USYC Teller | `0xcc205224862c7641930c87679e98999d23c26113` | Mint/redeem |

### 2.3 ERC-8004 Trustless Agents (live)
- Identity: `0x8004A818BFB912233c491871b3d84c89A494BD9e`
- Reputation: `0x8004B663056A597Dffe9eCcC1965A193B7388713`
- Validation: `0x8004Cb1BF31DAf7788923b405b754f57acEB4272`

Working SDK script in `docs.arc.io/arc/tutorials/register-your-first-ai-agent`.

Key calls:
- `register(string metadataURI) -> uint256 agentId`
- `giveFeedback(uint256 agentId, int128 score, uint8 type, string tag, string,string,string, bytes32 hash)`

AgentCard JSON (IPFS):
```json
{
  "name": "DeFi Arbitrage Agent v1.0",
  "description": "...",
  "image": "ipfs://...",
  "agent_type": "trading",
  "capabilities": ["arbitrage_detection","liquidity_monitoring"],
  "version": "1.0.0"
}
```

### 2.4 ERC-8183 Agentic Commerce (live)
Reference contract: `0x0747EEf0706327138c69792bF28Cd525089e4583`

State machine: `Open → Funded → Submitted → Terminal(Completed|Rejected|Expired)`

Core functions (from EIP reference impl):
```solidity
createJob(provider, evaluator, expiredAt, description, hook) -> jobId
setProvider(jobId, provider)
setBudget(jobId, amount, optParams)
fund(jobId, optParams)               // transfers escrow USDC
submit(jobId, deliverable, optParams) // provider; bytes32 IPFS hash
complete(jobId, reason, optParams)    // evaluator; releases escrow
reject(jobId, reason, optParams)
claimRefund(jobId)                    // anyone after expiredAt
```
Hooks: `IACPHook.beforeAction(jobId, selector, data)` / `afterAction(...)`. Built-in `platformFeeBP` to treasury + `evaluatorFeeBP`.

### 2.5 Crosschain
- CCTP TokenMessenger `0x8FE6B999Dc680CcFDD5Bf7EB0974218be2542DAA`
- CCTP MessageTransmitter `0xE737e5cEBEEBa77EFE34D4aa090756590b1CE275`
- CCTP TokenMinter `0xb43db544E2c27092c107639Ad201b3dEfAbcF192`
- CCTP MessageHandler `0xbaC0179bB358A8936169a63408C8481D582390C4`
- Gateway Wallet `0x0077777d7EBA4688BDeF3E311b846F25870A19B9`
- Gateway Minter `0x0022222ABE238Cc2C7Bb1f21003F0a260052475B`
- `arcTestnet` is in Gateway's supported chain list.

### 2.6 StableFX
Router `0x867650F5eAe8df91445971f14d89fd84F0C9a9f8`. Callable via App Kit `kit.swap({tokenIn:"USDC", tokenOut:"EURC", chain:"Arc_Testnet"})`.

### 2.7 x402 / Nanopayments
- Spec: x402.org · docs.x402.org · github.com/coinbase/x402
- Flow: client `GET` → server `402 Payment Required` → client signs **EIP-3009 transferWithAuthorization** offchain → resubmits with `PAYMENT-SIGNATURE` header → server verifies → Gateway batches settlement onchain.
- **Caveat:** Circle Agent Marketplace x402 services run on Base. **We will publish our own x402 server on Arc** — protocol is chain-agnostic.

### 2.8 Circle SDKs
- `@circle-fin/app-kit`, `@circle-fin/adapter-viem-v2` — supports `Arc_Testnet`
- `@circle-fin/developer-controlled-wallets` — `blockchains: ["ARC-TESTNET"]`, `accountType: "SCA"`
- `@circle-fin/modular-wallets-core` — passkeys
- `@circle-fin/cli` — agent stack
- Console: `console.circle.com` (free)
- Skills (Claude Code plugins): `github.com/circlefin/skills` — `use-arc`, `use-circle-wallets`, `use-gateway`, `use-developer-controlled-wallets`, `bridge-stablecoin`

### 2.9 EVM notes
- USDC-as-gas: `eth_gasPrice` USDC-denominated; ceiling `1e-3 USDC/gas`.
- EIP-7702 supported (gas/USDC sponsorship via delegated sigs).
- EIP-3009 supported on USDC (`transferWithAuthorization`) — critical for x402.
- ERC-4337 SCA wallets are first-class via Circle.

### 2.10 ArcaneVM (deferred v0.2)
Concept docs: `docs.arc.io/arc/concepts/opt-in-privacy`. Function-level access policies, `addTrustee`, X-Wing KEM + ML-KEM-768 + AES-256-GCM-SIV. **No deploy tutorial yet** — reason for v0.2.

### 2.11 Tokenomics
10B ARC supply · Ecosystem 60% / Circle 25% / Reserve 15% · Vesting unpublished · $2.2B raised · Backers: BlackRock, Goldman, Pantera, Visa, Mastercard, AWS, Anthropic, HSBC, BNY.

---

## 3. The Five Ideas (4 in MVP, 1 v0.2)

| # | Idea | Status |
|---|---|---|
| 1 | **ArcWork** — agent marketplace via ERC-8004 + ERC-8183 | **MVP CORE** |
| 2 | **PrivPay** — confidential payroll on ArcaneVM | v0.2 |
| 3 | **YieldCheckout** — USYC idle yield, atomic redeem on fund | MVP |
| 4 | **OracleMart** — x402 API marketplace on Arc | MVP |
| 5 | **DarkFX** — auto-FX USDC↔EURC via StableFX (privacy in v0.2) | MVP (basic) |

---

## 4. Elevators (push beyond standard)

Each adds independent signal. Add in order; all optional but recommended.

1. **A2A + MCP-compatible agents** — AgentCard exposes `/a2a` (skills+tasks) and `/mcp` (tools+prompts). Native Claude/OpenAI compatibility.
2. **Stratum MCP server** — Claude Code can post jobs / query reputation / check yield via MCP. Meta-loop on Arc's narrative.
3. **EIP-7702 gas sponsorship** — sponsor first job for new users (zero-USDC onboarding).
4. **EIP-3009 gasless USDC** — for x402 + tip features.
5. **Real TEE validators** — AWS Nitro Enclaves or Phala Cloud (free tiers) for ERC-8004 Validation Registry. Most projects will stub this; we ship real.
6. **zkML-stub validator interface** — placeholder for EZKL/Modulus; shows roadmap depth.
7. **Subgraph/indexer** — Goldsky free tier, Sim (Arc-supported), or self-hosted Graph node on VPS.
8. **Compliance hooks** — TRM Labs / Elliptic before-fund screening (toggle).
9. **Verified business tier (KYB)** — Circle Compliance flow + badge.
10. **Multi-evaluator committees** — Safe multisig as ERC-8183 evaluator.
11. **Reputation passport API** — aggregate ERC-8004 reputation across chains.
12. **Open-source educational content** — every layer documented; tutorials = Discord Creator role.
13. **Live demo agents 24/7 on VPS** — visitors see real onchain activity. Rare for solo builds.
14. **Native domain (InfinityName/etc.)** — `legalbot.arc` style names.

---

## 5. Unified User Journey (MVP)

EU founder Maria hires `legalbot` for legal research:
1. Passkey signup → Circle Modular Wallet
2. Funds €100 → StableFX swap to USDC (via App Kit)
3. Idle USDC auto-deposits → USYC vault (yield)
4. Browses agents (UI reads ERC-8004 reputation via indexer)
5. Posts job → `StratumJobFactory.createJob` (wraps ERC-8183)
6. Sets provider + budget (25 USDC)
7. `fund()` — atomically redeems USYC → USDC → escrow
8. Agent calls our x402 endpoints during work (EIP-3009 sigs, batch-settled)
9. Submits IPFS deliverable hash
10. Maria `complete()`s — escrow releases
11. Hook fires → `giveFeedback` to ERC-8004 Reputation
12. Remaining balance re-wraps to USYC

Every tx visible on `testnet.arcscan.app`.

---

## 6. Architecture

```
┌──────────────────────────────────────────────────────────────┐
│ L7  Content     Blog · YouTube · Twitter threads             │
├──────────────────────────────────────────────────────────────┤
│ L6  UI          Next.js 14 · Tailwind · shadcn/ui · Privy    │
├──────────────────────────────────────────────────────────────┤
│ L5  Commerce    ERC-8183 (0x0747EEf...) + Stratum hooks      │
├──────────────────────────────────────────────────────────────┤
│ L4  Trust       ERC-8004 Identity/Reputation/Validation      │
│                 TEE backend (Phala/Nitro)                    │
├──────────────────────────────────────────────────────────────┤
│ L3  Micro-bill  Our x402 server on Arc · Gateway settle      │
├──────────────────────────────────────────────────────────────┤
│ L2  Capital     USYC vault · atomic redeem on fund()         │
├──────────────────────────────────────────────────────────────┤
│ L1  FX          StableFX router · USDC ↔ EURC                │
├──────────────────────────────────────────────────────────────┤
│ L0  Arc         USDC gas · sub-second finality · CCTP/Gateway│
├──────────────────────────────────────────────────────────────┤
│ Agents  Node.js workers · A2A · MCP · Circle Agent Wallets   │
│ Indexer Goldsky/Sim/self-hosted Graph                        │
│ v0.2    ArcaneVM confidential jobs · zkML validators         │
└──────────────────────────────────────────────────────────────┘
```

---

## 7. Contracts We Deploy

7 own contracts + 4 Arc-native registries.

| # | Contract | Purpose |
|---|---|---|
| 1 | `StratumJobFactory.sol` | Wraps ERC-8183 ref; categories, tags, metadata pointers |
| 2 | `StratumReputationHook.sol` | `IACPHook` impl; on `complete` → `giveFeedback` to ERC-8004 |
| 3 | `StratumAgentCard.sol` | Validates AgentCard JSON; wraps ERC-8004 `register` |
| 4 | `StratumValidationOracle.sol` | TEE attestation submitter (Nitro/Phala signed reports) |
| 5 | `YieldVault.sol` | ERC-4626-ish USDC↔USYC vault; atomic `redeemAndApprove(jobId)` |
| 6 | `FXRouter.sol` | Wraps StableFX; "pay in EURC, escrow in USDC" |
| 7 | `NanopaymentSettlement.sol` | Receives batched x402 settlements; per-merchant balances |

**Revenue model:** ERC-8183 ref supports `platformFeeBP` → set 50 bps (0.50%) on every completed job. Real mainnet revenue, not vanity.

---

## 8. Tech Stack

**Contracts:** Foundry, OpenZeppelin `^5.0` (`@openzeppelin/contracts`, `@openzeppelin/contracts-upgradeable`), Solidity `^0.8.28`.

**Frontend:** Next.js 14 App Router, Tailwind, shadcn/ui, Lucide, wagmi+viem, `@circle-fin/app-kit` + `@circle-fin/adapter-viem-v2`, Privy (default) or Circle Modular Wallets, TanStack Query.

**Backend/agents:** Node.js 20.18+, Express (x402 server), `@circle-fin/developer-controlled-wallets`, `@circle-fin/cli`, viem, `@modelcontextprotocol/sdk`, A2A handler.

**Indexer:** Goldsky free tier OR Sim OR self-hosted Graph node (Docker on VPS).

**Storage:** Pinata free tier for IPFS (AgentCards, deliverables).

**Infra:** Docker Compose on VPS for x402 server + agent workers + MCP server + indexer; Caddy/nginx HTTPS; Vercel free tier for Next.js (or self-host); GitHub Actions CI.

---

## 9. Repo Structure

```
stratum/
├── arc-dapp.md                        # this file
├── README.md · .env.example · pnpm-workspace.yaml
├── contracts/                         # Foundry
│   ├── src/
│   │   ├── StratumJobFactory.sol
│   │   ├── StratumReputationHook.sol
│   │   ├── StratumAgentCard.sol
│   │   ├── StratumValidationOracle.sol
│   │   ├── YieldVault.sol
│   │   ├── FXRouter.sol
│   │   ├── NanopaymentSettlement.sol
│   │   └── interfaces/
│   │       ├── IAgenticCommerce.sol  # ERC-8183
│   │       ├── IIdentityRegistry.sol # ERC-8004
│   │       ├── IReputationRegistry.sol
│   │       ├── IValidationRegistry.sol
│   │       ├── IStableFX.sol
│   │       └── IUSYC.sol
│   ├── script/Deploy.s.sol
│   └── test/*.t.sol
├── app/                               # Next.js
│   ├── app/{page,layout,agents/[id],jobs/{new,[id]},dashboard}.tsx
│   ├── components/{WalletButton,AgentCard,JobBoard,YieldPanel,FXSwap}.tsx
│   └── lib/{arc,contracts,appKit,circle}.ts
├── agents/                            # Node workers
│   ├── src/{worker,a2a-server,jobs}.ts
│   └── agent-cards/{legalbot,fxquoter,summarizer}.json
├── x402-server/                       # paid APIs
│   ├── src/{index,facilitator,batched-settle}.ts
│   ├── src/routes/{summarize,fxquote,translate}.ts
│   └── Dockerfile
├── mcp-server/                        # Stratum MCP for Claude Code
│   └── src/{index,tools/{listAgents,postJob,checkYield}}.ts
├── indexer/{schema.graphql,subgraph.yaml,mappings/{erc8183,erc8004}.ts}
├── infra/{docker-compose.yml,Caddyfile,.github/workflows/ci.yml}
└── docs/                              # Discord Creator content
    ├── 01-overview.md
    ├── 02-deploying.md
    ├── 03-erc8004-tutorial.md
    ├── 04-erc8183-tutorial.md
    ├── 05-x402-on-arc.md
    └── 06-usyc-flow.md
```

---

## 10. Build Phases

### Week 1 — Foundation
- pnpm monorepo + Foundry + OZ
- Interface files (ERC-8004, ERC-8183, USYC, StableFX)
- `StratumJobFactory.sol`, `StratumAgentCard.sol`
- Forge tests green
- Circle Console API key + Entity Secret
- **File USYC allowlist ticket on Day 1** (24-48h lead)
- Deploy to Arc testnet, verify on arcscan
- Script: AgentCard → Pinata → register → agentId
- Script: full job lifecycle (createJob→setProvider→setBudget→fund→submit→complete)
- Next.js scaffold + Privy + minimal "Register Agent" + "Post Job" forms
- **Exit:** watch a job go Open→Funded→Submitted→Completed on explorer.

### Week 2 — Reputation, Validation, UI
- `StratumReputationHook.sol` (IACPHook); whitelist on factory
- One full job → confirm `giveFeedback` recorded
- `StratumValidationOracle.sol` (stub first)
- Agent worker: poll `JobCreated`, run trivial task, submit
- A2A endpoint at `/a2a`
- Frontend: agent list, profile w/ reputation, job board
- Set up indexer (Goldsky free tier)
- **Exit:** browse 3 agents, post job from UI, watch worker complete it, reputation ticks up.

### Week 3 — Capital + FX
- USYC allowlist approved
- `YieldVault.sol` ERC-4626-ish around USYC
- `FXRouter.sol` wraps StableFX
- Forge tests; deploy + verify
- Frontend: yield panel (USYC balance + APY)
- Wire `fund(jobId)` → atomic USYC redeem → escrow
- "Pay in EURC" toggle uses FXRouter at deposit
- Balance display USD + EUR equivalents
- **Exit:** fund a job from USYC balance one-click; same flow for EUR user.

### Week 4 — x402 + Polish + Submit
- `NanopaymentSettlement.sol`
- Express x402 server: `/summarize` ($0.001), `/fxquote` ($0.0005), `/translate` ($0.002)
- EIP-3009 verification + batched settle cron (every 5 min)
- Update agent workers to call x402 endpoints
- Stratum MCP server (Claude Code drives Stratum)
- UI polish: animations, empty/error/loading
- **90-second demo video**
- 6 educational blog posts (`docs/`)
- Twitter thread per post
- **Submit Office Hours form** (template §13)
- Apply for Discord Creator role
- **Exit:** public URL works, video published, form submitted.

---

## 11. Code Patterns (from Circle docs, ready to use)

### 11.1 Arc chain config (viem)
```ts
import { defineChain } from "viem";
export const arcTestnet = defineChain({
  id: 5042002,
  name: "Arc Testnet",
  nativeCurrency: { name: "USDC", symbol: "USDC", decimals: 6 },
  rpcUrls: { default: { http: ["https://rpc.testnet.arc.network"] } },
  blockExplorers: { default: { name: "ArcScan", url: "https://testnet.arcscan.app" } },
});
```

### 11.2 Register agent on ERC-8004 Identity
```ts
import { initiateDeveloperControlledWalletsClient } from "@circle-fin/developer-controlled-wallets";
const circle = initiateDeveloperControlledWalletsClient({
  apiKey: process.env.CIRCLE_API_KEY!,
  entitySecret: process.env.CIRCLE_ENTITY_SECRET!,
});
const ws = await circle.createWalletSet({ name: "Stratum Agents" });
const wallets = await circle.createWallets({
  blockchains: ["ARC-TESTNET"], count: 2,
  walletSetId: ws.data!.walletSet!.id, accountType: "SCA",
});
const owner = wallets.data!.wallets![0];

const IDENTITY = "0x8004A818BFB912233c491871b3d84c89A494BD9e";
await circle.createContractExecutionTransaction({
  walletAddress: owner.address!,
  blockchain: "ARC-TESTNET",
  contractAddress: IDENTITY,
  abiFunctionSignature: "register(string)",
  abiParameters: ["ipfs://<your_agentcard_cid>"],
  fee: { type: "level", config: { feeLevel: "MEDIUM" } },
});
```

### 11.3 Reputation feedback
```ts
import { keccak256, toHex } from "viem";
const REPUTATION = "0x8004B663056A597Dffe9eCcC1965A193B7388713";
const tag = "job_completed_on_time";
await circle.createContractExecutionTransaction({
  walletAddress: validator.address!,
  blockchain: "ARC-TESTNET",
  contractAddress: REPUTATION,
  abiFunctionSignature:
    "giveFeedback(uint256,int128,uint8,string,string,string,string,bytes32)",
  abiParameters: [agentId, "95", "0", tag, "", "", "", keccak256(toHex(tag))],
  fee: { type: "level", config: { feeLevel: "MEDIUM" } },
});
```

### 11.4 Stratum job facade (Solidity)
```solidity
function postJob(address agent, address evaluator, uint256 budget, string memory desc)
  external returns (uint256 jobId)
{
  jobId = IAgenticCommerce(ERC8183).createJob(
    agent, evaluator, block.timestamp + 7 days, desc, address(reputationHook)
  );
  IAgenticCommerce(ERC8183).setProvider(jobId, agent);
  IAgenticCommerce(ERC8183).setBudget(jobId, budget, "");
  // client approves USDC to ERC8183 then calls fund(jobId)
}
```

### 11.5 App Kit bridge & swap
```ts
await kit.bridge({
  from: { adapter, chain: "Ethereum_Sepolia" },
  to:   { adapter, chain: "Arc_Testnet" },
  amount: "10.00",
});
await kit.swap({
  from: { adapter, chain: "Arc_Testnet" },
  tokenIn: "USDC", tokenOut: "EURC", amountIn: "100.00",
  config: { kitKey: process.env.KIT_KEY },
});
```

### 11.6 x402 server (Express middleware)
```ts
app.get("/summarize", async (req, res) => {
  const auth = req.headers["payment-signature"];
  if (!auth) return res.status(402).json({
    x402Version: 1,
    accepts: [{
      scheme: "exact",
      network: "arcTestnet",
      asset: "0x3600000000000000000000000000000000000000", // USDC
      maxAmountRequired: "1000",                            // 0.001 USDC (6 decimals)
      payTo: process.env.MERCHANT_ADDRESS!,
      resource: "https://api.stratum.dev/summarize",
      description: "Summarize text via Stratum",
    }],
  });
  if (!await verifyEip3009(auth)) return res.status(402).end();
  await queueForBatchSettlement(auth);
  res.setHeader("payment-response", "settled");
  res.json({ summary: await runLLM(req.body.text) });
});
```

---

## 12. Risk Register

| Risk | Likelihood | Mitigation |
|---|---|---|
| Arc testnet instability | Med | Retry/idempotency; dry-run mode |
| USYC allowlist delay | High | File ticket Day 1; mock USYC for tests until approved |
| ArcaneVM not tooled by W4 | High | Already deferred to v0.2 |
| Registry addresses change | Low | Single config file; one-line update |
| Gateway nanopayment Base-only | Med | Self-host x402 server on Arc, batch-settle locally |
| Office Hours not selected | Med | Apply anyway; Creator role + content = parallel path |
| ARC token never launches | Med | Real platform fee = revenue path even without token |
| Wallet UX kills conversion | Med | Privy default; Modular Wallet for power users |

---

## 13. Office Hours Submission Template

| Field | Answer |
|---|---|
| Email | `kr863742@gmail.com` |
| Project name | **Stratum** |
| One-line | *Stratum is the agent commerce stack on Arc — onchain identity (ERC-8004), escrowed jobs (ERC-8183), yield-bearing balances (USYC), instant FX (StableFX), and per-call API micropayments (x402/Gateway) — all in one product.* |
| Token plan | No token; platform fee in USDC |
| Category | **AI agents** (primary); Payments (secondary) |
| Stage | Working prototype on testnet |
| Contracts deployed | Stratum 7 contracts `<addrs>`; integrates ERC-8004 (`0x8004A818...`, `0x8004B663...`, `0x8004Cb1B...`), ERC-8183 (`0x0747EEf0...`), USYC, StableFX, Gateway |
| How relates to Arc/USDC/Circle | 8 primitives: USDC-as-gas, ERC-8004 (3 registries), ERC-8183, App Kit (Bridge/Swap/Send/UB), Circle Dev-Controlled Wallets SCA, StableFX, USYC, Gateway+x402. Built natively on Arc testnet. |
| Feedback wanted | (1) ArcaneVM path for confidential job verticals; (2) ERC-8004 validator economics (TEE/zkML) at mainnet scale; (3) agent-discovery UX patterns; (4) Compliance/KYB hooks for verified-business tier |
| Keep building? | **Yes** |
| 5-10 min live? | **Yes** |

---

## 14. Content Strategy (Discord Creator role)

| Asset | Format |
|---|---|
| README.md | Markdown |
| `docs/01-overview.md` … `docs/06-usyc-flow.md` | 6 tutorials |
| Demo video (YouTube) | 90 sec |
| Long walkthrough | 10-15 min |
| Twitter thread per doc | Threads |
| Mirror.xyz launch post | Article |

The Creator role is granted for *"meaningful projects or quality educational content."* Stratum is both.

---

## 15. Cost Breakdown — $0 MVP

| Item | Cost |
|---|---|
| Arc testnet gas (USDC) | $0 (faucet) |
| EURC / USYC testnet | $0 (faucet + allowlist) |
| Circle Developer Console | $0 |
| Pinata IPFS free tier | $0 |
| Vercel | $0 |
| VPS (already owned) | $0 marginal |
| Goldsky / Sim free tier | $0 |
| Phala TEE free tier | $0 |
| GitHub | $0 |
| Domain (optional) | $0–15/yr |
| **TOTAL** | **$0** |

---

## 16. Sources (read in full during research)

**Arc:** `arc.io/`, `arc.io/litepaper`, `arc.io/ecosystem`, `docs.arc.io/`, `docs.arc.io/llms.txt`, `docs.arc.io/arc-chain`, `docs.arc.io/arc/concepts/{system-overview,stable-fee-design,deterministic-finality,opt-in-privacy,post-quantum-security}`, `docs.arc.io/arc/references/{connect-to-arc,contract-addresses,evm-compatibility,gas-and-fees,sample-applications}`, `docs.arc.io/arc/tutorials/{deploy-on-arc,deploy-contracts,interact-with-contracts,monitor-contract-events,register-your-first-ai-agent,create-your-first-erc-8183-job}`, `docs.arc.io/arc/tools/{node-providers,data-indexers,oracles,account-abstraction,compliance-vendors}`, `docs.arc.io/app-kit`, `docs.arc.io/app-kit/{unified-balance,bridge,quickstarts/*,references/*,tutorials/installation}`, `docs.arc.io/ai/mcp`, `docs.arc.io/build`, `docs.arc.io/build/{agentic-economy,payments,ecommerce,stablecoin-fx}`, `docs.arc.io/integrate`.

**Circle:** `developers.circle.com/`, `/products`, `/build-onchain`, `/ai/{skills,mcp}`, `/agent-stack`, `/agent-stack/{agent-wallets,agent-nanopayments,agent-nanopayments/quickstart,circle-cli}`, `/gateway`, `/gateway/{nanopayments,nanopayments/concepts/x402,nanopayments/concepts/batched-settlement,references/supported-blockchains}`, `/cctp`, `/stablefx`, `/wallets`, `/wallets/{dev-controlled,user-controlled,modular,dev-controlled/register-entity-secret}`, `/stablecoins/{usdc-contract-addresses,eurc-contract-addresses}`, `/tokenized/usyc/overview`.

**EIPs:** `eips.ethereum.org/EIPS/eip-8004` (ERC-8004), `eip-8183` (ERC-8183 + reference impl), `eip-3009`, `eip-7702`, `eip-1559`.

**x402:** `x402.org`, `docs.x402.org`, `github.com/coinbase/x402`.

**Tools:** `github.com/circlefin/skills`, `console.circle.com`, `faucet.circle.com`, `testnet.arcscan.app`, `thirdweb.com/arc-testnet`.

**Community/airdrop intel:** `community.arc.io/public/resources/project-submission-form-for-office-hours` (Office Hours form), `airdrops.io/arc/`, `whales.market/blog/how-to-get-the-arc-airdrop/`, `discord.com/invite/buildonarc`.

---

## 17. Instructions for Claude Code on VPS

1. Read this file in full.
2. Fetch `docs.arc.io/llms.txt` for missing API details.
3. Install Circle Skills (Claude Code plugins) from `github.com/circlefin/skills`: at minimum `use-arc`, `use-developer-controlled-wallets`, `use-gateway`, `use-smart-contract-platform`, `bridge-stablecoin`.
4. Optionally connect to Circle's MCP server (`developers.circle.com/ai/mcp`) and Arc's MCP server (`docs.arc.io/ai/mcp`).
5. Execute §10 phase-by-phase. Verify on `testnet.arcscan.app` after each deliverable. Track in `PROGRESS.md`.
6. Never hardcode addresses outside `app/lib/contracts.ts` and `contracts/script/Deploy.s.sol`. Always read ABIs from `forge build` output.
7. Never claim a feature works until a real testnet tx confirms it.
8. Never copy code that wasn't in this file or in §16 sources without flagging "unverified".
9. Stop and ask if any contract address fails. Re-fetch `docs.arc.io/arc/references/contract-addresses` to check for updates.
10. After Week 4, draft the Office Hours submission using §13 with real deployed addresses + URLs.

---

## 18. What's NOT in this spec (be honest)

- ArcaneVM deploy steps (no public tutorial yet)
- Arc mainnet specifics (testnet only)
- Token distribution mechanics (unpublished)
- Specific airdrop eligibility criteria (Circle has not announced)
- Production-grade KMS / Entity Secret rotation (use Circle's recommended flow)
- Legal/regulatory compliance for actually offering a paid service (consult counsel before mainnet)

If any of these become published while building, update this file.
