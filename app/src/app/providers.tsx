"use client";

import { type ReactNode } from "react";

// Privy is NOT loaded on initial render to avoid eval crashes from wallet extensions.
// It's loaded dynamically only when user clicks Connect (see Header).
export function Providers({ children }: { children: ReactNode }) {
  return <>{children}</>;
}
