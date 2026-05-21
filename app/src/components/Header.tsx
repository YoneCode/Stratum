"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useAccount, useConnect, useDisconnect } from "wagmi";

const NAV_ITEMS = [
  { href: "/", label: "Home" },
  { href: "/agents", label: "Agents" },
  { href: "/jobs", label: "Jobs" },
  { href: "/jobs/new", label: "Post Job" },
  { href: "/dashboard", label: "Dashboard" },
];

export function Header() {
  const pathname = usePathname();
  const { address, isConnected } = useAccount();
  const { connect, connectors } = useConnect();
  const { disconnect } = useDisconnect();

  return (
    <header className="border-b border-neutral-800 bg-neutral-950/80 backdrop-blur-sm sticky top-0 z-50">
      <div className="mx-auto flex max-w-6xl items-center justify-between px-6 py-3">
        <div className="flex items-center gap-8">
          <Link href="/" className="text-lg font-bold tracking-tight">
            Stratum
          </Link>
          <nav className="hidden md:flex items-center gap-1">
            {NAV_ITEMS.slice(1).map(({ href, label }) => (
              <Link
                key={href}
                href={href}
                className={`rounded-md px-3 py-1.5 text-sm transition ${
                  pathname === href
                    ? "bg-neutral-800 text-white"
                    : "text-neutral-400 hover:text-white hover:bg-neutral-800/50"
                }`}
              >
                {label}
              </Link>
            ))}
          </nav>
        </div>

        <div>
          {isConnected ? (
            <button
              onClick={() => disconnect()}
              className="rounded-md bg-neutral-800 px-3 py-1.5 text-xs font-mono text-neutral-300 hover:bg-neutral-700"
            >
              {address?.slice(0, 6)}…{address?.slice(-4)}
            </button>
          ) : (
            <button
              onClick={() => connectors[0] && connect({ connector: connectors[0] })}
              className="rounded-md bg-white px-4 py-1.5 text-xs font-medium text-black hover:bg-neutral-200"
            >
              Connect
            </button>
          )}
        </div>
      </div>
    </header>
  );
}
