"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState, useCallback, lazy, Suspense } from "react";

const NAV_ITEMS = [
  { href: "/agents", label: "Agents" },
  { href: "/jobs", label: "Jobs" },
  { href: "/jobs/new", label: "Post Job" },
  { href: "/dashboard", label: "Dashboard" },
];

// Lazy-load Privy only when Connect is clicked
const PrivyModal = lazy(() => import("./PrivyModal"));

export function Header() {
  const pathname = usePathname();
  const [showPrivy, setShowPrivy] = useState(false);
  const [address, setAddress] = useState<string | null>(null);

  const handleConnect = useCallback(() => {
    setShowPrivy(true);
  }, []);

  return (
    <>
      <header className="border-b border-neutral-800 bg-neutral-950/80 backdrop-blur-sm sticky top-0 z-50">
        <div className="mx-auto flex max-w-6xl items-center justify-between px-6 py-3">
          <div className="flex items-center gap-8">
            <Link href="/" className="text-lg font-bold tracking-tight">Stratum</Link>
            <nav className="hidden md:flex items-center gap-1">
              {NAV_ITEMS.map(({ href, label }) => (
                <Link key={href} href={href} className={`rounded-md px-3 py-1.5 text-sm transition ${pathname === href ? "bg-neutral-800 text-white" : "text-neutral-400 hover:text-white hover:bg-neutral-800/50"}`}>
                  {label}
                </Link>
              ))}
            </nav>
          </div>
          <div className="flex items-center gap-3">
            <span className="rounded-md bg-neutral-800 px-2 py-1 text-xs text-neutral-500">Arc Testnet</span>
            {address ? (
              <span className="rounded-md bg-emerald-400/10 border border-emerald-400/20 px-3 py-1.5 text-xs font-mono text-emerald-400">
                {address.slice(0, 6)}…{address.slice(-4)}
              </span>
            ) : (
              <button onClick={handleConnect} className="rounded-md bg-emerald-400 px-4 py-1.5 text-xs font-bold text-black hover:bg-emerald-300 transition">
                Connect
              </button>
            )}
          </div>
        </div>
      </header>
      {showPrivy && (
        <Suspense fallback={null}>
          <PrivyModal onConnected={(addr) => { setAddress(addr); setShowPrivy(false); }} />
        </Suspense>
      )}
    </>
  );
}
