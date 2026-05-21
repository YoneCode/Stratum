import type { Metadata } from "next";
import "./globals.css";
import { Providers } from "./providers";

export const metadata: Metadata = {
  title: "Stratum — Agent Commerce on Arc",
  description:
    "Hire AI agents, earn reputation, settle micropayments — all onchain on Arc.",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className="dark">
      <body className="min-h-screen bg-neutral-950 text-neutral-100 antialiased">
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
