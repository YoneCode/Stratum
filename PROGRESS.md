# Stratum — Progress Log

> Append-only log of every deliverable. Each entry must record date, step, txhash (where applicable), arcscan URL, and whether the phase exit criterion is met.
>
> Source of truth: `arc-dapp.md` (spec) + `CLAUDE.md` (working rules). Do not deviate without writing a justification here.

---

## Conventions

- **Date format:** ISO-8601 UTC (`YYYY-MM-DD`).
- **Tx links:** `Tx: 0x… — https://testnet.arcscan.app/tx/0x…`
- **Contract links:** `<Name>: 0x… — https://testnet.arcscan.app/address/0x…`
- **Status tags:** `DONE`, `IN_PROGRESS`, `BLOCKED`, `DEFERRED`.
- **Exit criterion:** must be checked off onchain before advancing to the next week.

---

## Week 1 — Foundation

**Goal (`arc-dapp.md §10`):** pnpm monorepo + Foundry + OZ scaffolded; ERC-8004/ERC-8183/USYC/StableFX interfaces; `StratumJobFactory.sol` and `StratumAgentCard.sol`; Forge tests green; Circle Console API key + Entity Secret; **USYC allowlist ticket filed Day 1**; deploy to Arc testnet, verify on arcscan; agent registration script (AgentCard → Pinata → register → agentId); full job lifecycle script (createJob → setProvider → setBudget → fund → submit → complete); Next.js scaffold + Privy + minimal "Register Agent" + "Post Job" forms.

**Exit criterion:** watch a job go `Open → Funded → Submitted → Completed` on `testnet.arcscan.app`.

### Tasks

