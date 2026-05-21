"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

const NAV_ITEMS = [
  { href: "/agents", label: "Agents" },
  { href: "/jobs", label: "Jobs" },
  { href: "/jobs/new", label: "Post Job" },
  { href: "/dashboard", label: "Dashboard" },
];

export function Header() {
  const pathname = usePathname();

  return (
    <header className="border-b border-neutral-800 bg-neutral-950/80 backdrop-blur-sm sticky top-0 z-50">
      <div className="mx-auto flex max-w-6xl items-center justify-between px-6 py-3">
        <div className="flex items-center gap-8">
          <Link href="/" className="text-lg font-bold tracking-tight">
            Stratum
          </Link>
          <nav className="hidden md:flex items-center gap-1">
            {NAV_ITEMS.map(({ href, label }) => (
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
        <div className="flex items-center gap-3">
          <span className="rounded-md bg-neutral-800 px-2 py-1 text-xs text-neutral-500">Arc Testnet</span>
          <a
            href="https://testnet.arcscan.app/address/0x989c0f21c712EecF8bD7AB1caf1A8Ba3da88a46f"
            target="_blank"
            rel="noopener noreferrer"
            className="rounded-md bg-white px-4 py-1.5 text-xs font-medium text-black hover:bg-neutral-200"
          >
            View on ArcScan
          </a>
        </div>
      </div>
    </header>
  );
}
