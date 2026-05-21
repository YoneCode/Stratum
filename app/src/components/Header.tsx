"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState, useCallback } from "react";

const NAV_ITEMS = [
  { href: "/agents", label: "Agents" },
  { href: "/jobs", label: "Jobs" },
  { href: "/jobs/new", label: "Post Job" },
  { href: "/dashboard", label: "Dashboard" },
];

export function Header() {
  const pathname = usePathname();
  const [address, setAddress] = useState<string | null>(null);

  const handleConnect = useCallback(async () => {
    try {
      const eth = (window as any).ethereum;
      if (!eth) { alert("No wallet extension found. Install Rabby, MetaMask, etc."); return; }
      const accounts = await eth.request({ method: "eth_requestAccounts" });
      if (accounts[0]) {
        setAddress(accounts[0]);
        // Switch to Arc Testnet
        try {
          await eth.request({ method: "wallet_switchEthereumChain", params: [{ chainId: "0x4CEF52" }] });
        } catch (e: any) {
          if (e.code === 4902) {
            await eth.request({ method: "wallet_addEthereumChain", params: [{ chainId: "0x4CEF52", chainName: "Arc Testnet", rpcUrls: ["https://rpc.testnet.arc.network"], nativeCurrency: { name: "USDC", symbol: "USDC", decimals: 6 }, blockExplorerUrls: ["https://testnet.arcscan.app"] }] });
          }
        }
      }
    } catch (err) { console.error("Connect failed:", err); }
  }, []);

  return (
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
  );
}
