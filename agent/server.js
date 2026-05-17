require('dotenv').config();
const express = require('express');
const { runHunarLinkPipeline } = require('./agent');

const app = express();
app.use(express.json());

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
  const { input, userId } = req.body;

  console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log(`📥  Incoming Request`);
  console.log(`    Input  : "${input}"`);
  console.log(`    UserId : ${userId || 'user_001'}`);
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  if (!input || input.trim() === '') {
    return res.status(400).json({
      success: false,
      error: 'input field is required and cannot be empty',
    });
  }

  try {
    const result = await runHunarLinkPipeline(input.trim(), userId || 'user_001');

    if (!result) {
      console.error('❌ Pipeline returned null');
      return res.status(500).json({
        success: false,
        error: 'Pipeline failed — check server terminal for details',
      });
    }

    console.log(`\n✅ Response sent to client — booking_id: ${result.booking?.booking_id}`);
    return res.status(200).json({
      success: true,
      data: {
        intent:   result.intent,
        selected: {
          name:     result.selected?.displayName?.text,
          distance: result.selected?.distanceLabel,
          rating:   result.selected?.rating,
          score:    result.selected?.score,
          address:  result.selected?.formattedAddress,
        },
        booking:  result.booking,
        reminder: result.reminder,
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

// ── 404 HANDLER ─────────────────────────────────────────
app.use((req, res) => {
  res.status(404).json({
    success: false,
    error: `Route ${req.method} ${req.path} not found`,
    available_routes: ['GET /health', 'POST /request'],
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