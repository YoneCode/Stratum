"use client";

import { type ReactNode } from "react";

// Privy + wagmi disabled temporarily — wallet extension conflicts cause
// "eval" crashes during hydration. Re-enable once Privy app ID is configured
// and the CSP issue is resolved with a proper nonce strategy.
export function Providers({ children }: { children: ReactNode }) {
  return <>{children}</>;
}
