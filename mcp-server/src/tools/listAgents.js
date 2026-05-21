import { createPublicClient, http, parseAbi } from "viem";

const RPC = "https://rpc.testnet.arc.network";
const IDENTITY = "0x8004A818BFB912233c491871b3d84c89A494BD9e";
const AGENT_IDS = [17868, 17896, 17897];

const client = createPublicClient({ transport: http(RPC) });
const abi = parseAbi(["function tokenURI(uint256) view returns (string)"]);

export async function listAgents() {
  const agents = [];
  for (const id of AGENT_IDS) {
    try {
      const uri = await client.readContract({ address: IDENTITY, abi, functionName: "tokenURI", args: [BigInt(id)] });
      let name = `Agent #${id}`;
      if (uri.startsWith("data:application/json;base64,")) {
        const json = JSON.parse(atob(uri.replace("data:application/json;base64,", "")));
        name = json.name || name;
      }
      agents.push({ id, name });
    } catch { agents.push({ id, name: `Agent #${id} (error)` }); }
  }
  return { content: [{ type: "text", text: JSON.stringify(agents, null, 2) }] };
}
