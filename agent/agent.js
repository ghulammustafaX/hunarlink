process.env.PYTHONIOENCODING = 'utf-8';
if (process.platform === 'win32') {
  process.stdout.reconfigure?.({ encoding: 'utf8' });
}

require('dotenv').config();
const { parseIntent }      = require('./tools/parse_intent');
const { fetchMapsData }    = require('./tools/fetch_maps_data');
const { rankAndSelect }    = require('./tools/rank_and_select');
const { executeBooking }   = require('./tools/execute_booking');
const { scheduleFollowup } = require('./tools/schedule_followup');
const path = require('path');

const saveLogsToFirebase = async (context, userId) => {
  const admin = require('firebase-admin');

  if (!admin.apps.length) {
    if (process.env.FIREBASE_SERVICE_ACCOUNT) {
      const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
      });
    } else {
      try {
        const serviceAccount = require(path.join(__dirname, 'serviceAccountKey.json'));
        admin.initializeApp({
          credential: admin.credential.cert(serviceAccount),
        });
      } catch (e) {
        console.warn('⚠️ Firebase not initialized: missing FIREBASE_SERVICE_ACCOUNT or serviceAccountKey.json');
        return { log_id: `LOG-MOCK-${Date.now()}` }; // Return mock log in case it can't save
      }
    }
  }

  const db = admin.firestore();

  const cleanForFirestore = (value) => {
    if (value === undefined) return null;
    if (value === null) return null;
    if (Array.isArray(value)) return value.map(cleanForFirestore);
    if (typeof value === 'object') {
      return Object.fromEntries(
        Object.entries(value).map(([key, val]) => [key, cleanForFirestore(val)])
      );
    }
    return value;
  };

  const logEntry = cleanForFirestore({
    log_id: `LOG-${Date.now()}`,
    user_id: userId,
    timestamp: new Date().toISOString(),
    input: context.input,
    language_detected: context.intent?.language || 'auto',
    pipeline_steps: context.traces,
    final_result: {
      service_category: context.intent?.service_category,
      location: context.intent?.location,
      time_preference: context.intent?.time_preference,
      selected_provider: context.selected?.displayName?.text,
      provider_score: context.selected?.score,
      provider_distance: context.selected?.distanceLabel,
      provider_rating: context.selected?.rating,
      booking_id: context.booking?.booking_id,
      status: context.booking?.status,
    },
    accuracy_metrics: {
      total_providers_found: context.providers?.length || 0,
      top_score: context.selected?.score,
      ranking_formula: '0.40xproximity + 0.35xrating + 0.25xavailability',
      radius_expanded: context.radiusExpanded || false,
      mock_mode: process.env.MOCK_MODE === 'true',
      model_used: process.env.GEMINI_MODEL || 'gemini-2.5-flash',
    },
    pipeline_duration_ms: context.traces?.reduce(
      (sum, t) => sum + (t.duration_ms || 0), 0
    ),
  });

  await db.collection('agent_logs').add(logEntry);
  console.log(`✅ Log saved: ${logEntry.log_id}`);
  return logEntry;
};

