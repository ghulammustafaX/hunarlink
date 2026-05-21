process.stdout.setEncoding('utf8');
const dotenv = require('dotenv');
dotenv.config();

const queries = [
    "G-13",
    "G-13, Islamabad",
    "G-13 Islamabad",
    "Sector G-13, Islamabad",
    "F-8",
    "F-8, Islamabad",
    "Sector F-8, Islamabad"
];

async function test() {
    const apiKey = process.env.GOOGLE_PLACES_API_KEY;
    for (const query of queries) {
        const url = `https://maps.googleapis.com/maps/api/place/textsearch/json?query=${encodeURIComponent(query)}&key=${apiKey}`;
        try {
            const response = await fetch(url);
            const data = await response.json();
            console.log(`\nQuery: "${query}"`);
            console.log(`Status: ${data.status}`);
            if (data.results && data.results.length > 0) {
                console.log(`Found: ${data.results[0].name} at ${data.results[0].formatted_address}`);
            } else {
                console.log("No results", data);
            }
        } catch (e) {
            console.log("Error", e);
        }
    }
}
test();

require('dotenv').config();
const antigravityAgent = require('./agent');

const testInputs = [
  "Mujhe G-13 mein kal subah AC technician chahiye",
  "Plumber chahiye F-8 mein aaj",
  "Need electrician in I-8 urgent",
];

(async () => {
  for (const input of testInputs) {
    const result = await antigravityAgent.run({
      input: input,
      userId: 'user_test_123'
    });
    console.log('Final result:', JSON.stringify(result?.booking, null, 2));
    console.log('\n-------------------------------------------\n');
    
    // Wait 3 seconds between runs
    await new Promise(resolve => setTimeout(resolve, 3000));
  }
})();