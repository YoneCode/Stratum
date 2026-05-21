export function translate(req, res) {
  const { text = "Hello", target = "fr" } = req.query;
  // Mock translation (production would call an LLM or translation API)
  const translations = { fr: "Bonjour", de: "Hallo", es: "Hola", ja: "こんにちは" };
  const translated = translations[target] || `[${target}] ${text}`;
  res.json({ original: text, translated, targetLanguage: target, provider: "stratum-translate" });
}