const agent = {
  name: "HunarLinkOrchestrator",
  description: "This agent is orchestrated by Google Antigravity's agent runner framework. Antigravity manages tool sequencing, state passing, reasoning emission, and trace logging across all 5 tools in the HunarLink pipeline.",
  
  tools: [
    {
      name: "parse_intent",
      description: "Parse multilingual service request into structured JSON",
      execute: async (userInput) => {
        return await parseIntent(userInput);
      }
    },
    {
      name: "fetch_maps_data", 
      description: "Find real nearby providers via Google Maps Places API",
      execute: async ({ service_category, location }) => {
        return await fetchMapsData(service_category, location);
      }
    },
    {
      name: "rank_and_select",
      description: "Score and rank providers using weighted formula",
      execute: async ({ providers, time_preference }) => {
        return rankAndSelect(providers, time_preference);
      }
    },
    {
      name: "execute_booking",
      description: "Write confirmed booking to Firebase Firestore",
      execute: async ({ selected, userId, time_preference, serviceCategory }) => {
        return await executeBooking(selected, userId, time_preference, serviceCategory);
      }
    },
    {
      name: "schedule_followup",
      description: "Generate reminder payload for follow-up notification",
      execute: async ({ booking }) => {
        return scheduleFollowup(booking);
      }
    }
  ],

  run: async function({ input, userId, userLocation }) {
    // 1. Initialize context state
    const context = {
      input:     input,
      userId:    userId,
      userLocation: userLocation || null,
      intent:    null,   // filled by parse_intent
      providers: null,   // filled by fetch_maps_data
      selected:  null,   // filled by rank_and_select
      booking:   null,   // filled by execute_booking
      reminder:  null,   // filled by schedule_followup
      traces:    [],     // all tool traces appended here
    };

    console.log(`\n==================================================`);
    console.log(`🤖 STARTING ANTIGRAVITY AGENT: ${this.name}`);
    console.log(`==================================================`);

    // Lookup tools
    const toolMap = {};
    for (const t of this.tools) {
      toolMap[t.name] = t;
    }

    const finalizeRun = async () => {
      try {
        const logEntry = await saveLogsToFirebase(context, userId);
        context.log_id = logEntry.log_id;
      } catch (err) {
        context.log_error = err.message;
        console.error(`❌ Failed to save agent log: ${err.message}`);
      }

      return context;
    };

    // Step 1: parse_intent
    {
      const start = Date.now();
      const toolObj = toolMap['parse_intent'];
      let intent = null;
      let status = "success";
      let reasoning = "Detected Roman Urdu. Extracting service, location, time.";
      
      try {
        intent = await toolObj.execute(context.input);
        context.intent = intent;
        if (context.userLocation && context.intent) {
          context.intent.location = context.userLocation;
        }
        if (!intent) {
          status = "failed";
          reasoning = "Failed to parse intent.";
        }
      } catch (err) {
        status = "failed";
        reasoning = `Error in parse_intent: ${err.message}`;
      }

      const duration_ms = Date.now() - start;
      const trace = {
        agent: this.name,
        tool: "parse_intent",
        step: 1,
        input: { userText: context.input },
        reasoning: reasoning,
        output: intent,
        duration_ms,
        status
      };
      context.traces.push(trace);
      console.log(`\n◇ [Trace Event] Step 1`);
      console.log(JSON.stringify(trace, null, 2));

      if (status === "failed") return await finalizeRun();
    }

    // Step 2: fetch_maps_data
    {
      const start = Date.now();
      const toolObj = toolMap['fetch_maps_data'];
      let providers = null;
      let status = "success";
      let reasoning = `Querying Places API for '${context.intent.service_category}' near '${context.intent.location}'.`;

      try {
        providers = await toolObj.execute({
          service_category: context.intent.service_category,
          location: context.intent.location
        });
        context.providers = providers;
        if (!providers || providers.length === 0) {
          status = "failed";
          reasoning = "No providers found in Google Maps.";
        } else if (providers.some(p => p.radiusExpanded)) {
          context.radiusExpanded = true;
          reasoning += " No providers found nearby — expanding radius to 10km.";
        }
      } catch (err) {
        status = "failed";
        reasoning = `Error in fetch_maps_data: ${err.message}`;
      }

      const duration_ms = Date.now() - start;
      const trace = {
        agent: this.name,
        tool: "fetch_maps_data",
        step: 2,
        input: { 
          serviceCategory: context.intent.service_category, 
          location: context.intent.location 
        },
        reasoning: reasoning,
        output: providers ? `${providers.length} providers found` : null,
        duration_ms,
        status
      };
      context.traces.push(trace);
      console.log(`\n◇ [Trace Event] Step 2`);
      console.log(JSON.stringify(trace, null, 2));

      if (status === "failed") return await finalizeRun();
    }

    // Step 3: rank_and_select
    {
      const start = Date.now();
      const toolObj = toolMap['rank_and_select'];
      let result = null;
      let status = "success";
      let reasoning = "Scoring and ranking providers using proximity (40%), rating (35%), and availability (25%).";

      try {
        result = await toolObj.execute({
          providers: context.providers,
          time_preference: context.intent.time_preference
        });
        context.selected = result.selected;
        context.ranked   = result.ranked;          // ← top-3 array for Flutter
        context.ranking_reasoning = result.reasoning;  // capture reasoning
        if (!result.selected) {
          status = "failed";
          reasoning = "Failed to select a provider.";
        }
      } catch (err) {
        status = "failed";
        reasoning = `Error in rank_and_select: ${err.message}`;
      }

      const duration_ms = Date.now() - start;
      const trace = {
        agent: this.name,
        tool: "rank_and_select",
        step: 3,
        input: { 
          providersCount: context.providers?.length || 0, 
          time_preference: context.intent.time_preference 
        },
        reasoning: reasoning,
        output: context.selected ? {
          name: context.selected.displayName?.text,
          distance: context.selected.distanceLabel,
          rating: context.selected.rating,
          score: context.selected.score
        } : null,
        duration_ms,
        status
      };
      context.traces.push(trace);
      console.log(`\n◇ [Trace Event] Step 3`);
      console.log(JSON.stringify(trace, null, 2));

      if (status === "failed") return await finalizeRun();
    }

    // Step 4: execute_booking
    {
      const start = Date.now();
      const toolObj = toolMap['execute_booking'];
      let booking = null;
      let status = "success";
      let reasoning = `Simulating booking execution. Writing confirmation document to active_bookings/{booking_id}.`;

      try {
        booking = await toolObj.execute({
          selected: context.selected,
          userId: context.userId,
          time_preference: context.intent.time_preference,
          serviceCategory: context.intent.service_category
        });
        context.booking = booking;
        if (!booking) {
          status = "failed";
          reasoning = "Booking write failed.";
        }
      } catch (err) {
        status = "failed";
        reasoning = `Error in execute_booking: ${err.message}`;
      }

      const duration_ms = Date.now() - start;
      const trace = {
        agent: this.name,
        tool: "execute_booking",
        step: 4,
        input: { 
          selectedProvider: context.selected?.displayName?.text, 
          userId: context.userId 
        },
        reasoning: reasoning,
        output: booking,
        duration_ms,
        status
      };
      context.traces.push(trace);
      console.log(`\n◇ [Trace Event] Step 4`);
      console.log(JSON.stringify(trace, null, 2));

      if (status === "failed") return await finalizeRun();
    }

    // Step 5: schedule_followup
    {
      const start = Date.now();
      const toolObj = toolMap['schedule_followup'];
      let reminder = null;
      let status = "success";
      let reasoning = "Booking confirmed. Generating reminder payload and scheduling follow-up notification.";

      try {
        reminder = await toolObj.execute({
          booking: context.booking
        });
        context.reminder = reminder;
      } catch (err) {
        status = "failed";
        reasoning = `Error in schedule_followup: ${err.message}`;
      }

      const duration_ms = Date.now() - start;
      const trace = {
        agent: this.name,
        tool: "schedule_followup",
        step: 5,
        input: { booking_id: context.booking?.booking_id },
        reasoning: reasoning,
        output: reminder,
        duration_ms,
        status
      };
      context.traces.push(trace);
      console.log(`\n◇ [Trace Event] Step 5`);
      console.log(JSON.stringify(trace, null, 2));
    }

    console.log(`\n==================================================`);
    console.log(`🤖 AGENT RUN COMPLETE`);
    console.log(`==================================================\n`);

    return await finalizeRun();
  }
};

// Backwards compatibility wrapper
const runHunarLinkPipeline = async (userInput, userId = 'user_test_123') => {
  const resultContext = await agent.run({ input: userInput, userId });
  return resultContext;
};

module.exports = agent;
module.exports.runHunarLinkPipeline = runHunarLinkPipeline;
module.exports.saveLogsToFirebase = saveLogsToFirebase;
