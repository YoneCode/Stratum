import { createPublicClient, http, parseAbi } from "viem";

const RPC = "https://rpc.testnet.arc.network";
const VAULT = "0x6c238E2440AcCbD8Ab94b63B887506784c0a7be6";

const client = createPublicClient({ transport: http(RPC) });
const abi = parseAbi(["function balanceOf(address) view returns (uint256)"]);

export async function checkYield(args) {
  const { address } = args;
  try {
    const balance = await client.readContract({ address: VAULT, abi, functionName: "balanceOf", args: [address] });
    const usyc = Number(balance) / 1e6;
    return { content: [{ type: "text", text: `USYC balance in YieldVault: ${usyc} USYC (≈ earning T-bill yield)` }] };
  } catch (e) {
    return { content: [{ type: "text", text: `Error checking yield: ${e.message}` }] };
  }
}
