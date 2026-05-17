const { GoogleGenerativeAI } = require('@google/generative-ai');

const MOCK_RESPONSES = {
  default: { service_category: "AC Technician", location: "G-13 Islamabad", time_preference: "tomorrow_morning" }
};

const parseIntent = async (userText) => {
  console.log('--- Running parse_intent ---');
  console.log(`Input: "${userText}"`);

  // MOCK MODE — set MOCK_MODE=true in .env to skip Gemini API
  if (process.env.MOCK_MODE === 'true') {
    console.log('     [MOCK MODE] Skipping Gemini API');
    const lower = userText.toLowerCase();
    const mock = {
      service_category: lower.includes('plumb') ? 'Plumber' : lower.includes('electr') ? 'Electrician' : 'AC Technician',
      location: lower.includes('f-8') ? 'F-8 Islamabad' : lower.includes('i-8') ? 'I-8 Islamabad' : 'G-13 Islamabad',
      time_preference: 
        lower.includes('urgent') ? 'today_urgent' : 
        lower.includes('aaj') || lower.includes('today') ? 'today' : 
        lower.includes('kal') || lower.includes('tomorrow') ? 'tomorrow_morning' : 
        'flexible',
    };
    console.log(`     ✅ Mock parsed:`, mock);
    return mock;
  }

  try {
    const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
    const model = genAI.getGenerativeModel({ 
      model: process.env.GEMINI_MODEL || 'gemini-2.5-flash'
    });

    const prompt = `
You are a multilingual service request parser for Pakistan.
Extract exactly three fields from the user input.
Input can be in English, Urdu, or Roman Urdu.

Return ONLY valid JSON, no extra text, no markdown, no backticks:
{
  "service_category": "<e.g. AC Technician, Plumber, Electrician, Tutor>",
  "location": "<area name, e.g. G-13 Islamabad>",
  "time_preference": "<tomorrow_morning | today_evening | today_urgent | flexible>"
}

Examples:
Input: "Mujhe G-13 mein kal subah AC technician chahiye"
Output: {"service_category":"AC Technician","location":"G-13 Islamabad","time_preference":"tomorrow_morning"}

Input: "Need a plumber in F-8 today"
Output: {"service_category":"Plumber","location":"F-8 Islamabad","time_preference":"today"}

Now parse this:
Input: "${userText}"
Output:`;

    const result = await model.generateContent(prompt);
    const raw = result.response.text().trim().replace(/```json|```/g, '').trim();
    console.log(`     Raw Gemini response: ${raw}`);
    const parsed = JSON.parse(raw);
    console.log(`     ✅ Parsed successfully`);
    return parsed;

  } catch (error) {
    console.error('❌ parse_intent error:', error.message);
    return null;
  }
};

module.exports = { parseIntent };