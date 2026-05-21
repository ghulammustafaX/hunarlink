require('dotenv').config();
const express = require('express');
const antigravityAgent = require('./agent');
const path = require('path');

const app = express();
app.use(express.json());

const getFirestore = () => {
  const admin = require('firebase-admin');

  if (!admin.apps.length) {
    const serviceAccount = require(path.join(__dirname, 'serviceAccountKey.json'));
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
    });
  }

  return admin.firestore();
};

// ── CORS — allows Flutter app to call this API ──────────
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Headers', 'Content-Type');
  res.header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  if (req.method === 'OPTIONS') return res.sendStatus(200);
  next();
});

// ── HEALTH CHECK ────────────────────────────────────────
app.get('/health', (req, res) => {
  res.json({
    status:    'HunarLink API running ✅',
    mode:      process.env.MOCK_MODE === 'true' ? 'MOCK' : 'LIVE',
    model:     process.env.GEMINI_MODEL || 'gemini-2.5-flash',
    timestamp: new Date().toISOString(),
  });
});

// ── MAIN PIPELINE ENDPOINT ──────────────────────────────
app.post('/request', async (req, res) => {
  const { input, userId, location } = req.body;

  console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log(`📥  Incoming Request`);
  console.log(`    Input  : "${input}"`);
  console.log(`    UserId : ${userId || 'user_mustafa_001'}`);
  if (location) {
    console.log(`    Location : ${location}`);
  }
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  if (!input || input.trim() === '') {
    return res.status(400).json({
      success: false,
      error: 'input field is required and cannot be empty',
    });
  }

  try {
    const result = await antigravityAgent.run({
      input: input.trim(),
      userId: userId || 'user_mustafa_001',
      userLocation: location,
      tools: ['parse_intent', 'fetch_maps_data', 'rank_and_select', 
              'execute_booking', 'schedule_followup']
    });

    if (!result) {
      console.error('❌ Pipeline returned null');
      return res.status(500).json({
        success: false,
        error: 'Pipeline failed — check server terminal for details',
      });
    }

    console.log(`\n✅ Response sent to client — booking_id: ${result.booking?.booking_id}`);

    // Map ranked top-3 into Flutter-friendly shape
    const rankedProviders = (result.ranked || []).map((p, i) => ({
      name:      p.displayName?.text || `Provider ${i + 1}`,
      distance:  p.distanceLabel || 'N/A',
      rating:    p.rating?.toString() || 'N/A',
      score:     p.score,
      address:   p.formattedAddress || '',
      best:      i === 0,
      service_category: result.intent?.service_category,
      time_preference: result.intent?.time_preference,
      reasoning: i === 0
        ? (result.ranking_reasoning || result.booking?.reasoning || 'Best match by HunarLink AI.')
        : `Ranked #${i + 1} — Score: ${p.score} | ${p.distanceLabel} | ⭐ ${p.rating}`,
    }));

    return res.status(200).json({
      success: true,
      data: {
        intent:        result.intent,
        selected: {
          name:        result.selected?.displayName?.text,
          distance:    result.selected?.distanceLabel,
          rating:      result.selected?.rating,
          score:       result.selected?.score,
          address:     result.selected?.formattedAddress,
          service_category: result.intent?.service_category,
          time_preference: result.intent?.time_preference,
          reasoning:   result.ranking_reasoning || result.booking?.reasoning,
        },
        ranked:        rankedProviders,
        reasoning:     result.ranking_reasoning || result.booking?.reasoning,
        booking:       result.booking,
        reminder:      result.reminder,
        traces:        result.traces || [],
        radiusExpanded: result.radiusExpanded === true,
      },
    });

  } catch (error) {
    console.error('❌ Server error:', error.message);
    return res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

// ── AGENT LOGS ENDPOINTS ───────────────────────────────
app.get('/logs/:userId', async (req, res) => {
  try {
    const db = getFirestore();

    const snapshot = await db
      .collection('agent_logs')
      .where('user_id', '==', req.params.userId)
      .get();

    const logs = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
    }))
      .sort((a, b) => (b.timestamp || '').localeCompare(a.timestamp || ''))
      .slice(0, 20);

    res.json({ success: true, data: logs });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.get('/logs/detail/:logId', async (req, res) => {
  try {
    const db = getFirestore();

    const snapshot = await db
      .collection('agent_logs')
      .where('log_id', '==', req.params.logId)
      .limit(1)
      .get();

    if (snapshot.empty) {
      return res.status(404).json({ success: false, error: 'Log not found' });
    }

    res.json({ success: true, data: snapshot.docs[0].data() });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// ── 404 HANDLER ─────────────────────────────────────────
app.use((req, res) => {
  res.status(404).json({
    success: false,
    error: `Route ${req.method} ${req.path} not found`,
    available_routes: [
      'GET /health',
      'POST /request',
      'GET /logs/:userId',
      'GET /logs/detail/:logId',
    ],
  });
});

// ── START SERVER ─────────────────────────────────────────
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('   🚀 HunarLink API Server Started');
  console.log(`   📡 URL     : http://localhost:${PORT}`);
  console.log(`   ❤️  Health  : http://localhost:${PORT}/health`);
  console.log(`   📬 Request : POST http://localhost:${PORT}/request`);
  console.log(`   🤖 Mode    : ${process.env.MOCK_MODE === 'true' ? 'MOCK (Gemini bypassed)' : 'LIVE (Gemini active)'}`);
  console.log(`   🧠 Model   : ${process.env.GEMINI_MODEL || 'gemini-2.5-flash'}`);
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
});
