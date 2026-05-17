// // agent.js
// require('dotenv').config();
// const { Anthropic } = require('@anthropic-ai/sdk');

// // Ensure you have ANTHROPIC_API_KEY set in your environment variables.
// const anthropic = new Anthropic();

// const tools = {
//     parse_intent: async (prompt) => {
//         console.log(`\n--- [Step 1] parse_intent ---`);
//         console.log(`Input: "${prompt}"`);
        
//         try {
//             const mockResponses = {
//                 "Kal subah G-13 mein AC technician chahiye": '{\n  "service_category": "AC Technician",\n  "location": "G-13 Islamabad",\n  "time_preference": "tomorrow_morning"\n}',
//                 "Need a plumber in F-8 today": '{\n  "service_category": "Plumber",\n  "location": "F-8 Islamabad",\n  "time_preference": "today"\n}',
//                 "G-11 mein tutor chahiye weekend pe": '{\n  "service_category": "Tutor",\n  "location": "G-11 Islamabad",\n  "time_preference": "weekend"\n}',
//                 "Electrician urgent I-8": '{\n  "service_category": "Electrician",\n  "location": "I-8 Islamabad",\n  "time_preference": "urgent"\n}',
//                 "Beautician chahiye F-6 mein kal": '{\n  "service_category": "Beautician",\n  "location": "F-6 Islamabad",\n  "time_preference": "tomorrow"\n}'
//             };
            
//             const result = mockResponses[prompt] || '{\n  "service_category": "Unknown",\n  "location": "Unknown",\n  "time_preference": "Unknown"\n}';
//             const parsed = JSON.parse(result);
//             console.log(`Output:`, parsed);
//             return parsed;
//         } catch (error) {
//             console.error("Error parsing response:", error.message);
//             return null;
//         }
//     },
//     fetch_maps_data: async (location) => {
//         console.log(`\n--- [Step 2] fetch_maps_data ---`);
//         console.log(`Querying Google Places API for: "${location}"`);
//         try {
//             const apiKey = process.env.GOOGLE_PLACES_API_KEY;
//             if (!apiKey) {
//                 console.log("GOOGLE_PLACES_API_KEY not found. Returning mock providers.");
//                 const mockProviders = [
//                     { name: `Provider A near ${location}`, address: location, rating: 4.8 },
//                     { name: `Provider B near ${location}`, address: location, rating: 4.2 }
//                 ];
//                 console.log(`Output:`, mockProviders);
//                 return mockProviders;
//             }
//             const url = `https://places.googleapis.com/v1/places:searchText`;
//             const response = await fetch(url, {
//                 method: "POST",
//                 headers: {
//                     "Content-Type": "application/json",
//                     "X-Goog-Api-Key": apiKey,
//                     "X-Goog-FieldMask": "places.displayName,places.formattedAddress,places.rating"
//                 },
//                 body: JSON.stringify({
//                     textQuery: location
//                 })
//             });
//             const data = await response.json();
            
//             if (data.error) {
//                 console.log(`API Error [${data.error.status}]: ${data.error.message}`);
//                 return [];
//             } else if (data.places && data.places.length > 0) {
//                 const providers = data.places.map(place => ({
//                     name: place.displayName ? place.displayName.text : "Unknown Name",
//                     address: place.formattedAddress,
//                     rating: place.rating
//                 }));
//                 console.log(`Output:`, providers);
//                 return providers;
//             } else {
//                 console.log("No results found.");
//                 return [];
//             }
//         } catch (error) {
//             console.error("Error calling Google Places API:", error.message);
//             return [];
//         }
//     },
//     rank_and_select: async (providers) => {
//         console.log(`\n--- [Step 3] rank_and_select ---`);
//         if (!providers || providers.length === 0) {
//             console.log("No providers to rank.");
//             return null;
//         }
//         const sorted = [...providers].sort((a, b) => (b.rating || 0) - (a.rating || 0));
//         const selected = sorted[0];
//         const result = {
//             selected_provider: selected,
//             reasoning: `Selected ${selected.name} because it has the highest rating (${selected.rating}).`
//         };
//         console.log(`Output:`, result);
//         return result;
//     },
//     execute_booking: async (bookingData) => {
//         console.log(`\n--- [Step 4] execute_booking ---`);
//         const payload = {
//             bookingId: "B" + Math.floor(Math.random() * 100000),
//             provider: bookingData.provider.selected_provider.name,
//             service: bookingData.intent.service_category,
//             location: bookingData.intent.location,
//             time: bookingData.intent.time_preference,
//             status: "success",
//             timestamp: new Date().toISOString()
//         };
//         console.log(`Output (Written to Firebase):`, payload);
//         return payload;
//     },
//     schedule_followup: async (bookingPayload) => {
//         console.log(`\n--- [Step 5] schedule_followup ---`);
//         const reminderPayload = {
//             reminderId: "R" + Math.floor(Math.random() * 100000),
//             bookingId: bookingPayload.bookingId,
//             message: `Reminder: Your ${bookingPayload.service} is scheduled for ${bookingPayload.time} at ${bookingPayload.location}.`,
//             scheduledFor: "1 hour before service"
//         };
//         console.log(`Output (Reminder Payload):`, reminderPayload);
//         return reminderPayload;
//     }
// };

