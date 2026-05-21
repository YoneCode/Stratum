"use client";

import { useState } from "react";
import { useAccount, useConnect, useWriteContract, useWaitForTransactionReceipt } from "wagmi";
import { parseAbi } from "viem";
import { contracts } from "@/lib/contracts";

const acpAbi = parseAbi([
  "function createJob(address provider, address evaluator, uint256 expiredAt, string description, address hook) returns (uint256)",
]);

export default function NewJobPage() {
  const { address, isConnected } = useAccount();
  const { connect, connectors } = useConnect();
  const { writeContract, data: hash, isPending } = useWriteContract();
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({ hash });

  const [provider, setProvider] = useState("");
  const [description, setDescription] = useState("");

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!address) return;

    const expiry = BigInt(Math.floor(Date.now() / 1000) + 86400); // 24h
    const hook = contracts.reputationHook as `0x${string}`;
    const providerAddr = (provider || address) as `0x${string}`;

    writeContract({
      address: contracts.stratumAcp as `0x${string}`,
      abi: acpAbi,
      functionName: "createJob",
      args: [providerAddr, address, expiry, description, hook],
    });
  };

  return (
    <main className="mx-auto max-w-2xl px-6 py-16">
      <h1 className="text-3xl font-bold">Post a Job</h1>
      <p className="mt-2 text-neutral-400">Create an ERC-8183 escrowed job on Stratum ACP</p>

      {!isConnected ? (
        <div className="mt-8">
          <p className="mb-4 text-neutral-400">Connect your wallet to post a job.</p>
          {connectors.map((connector) => (
            <button
              key={connector.id}
              onClick={() => connect({ connector })}
              className="mr-3 rounded-lg bg-neutral-800 px-4 py-2 text-sm font-medium hover:bg-neutral-700"
            >
              {connector.name}
            </button>
          ))}
        </div>
      ) : (
        <form onSubmit={handleSubmit} className="mt-8 space-y-6">
          <div>
            <label className="block text-sm font-medium text-neutral-300">Description</label>
            <textarea
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              required
              rows={3}
              className="mt-1 w-full rounded-lg border border-neutral-700 bg-neutral-900 px-4 py-2 text-sm"
              placeholder="e.g. Summarize the EU AI Act Article 6 compliance requirements"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-neutral-300">
              Provider address <span className="text-neutral-500">(optional — defaults to you)</span>
            </label>
            <input
              value={provider}
              onChange={(e) => setProvider(e.target.value)}
              className="mt-1 w-full rounded-lg border border-neutral-700 bg-neutral-900 px-4 py-2 text-sm font-mono"
              placeholder="0x..."
            />
          </div>

          <div className="text-xs text-neutral-500">
            Evaluator: you ({address?.slice(0, 6)}…{address?.slice(-4)}) • Hook: ReputationHook • Expiry: 24h
          </div>

          <button
            type="submit"
            disabled={isPending || isConfirming}
            className="rounded-lg bg-white px-6 py-2.5 text-sm font-medium text-black transition hover:bg-neutral-200 disabled:opacity-50"
          >
            {isPending ? "Signing..." : isConfirming ? "Confirming..." : "Create Job"}
          </button>

          {isSuccess && hash && (
            <p className="text-sm text-green-400">
              ✅ Job created!{" "}
              <a
                href={`https://testnet.arcscan.app/tx/${hash}`}
                target="_blank"
                rel="noopener noreferrer"
                className="underline"
              >
                View on ArcScan
              </a>
            </p>
          )}
        </form>
      )}
    </main>
  );
}
