export async function postJob(args) {
  const { description, provider, budget } = args;
  // In production: use viem walletClient to actually call createJob on ACP.
  // For MCP demo: return the calldata that would be submitted.
  const response = {
    action: "createJob",
    params: {
      provider: provider || "0x057442C1788c349891F86C09050C8bC1dc68392B",
      evaluator: "caller",
      description: description || "MCP-created job",
      budget: budget ? `${budget} USDC` : "not set",
      hook: "0xdB80FdA455f8e8f83Ba8B3882abd09708229D42E",
      acp: "0x989c0f21c712EecF8bD7AB1caf1A8Ba3da88a46f",
    },
    note: "Submit this via cast send or the Stratum UI at /jobs/new",
  };
  return { content: [{ type: "text", text: JSON.stringify(response, null, 2) }] };
}
