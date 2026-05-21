export function summarize(req, res) {
  const text = req.query.text || req.body?.text || "No text provided";
  // Mock summarization (production would call an LLM)
  const summary = text.length > 100
    ? text.slice(0, 100) + "... [summarized by Stratum LegalBot]"
    : `Summary: ${text}`;
  res.json({ summary, model: "stratum-summarizer-v1", tokens: text.split(" ").length });
}
