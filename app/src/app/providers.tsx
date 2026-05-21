"use client";

import { PrivyProvider } from "@privy-io/react-auth";
import { type ReactNode } from "react";
import { arcTestnet } from "@/lib/chain";

export function Providers({ children }: { children: ReactNode }) {
  return (
    <PrivyProvider
      appId="cmpfewdt500bl0cl7vd23on0y"
      config={{
        appearance: { theme: "dark" },
        supportedChains: [arcTestnet],
        defaultChain: arcTestnet,
      }}
    >
      {children}
    </PrivyProvider>
  );
}
