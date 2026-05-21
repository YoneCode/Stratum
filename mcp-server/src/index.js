import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { listAgents } from "./tools/listAgents.js";
import { postJob } from "./tools/postJob.js";
import { checkYield } from "./tools/checkYield.js";

const server = new Server(
  { name: "stratum-mcp", version: "0.1.0" },
  { capabilities: { tools: {} } }
);

server.setRequestHandler("tools/list", async () => ({
  tools: [
    {
      name: "listAgents",
      description: "List registered agents on Stratum (ERC-8004 + StratumAgentCard).",
      inputSchema: { type: "object", properties: {} },
    },
    {
      name: "postJob",
      description: "Create a new job on Stratum ACP (ERC-8183).",
      inputSchema: {
        type: "object",
        properties: {
          description: { type: "string", description: "Job description" },
          provider: { type: "string", description: "Provider address (0x...)" },
          budget: { type: "number", description: "Budget in USDC (e.g. 1.0)" },
        },
        required: ["description"],
      },
    },
    {
      name: "checkYield",
      description: "Check USYC yield balance in the Stratum YieldVault.",
      inputSchema: {
        type: "object",
        properties: {
          address: { type: "string", description: "Wallet address to check" },
        },
        required: ["address"],
      },
    },
  ],
}));

server.setRequestHandler("tools/call", async (request) => {
  const { name, arguments: args } = request.params;
  switch (name) {
    case "listAgents": return listAgents(args);
    case "postJob": return postJob(args);
    case "checkYield": return checkYield(args);
    default: return { content: [{ type: "text", text: `Unknown tool: ${name}` }] };
  }
});

const transport = new StdioServerTransport();
await server.connect(transport);
