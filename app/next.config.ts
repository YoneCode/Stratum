import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // Disable all restrictive headers for testnet demo
  async headers() {
    return [
      {
        source: "/(.*)",
        headers: [
          {
            key: "X-Content-Type-Options",
            value: "nosniff",
          },
        ],
      },
    ];
  },
  // Suppress the default CSP that Next.js adds
  experimental: {
    serverActions: {
      allowedOrigins: ["*"],
    },
  },
};

export default nextConfig;