| # | Task | Status | Skills used | Tx / address | Notes |
|---|---|---|---|---|---|
| 1 | pnpm monorepo + Foundry + OZ scaffolded | DONE 2026-05-21 | `test-foundry`, `use-smart-contract-platform` | n/a (no onchain action) | `forge build` ok (Solc 0.8.28, 20 files); `forge test` ok (`test_ToolchainAlive`); `pnpm install` ok |
| 2 | Interface files (ERC-8004 ×3, ERC-8183 ×2) | DONE 2026-05-21 | `use-arc`, `test-foundry`, `use-smart-contract-platform`, `audit` | n/a (off-chain only) | `IIdentityRegistry`, `IReputationRegistry`, `IValidationRegistry`, `IAgenticCommerce`, `IACPHook` written; 9/9 selector-pinning tests pass; `IUSYC` + `IStableFX` deferred to Week 3 (no signatures verifiable from `arc-dapp.md` or EIPs) |
| 3 | `StratumJobFactory.sol` + tests | DONE 2026-05-21 | `test-foundry`, `audit`, `gas-optimize`, `use-smart-contract-platform` | n/a (off-chain only) | 218 LoC sidecar contract; 28 unit tests + 2 fuzz tests, all green; covers 9/9 custom errors, 3/3 events, every public function. Total suite: **37/37 passing** |
| 4 | `StratumAgentCard.sol` + tests | DONE 2026-05-21 | `test-foundry`, `audit`, `gas-optimize`, `use-smart-contract-platform` | n/a (off-chain only) | 153 LoC sidecar contract; 18 unit tests + 2 fuzz tests, all green; covers 6/6 custom errors, 2/2 events, post-NFT-transfer rewrite scenario. Total suite: **57/57 passing** |
| 5 | Deploy script + addresses config | DONE 2026-05-21 | `test-foundry`, `audit`, `use-arc`, `use-smart-contract-platform` | not yet broadcast | `contracts/script/Deploy.s.sol` (chain-id guard + env-overridable defaults) and `app/lib/contracts.ts` (single source of truth for every Arc Testnet address per CLAUDE.md Rule 4). Compiles clean. Deploy itself blocked on funded testnet keystore — see "External Tickets" |
| 6 | Deploy to Arc testnet | DONE 2026-05-21 | `use-arc` | Block 43323893 | StratumJobFactory `0xad71…` + StratumAgentCard `0xeE9a…`. Cost: 0.0315 USDC. View-call verified: `acp()`, `identity()`, `owner()` all correct |
| 7 | Register agent + link on StratumAgentCard | DONE 2026-05-21 | `use-arc`, `use-smart-contract-platform` | Tx1: [`0x71e47a83…`](https://testnet.arcscan.app/tx/0x71e47a83ee369557c5c5d3650e72cf240fb5be7f0ee1b0edb9d5783b1fbe5448) Tx2: [`0x19f28b44…`](https://testnet.arcscan.app/tx/0x19f28b44813a73f8cb38d5d5c6d2bbf80e02a5901e9293f662992bb8407f9bd4) | agentId=17868 (0x45cc); registered on ERC-8004 Identity + linked on StratumAgentCard with category `legal-research`, tags `[law, eu]` |
| 8 | Full job lifecycle (Open→Funded→Submitted→Completed) | DONE 2026-05-21 | `use-arc`, `use-smart-contract-platform` | createJob [`0x74f2a791…`](https://testnet.arcscan.app/tx/0x74f2a791c776c52464156ea8da35a0ac095639f91e3c0490d4fcccaf2fe841be) · setBudget [`0xaf11889c…`](https://testnet.arcscan.app/tx/0xaf11889c867d456ef41010ec96212e9accd45222c9fbbd6814e1081cfcab6fe3) · fund [`0x920dd1f6…`](https://testnet.arcscan.app/tx/0x920dd1f6c444d2c901fd50121bbc40337ad2865bef56b4db2f5ebd2c1bf2b320) · submit [`0x2b44d9eb…`](https://testnet.arcscan.app/tx/0x2b44d9eb42ff9927e68fa88ad94da98f06d1174b82449fdab05c09e1401983c4) · complete [`0xed048696…`](https://testnet.arcscan.app/tx/0xed0486965e488dc95c9f30091a33f197f8eeb562bf5683d9ebdf611d3daa9c0f) | jobId=35308; 1 USDC escrowed + released; **WEEK 1 EXIT CRITERION MET** ✅ |

### Blockers

_(none yet)_

### Decisions / deviations

- **Solidity version → 0.8.28** (resolves conflict between `arc-dapp.md §8` `^0.8.28` and `CLAUDE.md §4` `0.8.27`). Per CLAUDE.md's own override clause ("spec overrides any conflict here except Rules 1–5"), the spec wins. `contracts/foundry.toml` pins `solc_version = "0.8.28"`; tests use `pragma solidity 0.8.28`.
- **EVM target → `paris`** (not Shanghai/Cancun). Source: `.claude/skills/use-smart-contract-platform/SKILL.md` — Solidity ≥ 0.8.20 emits `PUSH0` under default target, which has caused `ESTIMATION_ERROR` / `Create2: Failed on deploy` on Arc Testnet via Circle SCP. Pinning `evm_version = "paris"` removes `PUSH0` from output. Will re-evaluate when first real deploy lands.
- **Pinned dependency tags (reproducibility):**
  - `foundry-rs/forge-std@v1.16.1`
  - `OpenZeppelin/openzeppelin-contracts@v5.6.1`
  - `OpenZeppelin/openzeppelin-contracts-upgradeable@v5.6.1`
- **Node engine** declared as `>=20.18.0` in root `package.json` and pinned to `20` in `.nvmrc` per `CLAUDE.md §4`. The local runtime is Node 22.22.2; backwards compatible for the scaffold work, will switch via `nvm use` before the Next.js phase.
- **Workspaces** declared in `pnpm-workspace.yaml`: `app`, `agents`, `x402-server`, `mcp-server`, `indexer`, `packages/*` (matches `arc-dapp.md §9`). None exist yet; will be created as their respective phases begin.
- **Sanity test** at `contracts/test/Sanity.t.sol` is intentional throwaway. It will be deleted as soon as the first real Stratum contract test lands.
- **No commits yet.** Per `CLAUDE.md` git policy, commits only happen on explicit user request. The git repo is initialised on `main` with three submodules registered; nothing staged.

#### Deliverable 2 — interface files

- **Source-of-truth ranking applied:** EIP reference implementation > EIP spec text > `arc-dapp.md`. When the three disagree, the deployed contract (= reference impl on Arc) wins.
  - `fund` → `fund(uint256, bytes)` — no `expectedBudget`. Reference impl, matches arc-dapp.md.
  - `setProvider` → `setProvider(uint256, address)` — no `optParams`. Reference impl.
  - `giveFeedback` → uses EIP-8004 names (`value`, `valueDecimals`, `tag1`, `tag2`, `endpoint`, `feedbackURI`, `feedbackHash`). arc-dapp.md's old names (`score`, `type`, single `tag`) are obsolete.
- **`IIdentityRegistry` extends `IERC721` + `IERC721Metadata`** because the Identity Registry is an ERC-721 with URIStorage extension per EIP-8004. This is one of the few places where downstream contracts (StratumAgentCard) will need full NFT semantics.
- **`MetadataEntry` struct** is declared inside `IIdentityRegistry` (per EIP-8004's `register(string, MetadataEntry[])` overload).
- **Selector pinning test** (`contracts/test/Interfaces.t.sol`) compiles each canonical signature inline as `keccak256(...)` and asserts equality with the resolved interface selector. Any future signature drift will fail at compile time or test time.
- **`IUSYC.sol` + `IStableFX.sol` are deliberately not created.** Per Rule 4 ("treat as unknown" if not verifiable), neither `arc-dapp.md` nor the EIPs nor public docs reachable from §16 give exact onchain ABIs for the USYC Teller (`0xcc205224...`) or StableFX router (`0x867650F5...`). They will be derived from official Circle docs (`developers.circle.com/tokenized/usyc/overview`, `developers.circle.com/stablefx`) and verified contract source on `testnet.arcscan.app` at the start of Week 3 (Capital + FX), where they are first needed by `YieldVault.sol` / `FXRouter.sol`. Tracking item added to External-Tickets table.

#### Deliverable 3 — StratumJobFactory.sol

- **DEVIATION from `arc-dapp.md §11.4`: factory is a metadata sidecar, not a `createJob` proxy.** Rationale: the ERC-8183 reference implementation deployed at `0x0747EEf0...` gates every lifecycle action on `msg.sender` (`setBudget` is provider-only, `fund` is client-only, `submit` is provider-only, `complete`/`reject` are evaluator-only). If the factory called `createJob`, the factory would become the immutable `client` and the real user could never `fund` from their balance. The §11.4 sample code (`postJob` calling `createJob` then `setBudget`) cannot work against the deployed reference. Stratum factory therefore exposes `registerJob(jobId, ...)` instead — users call `IAgenticCommerce.createJob` themselves, then bind Stratum metadata via the factory. Documented in the contract's NatSpec.
- **Future enforcement hook (`requiredHook`).** Owner-pinned address; when non-zero, `registerJob` rejects any job whose ACP `hook` is not exactly that address. Default is `address(0)` (no enforcement). In Week 2, this will be set to the deployed `StratumReputationHook` so every Stratum-registered job guarantees feedback flows to ERC-8004 on completion.
- **Slot packing.** `StratumJobMeta` packs `creator (20)` + `createdAt (uint32, 4)` + `updatedAt (uint32, 4)` into one 32-byte slot (28 bytes used, 4 padding). `uint32` epoch seconds is safe through year 2106; `uint64` would have spilled into a second slot. `category (bytes32)` is its own slot. Strings/arrays are unavoidably dynamic.
- **DoS caps.** `MAX_TAGS = 16` and `MAX_URI_LEN = 256` bound storage costs. IPFS CIDs are 46–59 chars; `MAX_URI_LEN = 256` is generous. Both are `public constant`.
- **No fund custody.** Factory never holds tokens. Only external call is a single `acp.getJob(jobId)` view per write. `nonReentrant` not required.
- **Ownership = `Ownable2Step` (OZ 5.x).** Two-step transfer protects against typos in owner handover.
- **Coverage:** every custom error (9), every event (3), every public function exercised. Two fuzz tests (`testFuzz_RegisterJob_RandomTagCount` runs 256, `testFuzz_RegisterJob_RejectsNonClient` runs 256). Forge-lint clean. Gas profile: `registerJob` ≈ 230k–410k gas depending on hook check + tag length; `getJobMeta` is cold-storage view only.

#### Deliverable 4 — StratumAgentCard.sol

- **Same sidecar reasoning as JobFactory.** `IIdentityRegistry.register(string)` mints the ERC-721 to `msg.sender`; if Stratum proxied it, the agent NFT would be owned by Stratum, not the user. So users register their agent directly with ERC-8004 (e.g. via Circle Developer-Controlled Wallets per `arc-dapp.md §11.2`), then call `StratumAgentCard.linkAgent(agentId, category, tags)` to bind Stratum metadata.
- **AgentCard JSON validation deliberately stays off-chain.** `arc-dapp.md §7` describes this contract as "Validates AgentCard JSON" — but Solidity cannot parse JSON. The frontend and indexer perform schema validation against the AgentCard JSON shape (per EIP-8004) before allowing the user to call `linkAgent`. On-chain we enforce only ownership (caller MUST be `IIdentityRegistry.ownerOf(agentId)`) and input bounds (`category != bytes32(0)`, `tags.length <= MAX_TAGS = 16`). Documented in NatSpec.
- **NFT-transfer aware.** Ownership is re-checked at every `updateAgentMetadata` call. The post-transfer scenario is explicitly covered by two tests:
  - `test_UpdateAgentMetadata_NewOwnerCanRewriteAfterTransfer` (new owner can update after transfer)
  - `test_UpdateAgentMetadata_OldOwnerLocksOutAfterTransfer` (old owner is correctly locked out)
- **Linker preserved across updates** as historical attribution. The `linker` field records the address that first linked the agent; `updatedAt` tracks the most recent overwrite. Slot-packed: `linker (20)` + `linkedAt (uint32, 4)` + `updatedAt (uint32, 4)` = 28 bytes in slot 0.
- **No Ownable for now.** This contract has no admin functions in V1. KYB tier and verification badges (per `arc-dapp.md §4.9` elevator) are deferred. When added in v0.2 the contract will inherit `Ownable2Step`.
- **Mock pattern.** `MockIdentityRegistry` reverts with the canonical OZ 5.x `IERC721Errors.ERC721NonexistentToken(uint256)` error for unknown agent IDs, so tests assert against the same revert shape that the live ERC-8004 registry produces.

---

## Week 2 — Reputation, Validation, UI

**Goal (`arc-dapp.md §10`):** `StratumReputationHook` (IACPHook), whitelist on factory; one full job → confirm `giveFeedback` recorded; `StratumValidationOracle` (stub); agent worker; A2A endpoint; frontend agent list + job board + reputation; indexer.

**Exit criterion:** browse 3 agents, post job from UI, watch worker complete it, reputation ticks up.

### Tasks

| # | Task | Status | Skills used | Tx / address | Notes |
|---|---|---|---|---|---|
| 1 | `StratumReputationHook.sol` + tests | DONE 2026-05-21 | `test-foundry`, `audit`, `gas-optimize`, `use-arc`, `use-smart-contract-platform` | n/a | 127 LoC; 22 tests (20 unit + 2 fuzz); 79/79 total suite passing |
| 2 | Deploy Stratum-owned AgenticCommerce | DONE 2026-05-21 | `use-arc` | [`0x989c0f21…`](https://testnet.arcscan.app/tx/0x42a6ce1ac8ee3a4fe27236be4cb615047ef0a6eebca84611b2713ddd1cca75cd) | Non-upgradeable; we own admin; can whitelist hooks. Shared ACP at `0x0747EEf0…` doesn't grant ADMIN_ROLE to third parties |
| 3 | Deploy StratumReputationHook (pointing at Stratum ACP) | DONE 2026-05-21 | `use-arc` | [`0xdB80FdA4…`](https://testnet.arcscan.app/tx/0x08baea44e0a52b1c372b3034f6e1d9e04826e7aa651e54cab9ededab87f79163) | Immutables: acp=Stratum ACP, reputation=ERC-8004, identity=ERC-8004 |
| 4 | Full lifecycle WITH hook → giveFeedback fires | DONE 2026-05-21 | `use-arc` | [`0xb8ad3a12…`](https://testnet.arcscan.app/tx/0xb8ad3a1296b0b2abda6984d42d7a69c06061df6ffc48bc173f6bbd202f15dc99) | **6 events in complete tx**: JobCompleted + PaymentReleased + **NewFeedback** (0x8004B663…) + **FeedbackWritten** (hook). agentId=17868 received positive reputation ✅ |
| 5 | `StratumValidationOracle.sol` (stub) + tests + deploy | DONE 2026-05-21 | `test-foundry`, `audit`, `gas-optimize`, `use-arc` | [`0xCfc99136…`](https://testnet.arcscan.app/address/0xCfc99136D2BB8DA1C4C457667B9Cd15c418b94C9) | 69 LoC; 11 tests (9 unit + 2 fuzz); 90/90 total. Single oracle EOA, owner can rotate. |

### Blockers

_(none)_

### Decisions / deviations

- **Deployed our own AgenticCommerce** (`0x989c0f21…`) instead of using the shared reference at `0x0747EEf0…`. Reason: the shared instance requires `ADMIN_ROLE` to whitelist hooks, which is not granted to third parties. Our instance is non-upgradeable (simpler for testnet), uses the same ERC-8183 lifecycle logic, and gives us full admin control. The `StratumJobFactory` sidecar still works with any ACP address — just update `app/lib/contracts.ts`.
- **EVM version changed to `cancun`** (from `paris`). The shared ERC-8183 implementation uses `ReentrancyGuardTransient` which requires `TSTORE`/`TLOAD` (Cancun opcodes). Arc Testnet supports them (confirmed by the shared ACP working). Our previous contracts deployed under `paris` are unaffected since they don't use transient storage. Logged in `foundry.toml` comment.

---

## Week 3 — Capital + FX

_Not started. See `arc-dapp.md §10` Week 3._

---

## Week 4 — x402 + Polish + Submit

_Not started. See `arc-dapp.md §10` Week 4._

---

## Deployed Contracts

_All addresses also live in `app/lib/contracts.ts` and `contracts/script/Deploy.s.sol`._

| Contract | Address | Deploy tx | Verified | Notes |
|---|---|---|---|---|
| StratumJobFactory | [`0xad7157cE777c62273E2CADf8e81203bCBD23E1Fe`](https://testnet.arcscan.app/address/0xad7157cE777c62273E2CADf8e81203bCBD23E1Fe) | [`0xc6a8e48e5c1ddc15a76d42845076226dfccd071991f76d0cf9fb535054b541db`](https://testnet.arcscan.app/tx/0xc6a8e48e5c1ddc15a76d42845076226dfccd071991f76d0cf9fb535054b541db) | pending | Block 43323893; `acp()` returns `0x0747EEf0…` ✓ |
| StratumAgentCard | [`0xeE9a8Cb064b789071c15a6c5aBB25D570871E0eB`](https://testnet.arcscan.app/address/0xeE9a8Cb064b789071c15a6c5aBB25D570871E0eB) | [`0xc9b90ad750f7a5027d12dad014a30b02cf55dda7d91421e693e5117ddf210739`](https://testnet.arcscan.app/tx/0xc9b90ad750f7a5027d12dad014a30b02cf55dda7d91421e693e5117ddf210739) | pending | Block 43323893; `identity()` returns `0x8004A818…` ✓ |
| AgenticCommerce (Stratum-owned) | [`0x989c0f21c712EecF8bD7AB1caf1A8Ba3da88a46f`](https://testnet.arcscan.app/address/0x989c0f21c712EecF8bD7AB1caf1A8Ba3da88a46f) | [`0x42a6ce1a…`](https://testnet.arcscan.app/tx/0x42a6ce1ac8ee3a4fe27236be4cb615047ef0a6eebca84611b2713ddd1cca75cd) | pending | Non-upgradeable; admin=deployer; paymentToken=USDC |
| StratumReputationHook | [`0xdB80FdA455f8e8f83Ba8B3882abd09708229D42E`](https://testnet.arcscan.app/address/0xdB80FdA455f8e8f83Ba8B3882abd09708229D42E) | [`0x08baea44…`](https://testnet.arcscan.app/tx/0x08baea44e0a52b1c372b3034f6e1d9e04826e7aa651e54cab9ededab87f79163) | pending | acp=Stratum ACP; giveFeedback verified in tx `0xb8ad3a12…` |
| StratumValidationOracle | [`0xCfc99136D2BB8DA1C4C457667B9Cd15c418b94C9`](https://testnet.arcscan.app/address/0xCfc99136D2BB8DA1C4C457667B9Cd15c418b94C9) | [`0x5afc5f7f…`](https://testnet.arcscan.app/tx/0x5afc5f7f1d3a26b25b8a3c1b82a23c08887b2b3fef7d33e5b5361fba87c984d9) | pending | Stub; oracle=deployer; forwards to ERC-8004 Validation Registry |

---

## External Tickets / Async Work

| Item | Filed | Status | Notes |
|---|---|---|---|
| USYC allowlist (Circle Support) | _pending_ | _pending_ | File on Day 1 — 24-48h lead time |
| Circle Console API key + Entity Secret | _pending_ | _pending_ | `console.circle.com` |
| Pinata account (IPFS free tier) | _pending_ | _pending_ | for AgentCards + deliverables |
| Goldsky project (free tier indexer) | _pending_ | _pending_ | week 2 |
| `IUSYC.sol` interface (Teller `0xcc205224...`) | _pending_ | _pending_ | Verify ABI from `developers.circle.com/tokenized/usyc/overview` + arcscan source at start of Week 3 |
| `IStableFX.sol` interface (Router `0x867650F5...`) | _pending_ | _pending_ | Verify ABI from `developers.circle.com/stablefx` + arcscan source at start of Week 3 |

---
