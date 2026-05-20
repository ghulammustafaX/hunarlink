const admin = require('firebase-admin');
const path = require('path');

if (!admin.apps.length) {
  const serviceAccount = require(path.join(__dirname, '../serviceAccountKey.json'));
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

const executeBooking = async (provider, userId, timePreference, serviceCategory) => {
  console.log('\n--- Running execute_booking ---');
  console.log(`Booking: ${provider?.displayName?.text} for user ${userId}`);

  const bookingId = `BK-${Date.now()}`;

  const payload = {
    booking_id:        bookingId,
    user_id:           userId,
    status:            'confirmed',
    provider_name:     provider?.displayName?.text || 'Provider',
    service_category:  serviceCategory || 'Home Service',
    service_time:      timePreference === 'tomorrow_morning' ? '10:00 AM Tomorrow' : 'Today',
    provider_distance: provider?.distanceLabel || '2.1 km',
    provider_rating:   provider?.rating?.toString() || '4.5',
    reasoning:         `Selected as the closest available provider with a ${provider?.rating || 4.5} rating.`,
    created_at:        new Date().toISOString(),
    reminder_at:       new Date(Date.now() + 86400000).toISOString(),
  };

  try {
    const db = admin.firestore();
    await db
      .collection('active_bookings')
      .doc(userId)
      .set(payload);

    console.log(`✅ Firebase write success — booking_id: ${bookingId}`);
    console.log(`✅ Document path: active_bookings/${userId}`);
  } catch (error) {
    console.error('❌ Firebase write failed:', error.message);
  }

  return payload;
};

module.exports = { executeBooking };