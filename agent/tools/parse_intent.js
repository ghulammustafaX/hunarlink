// Tool 1: parse_intent
// Extracts service_category, location, time_preference from multilingual input

const parseIntent = async (userText) => {
  console.log('\n--- Running parse_intent ---');
  console.log(`Input: "${userText}"`);
  // Antigravity handles the LLM call using intent_agent.txt prompt
  // This file documents the tool logic for reference
};

module.exports = { parseIntent };
