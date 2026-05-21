# Stratum

> Arc-native agent commerce stack. ERC-8004 identity + ERC-8183 jobs + USYC yield + StableFX + x402 nanopayments — one product, eight Arc/Circle primitives.

**Source of truth:** [`arc-dapp.md`](./arc-dapp.md) (full spec) and [`CLAUDE.md`](./CLAUDE.md) (working rules).
**Progress log:** [`PROGRESS.md`](./PROGRESS.md).

---

## Quickstart (will fill in as the build progresses)

```bash
# Toolchain
nvm use                    # pins Node 20 LTS via .nvmrc
pnpm install               # workspace install (root)

# Contracts
pnpm build:contracts       # forge build
pnpm test:contracts        # forge test -vvv
```

## Repo layout

See [`arc-dapp.md §9`](./arc-dapp.md). Workspace packages: `app/`, `agents/`, `x402-server/`, `mcp-server/`, `indexer/`. Contracts live under `contracts/` (Foundry).
