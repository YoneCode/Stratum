"use client";

import { PrivyProvider } from "@privy-io/react-auth";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { WagmiProvider, createConfig, http } from "wagmi";
import { arcTestnet } from "@/lib/chain";
import { useState, type ReactNode } from "react";

const wagmiConfig = createConfig({
  chains: [arcTestnet],
  transports: { [arcTestnet.id]: http() },
});

export function Providers({ children }: { children: ReactNode }) {
  const [queryClient] = useState(() => new QueryClient());
  const privyAppId = process.env.NEXT_PUBLIC_PRIVY_APP_ID;

  // Privy requires a valid app ID. Without one, render children without Privy.
  if (!privyAppId || privyAppId === "placeholder") {
    return (
      <QueryClientProvider client={queryClient}>
        <WagmiProvider config={wagmiConfig}>{children}</WagmiProvider>
      </QueryClientProvider>
    );
  }

  return (
    <PrivyProvider
      appId={privyAppId}
      config={{
        appearance: { theme: "dark" },
        supportedChains: [arcTestnet],
        defaultChain: arcTestnet,
      }}
    >
      <QueryClientProvider client={queryClient}>
        <WagmiProvider config={wagmiConfig}>{children}</WagmiProvider>
      </QueryClientProvider>
    </PrivyProvider>
  );
}
