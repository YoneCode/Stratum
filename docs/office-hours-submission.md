# Stratum — Office Hours Submission

## Project Details

| Field | Answer |
|---|---|
| **Email** | <your-email> |
| **Project name** | Stratum |
| **One-line** | Stratum is the agent commerce stack on Arc — onchain identity (ERC-8004), escrowed jobs (ERC-8183), yield-bearing balances (USYC), instant FX (StableFX), and per-call API micropayments (x402/Gateway) — all in one product. |
| **Token plan** | No token; platform fee in USDC (50 bps on completed jobs) |
| **Category** | AI agents (primary); Payments (secondary) |
| **Stage** | Working prototype on testnet |

## Deployed Contracts (Arc Testnet, chainId 5042002)

| Contract | Address | Purpose |
|---|---|---|
| StratumJobFactory | `0xad7157cE777c62273E2CADf8e81203bCBD23E1Fe` | Metadata sidecar for ERC-8183 jobs (categories, tags) |
| StratumAgentCard | `0xeE9a8Cb064b789071c15a6c5aBB25D570871E0eB` | Metadata sidecar for ERC-8004 agents |
| AgenticCommerce (Stratum) | `0x989c0f21c712EecF8bD7AB1caf1A8Ba3da88a46f` | Stratum-owned ERC-8183 with hook whitelist |
| StratumReputationHook | `0xdB80FdA455f8e8f83Ba8B3882abd09708229D42E` | IACPHook → writes giveFeedback on job complete |
| StratumValidationOracle | `0xCfc99136D2BB8DA1C4C457667B9Cd15c418b94C9` | TEE attestation stub for ERC-8004 Validation |
| YieldVault | `0x6c238E2440AcCbD8Ab94b63B887506784c0a7be6` | USDC↔USYC yield wrapper |
| FXRouter | `0xB73e52b71B5E5edd684E61a50569c6c024726983` | EURC→USDC via StableFX relayer |
| NanopaymentSettlement | `0xd88371e75855B0f3b81BCB6D777fEC8207F7d4Cb` | x402 batched EIP-3009 settlement |

**Integrates Arc-native registries:**
- ERC-8004 Identity: `0x8004A818BFB912233c491871b3d84c89A494BD9e`
- ERC-8004 Reputation: `0x8004B663056A597Dffe9eCcC1965A193B7388713`
- ERC-8004 Validation: `0x8004Cb1BF31DAf7788923b405b754f57acEB4272`
- ERC-8183 (ref): `0x0747EEf0706327138c69792bF28Cd525089e4583`
- USYC: `0xe9185F0c5F296Ed1797AaE4238D26CCaBEadb86C`
- StableFX Router: `0x867650F5eAe8df91445971f14d89fd84F0C9a9f8`

## How does this relate to Arc/USDC/Circle?

8 primitives in one product:

1. **USDC-as-gas** — native gas token on Arc; all txs denominated in USDC
2. **ERC-8004** (3 registries) — agent identity, reputation, and validation
3. **ERC-8183** — job escrow with evaluator attestation
4. **USYC** — idle USDC auto-deposits to T-bill yield; atomic redeem on fund
5. **StableFX** — "pay in EURC" toggle for EU clients; relayer-based FX
6. **x402 / Gateway** — micropayment server for paid API endpoints (summarize, translate, fxquote)
7. **Circle Dev-Controlled Wallets** — agent workers use SCA wallets on Arc
8. **App Kit** — bridge/swap/send via SDK (frontend integration ready)

## Feedback wanted

1. ArcaneVM path for confidential job verticals (scope/pricing hidden until completion)
2. ERC-8004 validator economics — TEE/zkML costs at mainnet scale
3. Agent-discovery UX patterns — how to surface "best agent for this task"
4. Compliance/KYB hooks for verified-business tier

## Other

| Question | Answer |
|---|---|
| Keep building? | **Yes** |
| Available for 5-10 min live presentation? | **Yes** |
| GitHub | (will provide repo link) |
| Demo URL | (VPS URL when live) |
