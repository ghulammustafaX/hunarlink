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

const runHunarLinkPipeline = async (userInput, userId = 'user_test_123') => {

  console.log('\n═══════════════════════════════════════════════════');
  console.log('       HUNARLINK — ANTIGRAVITY PIPELINE START       ');
  console.log('═══════════════════════════════════════════════════');
  console.log(`  Input : "${userInput}"`);
  console.log(`  User  : ${userId}`);
  console.log('═══════════════════════════════════════════════════\n');

  // ── STEP 1: Parse Intent ─────────────────────────────
  console.log('[01] parse_intent INVOKED');
  const intent = await parseIntent(userInput);
  if (!intent) {
    console.error('❌ Intent parsing failed. Stopping pipeline.');
    return null;
  }
  console.log(`     ✅ service_category : ${intent.service_category}`);
  console.log(`     ✅ location         : ${intent.location}`);
  console.log(`     ✅ time_preference  : ${intent.time_preference}\n`);

  // ── STEP 2: Fetch Providers ──────────────────────────
  console.log('[02] fetch_maps_data INVOKED');
  const providers = await fetchMapsData(intent.service_category, intent.location);
  if (!providers || providers.length === 0) {
    console.error('❌ No providers found. Stopping pipeline.');
    return null;
  }
  console.log(`     ✅ ${providers.length} providers fetched from Google Maps\n`);

  // ── STEP 3: Rank & Select ────────────────────────────
  console.log('[03] rank_and_select INVOKED');
  const { ranked, selected } = rankAndSelect(providers, intent.time_preference);
  if (!selected) {
    console.error('❌ Ranking failed. Stopping pipeline.');
    return null;
  }
  console.log(`     ✅ Selected  : ${selected.displayName?.text}`);
  console.log(`     ✅ Score     : ${selected.score}`);
  console.log(`     ✅ Distance  : ${selected.distanceLabel}`);
  console.log(`     ✅ Rating    : ${selected.rating}\n`);

  // ── STEP 4: Execute Booking ──────────────────────────
  console.log('[04] execute_booking INVOKED');
  const booking = await executeBooking(selected, userId, intent.time_preference);
  if (!booking) {
    console.error('❌ Booking failed. Stopping pipeline.');
    return null;
  }
  console.log(`     ✅ booking_id : ${booking.booking_id}`);
  console.log(`     ✅ status     : ${booking.status}`);
  console.log(`     ✅ Firebase   : active_bookings/${userId}\n`);

  // ── STEP 5: Schedule Follow-up ───────────────────────
  console.log('[05] schedule_followup INVOKED');
  const reminder = scheduleFollowup(booking);
  console.log(`     ✅ Reminder   : ${reminder.trigger_at}`);
  console.log(`     ✅ Message    : ${reminder.message}\n`);

  console.log('═══════════════════════════════════════════════════');
  console.log('       PIPELINE COMPLETE ✅                         ');
  console.log('═══════════════════════════════════════════════════');
  console.log('\n  Final Booking Summary:');
  console.log(`  ├─ Booking ID : ${booking.booking_id}`);
  console.log(`  ├─ Provider   : ${booking.provider_name}`);
  console.log(`  ├─ Service    : ${intent.service_category}`);
  console.log(`  ├─ Location   : ${intent.location}`);
  console.log(`  ├─ Time       : ${booking.service_time}`);
  console.log(`  ├─ Distance   : ${booking.provider_distance}`);
  console.log(`  ├─ Rating     : ${booking.provider_rating}`);
  console.log(`  └─ Reminder   : ${reminder.trigger_at}`);
  console.log('═══════════════════════════════════════════════════\n');

  return { intent, selected, booking, reminder };
};

module.exports = { runHunarLinkPipeline };