// class OrchestratorAgent {
//     constructor(tools) {
//         this.tools = tools;
//     }

//     async process(prompt) {
//         console.log(`\n======================================================`);
//         console.log(`STARTING PIPELINE FOR: "${prompt}"`);
//         console.log(`======================================================`);

//         // 1. Parse intent
//         const intent = await this.tools.parse_intent(prompt);
//         if (!intent) return;
        
//         // 2. Fetch maps data
//         const providers = await this.tools.fetch_maps_data(intent.location);
//         if (!providers || providers.length === 0) {
//             console.log("\nPipeline stopped: No providers available.");
//             return;
//         }

//         // 3. Rank and select
//         const selection = await this.tools.rank_and_select(providers);
//         if (!selection) return;

//         // 4. Execute booking
//         const booking = await this.tools.execute_booking({
//             intent: intent,
//             provider: selection
//         });
//         if (!booking) return;

//         // 5. Schedule followup
//         const followup = await this.tools.schedule_followup(booking);
        
//         console.log(`\n======================================================`);
//         console.log(`PIPELINE COMPLETE`);
//         console.log(`======================================================\n`);
//     }
// }

// async function testPrompts() {
//     const agent = new OrchestratorAgent(tools);
//     const testInputs = [
//         "Kal subah G-13 mein AC technician chahiye",
//         "Need a plumber in F-8 today",
//         "G-11 mein tutor chahiye weekend pe",
//         "Electrician urgent I-8",
//         "Beautician chahiye F-6 mein kal"
//     ];

//     console.log("Starting master orchestrator pipeline tests...");
//     for (const input of testInputs) {
//         await agent.process(input);
//     }
//     console.log("All tests completed!");
// }

// testPrompts();

process.env.PYTHONIOENCODING = 'utf-8';
if (process.platform === 'win32') {
  process.stdout.reconfigure?.({ encoding: 'utf8' });
}

require('dotenv').config();
const { parseIntent }       = require('./tools/parse_intent');
const { fetchMapsData }     = require('./tools/fetch_maps_data');
const { rankAndSelect }     = require('./tools/rank_and_select');
const { executeBooking }    = require('./tools/execute_booking');
const { scheduleFollowup }  = require('./tools/schedule_followup');

const runHunarLinkPipeline = async (userInput, userId = 'user_test_123') => {
  console.log('\n═══════════════════════════════════════════');
  console.log('HUNARLINK — ANTIGRAVITY PIPELINE START');
  console.log('═══════════════════════════════════════════');
  console.log(`Input: "${userInput}"`);
  console.log(`User:  ${userId}`);

  // ── STEP 1: Parse Intent ──────────────────────
  console.log('\n[01] parse_intent INVOKED');
  const intent = await parseIntent(userInput);
  if (!intent) {
    console.error('❌ Intent parsing failed. Stopping pipeline.');
    return null;
  }
  console.log(`     service_category: ${intent.service_category}`);
  console.log(`     location:         ${intent.location}`);
  console.log(`     time_preference:  ${intent.time_preference}`);

  // ── STEP 2: Fetch Providers ───────────────────
  console.log('\n[02] fetch_maps_data INVOKED');
  const providers = await fetchMapsData(intent.service_category, intent.location);
  if (!providers || providers.length === 0) {
    console.error('❌ No providers found. Stopping pipeline.');
    return null;
  }
  console.log(`     Found ${providers.length} providers from Google Maps`);

  // ── STEP 3: Rank & Select ─────────────────────
  console.log('\n[03] rank_and_select INVOKED');
  const { ranked, selected } = rankAndSelect(providers, intent.time_preference);
  console.log(`     Selected: ${selected?.displayName?.text}`);
  console.log(`     Score:    ${selected?.score}`);
  console.log(`     Reasoning: Closest available provider with rating ${selected?.rating}`);

  // ── STEP 4: Execute Booking ───────────────────
  console.log('\n[04] execute_booking INVOKED');
  const booking = await executeBooking(selected, userId, intent.time_preference);
  console.log(`     booking_id: ${booking.booking_id}`);
  console.log(`     status:     ${booking.status}`);

  // ── STEP 5: Schedule Follow-up ────────────────
  console.log('\n[05] schedule_followup INVOKED');
  const reminder = scheduleFollowup(booking);
  console.log(`     Reminder scheduled: ${reminder.trigger_at}`);
  console.log(`     Message: ${reminder.message}`);

  console.log('\n═══════════════════════════════════════════');
  console.log('PIPELINE COMPLETE ✅');
  console.log('═══════════════════════════════════════════\n');

  return { intent, selected, booking, reminder };
};

module.exports = { runHunarLinkPipeline };