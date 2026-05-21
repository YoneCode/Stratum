import express from "express";
import { summarize } from "./routes/summarize.js";
import { fxquote } from "./routes/fxquote.js";
import { translate } from "./routes/translate.js";

const app = express();
app.use(express.json());

const PORT = process.env.X402_SERVER_PORT || 4402;
const MERCHANT = process.env.MERCHANT_ADDRESS || "0x057442C1788c349891F86C09050C8bC1dc68392B";

// x402 middleware: if no payment header, return 402 with payment requirements
function x402Gate(price, resource, description) {
  return (req, res, next) => {
    const paymentSig = req.headers["payment-signature"];
    if (!paymentSig) {
      return res.status(402).json({
        x402Version: 1,
        accepts: [{
          scheme: "exact",
          network: "arcTestnet",
          asset: "0x3600000000000000000000000000000000000000",
          maxAmountRequired: String(price),
          payTo: MERCHANT,
          resource: `https://api.stratum.dev${resource}`,
          description,
        }],
      });
    }
    // In production: verify EIP-3009 signature, queue for batch settlement
    // For testnet demo: accept any non-empty header
    req.paymentVerified = true;
    next();
  };
}

app.get("/summarize", x402Gate(1000, "/summarize", "Summarize text via Stratum"), summarize);
app.get("/fxquote", x402Gate(500, "/fxquote", "Get FX quote USDC/EURC"), fxquote);
app.get("/translate", x402Gate(2000, "/translate", "Translate text"), translate);

app.get("/health", (_, res) => res.json({ status: "ok", merchant: MERCHANT }));

app.listen(PORT, () => {
  console.log(`[x402] Stratum x402 server running on :${PORT}`);
  console.log(`[x402] Merchant: ${MERCHANT}`);
  console.log(`[x402] Endpoints: /summarize ($0.001), /fxquote ($0.0005), /translate ($0.002)`);
});
