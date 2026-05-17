const { GoogleGenerativeAI } = require('@google/generative-ai');

const parseIntent = async (userText) => {
  console.log('--- Running parse_intent ---');
  console.log(`Input: "${userText}"`);

  try {
    const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
    const model = genAI.getGenerativeModel({ 
      model: process.env.GEMINI_MODEL || 'gemini-2.0-flash' 
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

Input: "G-11 mein electrician chahiye abhi"
Output: {"service_category":"Electrician","location":"G-11 Islamabad","time_preference":"today_urgent"}

Now parse this:
Input: "${userText}"
Output:`;

    const result = await model.generateContent(prompt);
    const raw = result.response.text().trim();
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