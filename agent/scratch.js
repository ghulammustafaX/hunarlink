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
