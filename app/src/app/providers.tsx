"use client";

import { type ReactNode } from "react";

// Privy + wagmi loaded ONLY on interaction (dynamic import) to avoid
// eval crashes from wallet extensions (Phantom, MetaMask, OKX) on initial hydration.
export function Providers({ children }: { children: ReactNode }) {
  return <>{children}</>;
}
