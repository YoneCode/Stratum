export function fxquote(req, res) {
  const { from = "USDC", to = "EURC", amount = "100" } = req.query;
  // Mock FX rate (production would query StableFX API)
  const rate = from === "USDC" ? 0.92 : 1.087;
  const output = (parseFloat(amount) * rate).toFixed(6);
  res.json({ from, to, amountIn: amount, amountOut: output, rate, provider: "stratum-fx" });
}
