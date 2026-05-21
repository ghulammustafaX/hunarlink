const { GoogleGenerativeAI } = require('@google/generative-ai');

// ─── API Key Rotation ────────────────────────────────────────────────────────
// If the primary key hits quota (429 error), automatically retries with the
// backup key. This allows seamless demo-day operation across two accounts.
const GEMINI_KEYS = [
  process.env.GEMINI_API_KEY,
  process.env.GEMINI_API_KEY_BACKUP,
].filter(Boolean); // remove any undefined entries

const parseIntent = async (userText) => {
  console.log('--- Running parse_intent ---');
  console.log(`Input: "${userText}"`);

  // MOCK MODE — set MOCK_MODE=true in .env to skip Gemini API
  if (process.env.MOCK_MODE === 'true') {
    console.log('     [MOCK MODE] Skipping Gemini API');
    const lower = userText.toLowerCase();
    
    // Fallback for unrecognized intent as requested
    const known = ['plumb', 'electr', 'clean', 'carpen', 'ac', 'repair'];
    const hasKnown = known.some(k => lower.includes(k));
    if (!hasKnown) {
      const mockFallback = {
        service_category: "General Home Service",
        location: "Islamabad",
        time_preference: "flexible"
      };
      console.log(`     ✅ Mock fallback parsed:`, mockFallback);
      return mockFallback;
    }

    const mock = {
      service_category: lower.includes('plumb') ? 'Plumber'
        : lower.includes('electr') ? 'Electrician'
        : lower.includes('clean') ? 'Cleaning'
        : lower.includes('carpen') ? 'Carpenter'
        : 'AC Technician',
      location: lower.includes('f-8') ? 'F-8 Islamabad'
        : lower.includes('i-8') ? 'I-8 Islamabad'
        : lower.includes('f-11') ? 'F-11 Islamabad'
        : lower.includes('g-14') ? 'G-14 Islamabad'
        : 'G-13 Islamabad',
      time_preference:
        lower.includes('urgent') ? 'today_urgent' :
        lower.includes('aaj') || lower.includes('today') ? 'today' :
        lower.includes('kal') || lower.includes('tomorrow') ? 'tomorrow_morning' :
        'flexible',
    };
    console.log(`     ✅ Mock parsed:`, mock);
    return mock;
  }

  // ─── Live Mode: try each key in order, rotate on quota error ──────────────
  let lastError = null;

  for (let i = 0; i < GEMINI_KEYS.length; i++) {
    const apiKey = GEMINI_KEYS[i];
    const keyLabel = i === 0 ? 'PRIMARY' : `BACKUP-${i}`;

    try {
      console.log(`     [Gemini] Trying ${keyLabel} key...`);

      const genAI = new GoogleGenerativeAI(apiKey);
      // Backup key only supports gemini-2.5-flash — use it as the safe fallback model
      const modelName = process.env.GEMINI_MODEL || 'gemini-2.5-flash';
      const model = genAI.getGenerativeModel({ model: modelName });

      const prompt = `
You are a multilingual service request parser for Pakistan.
Extract exactly three fields from the user input.
Input can be in English, Urdu, or Roman Urdu.

Return ONLY valid JSON, no extra text, no markdown, no backticks:
{
  "service_category": "<e.g. AC Technician, Plumber, Electrician, Tutor, Cleaning, Carpenter>",
  "location": "<area name, e.g. G-13 Islamabad>",
  "time_preference": "<tomorrow_morning | today_evening | today_urgent | flexible>"
}

Examples:
Input: "Mujhe G-13 mein kal subah AC technician chahiye"
Output: {"service_category":"AC Technician","location":"G-13 Islamabad","time_preference":"tomorrow_morning"}

Input: "مجھے کل صبح جی-13 میں اے سی ٹیکنیشن چاہیے"
Output: {"service_category":"AC Technician","location":"G-13 Islamabad","time_preference":"tomorrow_morning"}

Input: "Need electrician in I-8 urgent"
Output: {"service_category":"Electrician","location":"I-8 Islamabad","time_preference":"today_urgent"}

Input: "Need a plumber in F-8 today"
Output: {"service_category":"Plumber","location":"F-8 Islamabad","time_preference":"today"}

Now parse this:
Input: "${userText}"
Output:`;

      const result = await model.generateContent(prompt);
      const raw = result.response.text().trim().replace(/```json|```/g, '').trim();
      console.log(`     Raw Gemini response: ${raw}`);
      const parsed = JSON.parse(raw);
      console.log(`     ✅ Parsed successfully using ${keyLabel} key`);
      return parsed;

    } catch (error) {
      lastError = error;
      const isQuotaError = error.message?.includes('429') ||
                           error.message?.includes('quota') ||
                           error.message?.includes('RESOURCE_EXHAUSTED');

      if (isQuotaError && i < GEMINI_KEYS.length - 1) {
        console.warn(`     ⚠️  ${keyLabel} key quota exceeded — rotating to next key...`);
        continue; // try next key
      }

      // Non-quota error or no more keys to try
      console.error(`❌ parse_intent error (${keyLabel}):`, error.message);
      break;
    }
  }

  // All keys exhausted — return null to trigger mock fallback in agent
  console.error('❌ All Gemini API keys failed. Returning null.');
  return null;
};

module.exports = { parseIntent };