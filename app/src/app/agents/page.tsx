import { createPublicClient, http } from "viem";
import { arcTestnet } from "@/lib/chain";
import { contracts } from "@/lib/contracts";

const client = createPublicClient({
  chain: arcTestnet,
  transport: http(),
});

// Minimal ABI for reading agent data
const identityAbi = [
  {
    name: "ownerOf",
    type: "function",
    stateMutability: "view",
    inputs: [{ name: "tokenId", type: "uint256" }],
    outputs: [{ name: "", type: "address" }],
  },
  {
    name: "tokenURI",
    type: "function",
    stateMutability: "view",
    inputs: [{ name: "tokenId", type: "uint256" }],
    outputs: [{ name: "", type: "string" }],
  },
] as const;

const agentCardAbi = [
  {
    name: "linked",
    type: "function",
    stateMutability: "view",
    inputs: [{ name: "agentId", type: "uint256" }],
    outputs: [{ name: "", type: "bool" }],
  },
] as const;

const reputationAbi = [
  {
    name: "getLastIndex",
    type: "function",
    stateMutability: "view",
    inputs: [
      { name: "agentId", type: "uint256" },
      { name: "clientAddress", type: "address" },
    ],
    outputs: [{ name: "", type: "uint64" }],
  },
] as const;

type Agent = {
  id: number;
  owner: string;
  uri: string;
  name: string;
  description: string;
  linked: boolean;
  feedbackCount: number;
};

async function fetchAgent(agentId: number): Promise<Agent | null> {
  try {
    const [owner, uri, linked] = await Promise.all([
      client.readContract({
        address: contracts.erc8004Identity as `0x${string}`,
        abi: identityAbi,
        functionName: "ownerOf",
        args: [BigInt(agentId)],
      }),
      client.readContract({
        address: contracts.erc8004Identity as `0x${string}`,
        abi: identityAbi,
        functionName: "tokenURI",
        args: [BigInt(agentId)],
      }),
      client.readContract({
        address: contracts.agentCard as `0x${string}`,
        abi: agentCardAbi,
        functionName: "linked",
        args: [BigInt(agentId)],
      }),
    ]);

    // Try to get feedback count (non-critical)
    let feedbackCount = 0;
    try {
      const count = await client.readContract({
        address: contracts.erc8004Reputation as `0x${string}`,
        abi: reputationAbi,
        functionName: "getLastIndex",
        args: [BigInt(agentId), owner],
      });
      feedbackCount = Number(count);
    } catch {}

    // Decode data URI if present
    let name = `Agent #${agentId}`;
    let description = "";
    if (uri.startsWith("data:application/json;base64,")) {
      try {
        const json = JSON.parse(atob(uri.replace("data:application/json;base64,", "")));
        name = json.name || name;
        description = json.description || "";
      } catch {}
    }

    return { id: agentId, owner, uri, name, description, linked, feedbackCount };
  } catch {
    return null;
  }
}

export default async function AgentsPage() {
  // Fetch our known agent + a few recent ones to demonstrate
  const knownIds = [17868, 17896, 17897]; // LegalBot, FXQuoter, Summarizer
  const agents = (await Promise.all(knownIds.map(fetchAgent))).filter(Boolean) as Agent[];

  return (
    <main className="mx-auto max-w-4xl px-6 py-16">
      <h1 className="text-3xl font-bold">Agents</h1>
      <p className="mt-2 text-neutral-400">
        Registered on ERC-8004 Identity Registry • Arc Testnet
      </p>

      <div className="mt-8 space-y-4">
        {agents.map((agent) => (
          <div
            key={agent.id}
            className="rounded-lg border border-neutral-800 bg-neutral-900 p-6"
          >
            <div className="flex items-start justify-between">
              <div>
                <h2 className="text-xl font-semibold">{agent.name}</h2>
                <p className="mt-1 text-sm text-neutral-400">{agent.description}</p>
              </div>
              <span className="rounded bg-neutral-800 px-2 py-1 text-xs font-mono">
                #{agent.id}
              </span>
            </div>
            <div className="mt-4 flex gap-4 text-xs text-neutral-500">
              <span>Owner: {agent.owner.slice(0, 6)}…{agent.owner.slice(-4)}</span>
              {agent.linked && (
                <span className="text-green-400">✓ Stratum linked</span>
              )}
              {agent.feedbackCount > 0 && (
                <span className="text-blue-400">⭐ {agent.feedbackCount} feedback</span>
              )}
            </div>
          </div>
        ))}

        {agents.length === 0 && (
          <p className="text-neutral-500">No agents found.</p>
        )}
      </div>
    </main>
  );
}
