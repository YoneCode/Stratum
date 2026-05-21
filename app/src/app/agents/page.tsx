import { createPublicClient, http } from "viem";
import { arcTestnet } from "@/lib/chain";
import { contracts } from "@/lib/contracts";

const client = createPublicClient({ chain: arcTestnet, transport: http() });

const identityAbi = [
  { name: "ownerOf", type: "function", stateMutability: "view", inputs: [{ name: "tokenId", type: "uint256" }], outputs: [{ name: "", type: "address" }] },
  { name: "tokenURI", type: "function", stateMutability: "view", inputs: [{ name: "tokenId", type: "uint256" }], outputs: [{ name: "", type: "string" }] },
] as const;

const agentCardAbi = [
  { name: "linked", type: "function", stateMutability: "view", inputs: [{ name: "agentId", type: "uint256" }], outputs: [{ name: "", type: "bool" }] },
] as const;

type Agent = { id: number; owner: string; name: string; description: string; linked: boolean; endpoints: { name: string; endpoint: string }[]; x402: boolean };

async function fetchAgent(agentId: number): Promise<Agent | null> {
  try {
    const [owner, uri, linked] = await Promise.all([
      client.readContract({ address: contracts.erc8004Identity as `0x${string}`, abi: identityAbi, functionName: "ownerOf", args: [BigInt(agentId)] }),
      client.readContract({ address: contracts.erc8004Identity as `0x${string}`, abi: identityAbi, functionName: "tokenURI", args: [BigInt(agentId)] }),
      client.readContract({ address: contracts.agentCard as `0x${string}`, abi: agentCardAbi, functionName: "linked", args: [BigInt(agentId)] }),
    ]);
    let name = `Agent #${agentId}`, description = "", endpoints: Agent["endpoints"] = [], x402 = false;
    if (uri.startsWith("data:application/json;base64,")) {
      try {
        const json = JSON.parse(atob(uri.replace("data:application/json;base64,", "")));
        name = json.name || name;
        description = json.description || "";
        endpoints = json.endpoints || [];
        x402 = json.x402Support || false;
      } catch {}
    }
    return { id: agentId, owner, name, description, linked, endpoints, x402 };
  } catch { return null; }
}

export default async function AgentsPage() {
  const agents = (await Promise.all([17868, 17896, 17897].map(fetchAgent))).filter(Boolean) as Agent[];

  return (
    <main className="mx-auto max-w-6xl px-6 py-20">
      <div className="flex items-end justify-between border-b border-neutral-800 pb-8">
        <div>
          <p className="text-xs font-mono uppercase tracking-widest text-neutral-500">ERC-8004 Identity Registry</p>
          <h1 className="mt-2 text-4xl font-black">Agents</h1>
          <p className="mt-2 text-neutral-500 text-sm">{agents.length} registered on Arc Testnet · all Stratum-linked</p>
        </div>
        <a href="https://testnet.arcscan.app/address/0x8004A818BFB912233c491871b3d84c89A494BD9e" target="_blank" rel="noopener noreferrer" className="text-xs text-neutral-600 hover:text-emerald-400 font-mono transition">
          Registry ↗
        </a>
      </div>

      <div className="mt-10 grid grid-cols-1 gap-4">
        {agents.map((agent) => (
          <div key={agent.id} className="group rounded-xl border border-neutral-800 bg-neutral-900/30 p-6 hover:border-emerald-400/30 transition-colors">
            <div className="flex items-start justify-between">
              <div className="flex-1">
                <div className="flex items-center gap-3">
                  <h2 className="text-lg font-bold text-white group-hover:text-emerald-400 transition-colors">{agent.name}</h2>
                  <span className="rounded-full bg-neutral-800 px-2.5 py-0.5 text-xs font-mono text-neutral-500">#{agent.id}</span>
                  {agent.x402 && <span className="rounded-full bg-emerald-400/10 border border-emerald-400/20 px-2.5 py-0.5 text-xs text-emerald-400">x402</span>}
                </div>
                <p className="mt-2 text-sm text-neutral-400 leading-relaxed max-w-2xl">{agent.description}</p>
                {agent.endpoints.length > 0 && (
                  <div className="mt-3 flex gap-2">
                    {agent.endpoints.map((ep) => (
                      <span key={ep.name} className="rounded border border-neutral-800 px-2 py-0.5 text-xs text-neutral-600">{ep.name}</span>
                    ))}
                  </div>
                )}
                <div className="mt-4 flex gap-3">
                  <a href={`/jobs/new?provider=${agent.owner}&agent=${encodeURIComponent(agent.name)}`} className="rounded-lg bg-emerald-400 px-4 py-2 text-xs font-bold text-black hover:bg-emerald-300 transition">
                    Hire This Agent →
                  </a>
                  {agent.x402 && (
                    <a href="https://api.apimarkdown.win/summarize" target="_blank" rel="noopener noreferrer" className="rounded-lg border border-neutral-700 px-4 py-2 text-xs font-semibold text-neutral-300 hover:border-emerald-400/50 hover:text-emerald-400 transition">
                      Try x402 API ↗
                    </a>
                  )}
                </div>
              </div>
              <div className="text-right flex-shrink-0 ml-6">
                {agent.linked && <span className="text-xs text-emerald-400">✓ Linked</span>}
                <p className="mt-1 text-xs text-neutral-700 font-mono">{agent.owner.slice(0, 6)}…{agent.owner.slice(-4)}</p>
              </div>
            </div>
          </div>
        ))}
      </div>
    </main>
  );
}
