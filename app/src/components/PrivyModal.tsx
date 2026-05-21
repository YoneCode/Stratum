"use client";

import { useEffect } from "react";
import { PrivyProvider, usePrivy } from "@privy-io/react-auth";
import { arcTestnet } from "@/lib/chain";

function Inner({ onConnected }: { onConnected: (addr: string) => void }) {
  const { login, authenticated, user } = usePrivy();

  useEffect(() => {
    if (authenticated && user?.wallet?.address) {
      onConnected(user.wallet.address);
    } else {
      login();
    }
  }, [authenticated, user, login, onConnected]);

  return null;
}

export default function PrivyModal({ onConnected }: { onConnected: (addr: string) => void }) {
  return (
    <PrivyProvider
      appId="cmpfewdt500bl0cl7vd23on0y"
      config={{
        appearance: { theme: "dark" },
        supportedChains: [arcTestnet],
        defaultChain: arcTestnet,
      }}
    >
      <Inner onConnected={onConnected} />
    </PrivyProvider>
  );
}
