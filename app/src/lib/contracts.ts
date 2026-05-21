// Contract addresses — single source of truth.
// Mirrors the root app/lib/contracts.ts but co-located in the Next.js src/ for imports.

export const contracts = {
  // Arc primitives
  usdc: "0x3600000000000000000000000000000000000000",
  erc8004Identity: "0x8004A818BFB912233c491871b3d84c89A494BD9e",
  erc8004Reputation: "0x8004B663056A597Dffe9eCcC1965A193B7388713",
  erc8004Validation: "0x8004Cb1BF31DAf7788923b405b754f57acEB4272",

  // Stratum-deployed
  stratumAcp: "0x989c0f21c712EecF8bD7AB1caf1A8Ba3da88a46f",
  jobFactory: "0xad7157cE777c62273E2CADf8e81203bCBD23E1Fe",
  agentCard: "0xeE9a8Cb064b789071c15a6c5aBB25D570871E0eB",
  reputationHook: "0xdB80FdA455f8e8f83Ba8B3882abd09708229D42E",
  validationOracle: "0xCfc99136D2BB8DA1C4C457667B9Cd15c418b94C9",
} as const;
