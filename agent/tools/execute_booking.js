const admin = require('firebase-admin');

if (!admin.apps.length) {
  // Works both locally (file) and on Railway (env variable)
  if (process.env.FIREBASE_SERVICE_ACCOUNT) {
    const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
    });
  } else {
    const path = require('path');
    const serviceAccount = require(path.join(__dirname, '../serviceAccountKey.json'));
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
    });
  }
}

const executeBooking = async (provider, userId, timePreference, serviceCategory) => {
  console.log('\n--- Running execute_booking ---');
  console.log(`Booking: ${provider?.displayName?.text} for user ${userId}`);

  const bookingId = `BK-${Date.now()}`;
  const formatServiceTime = (preference) => {
    switch (preference) {
      case 'today_urgent':
        return 'ASAP Today';
      case 'today_evening':
        return 'Today Evening';
      case 'today':
        return 'Today';
      case 'tomorrow_morning':
        return 'Tomorrow Morning';
      case 'tomorrow_evening':
        return 'Tomorrow Evening';
      case 'weekend':
        return 'This Weekend';
      case 'flexible':
      default:
        return 'Flexible';
    }
  };

  const payload = {
    booking_id:        bookingId,
    user_id:           userId,
    status:            'confirmed',
    provider_name:     provider?.displayName?.text || 'Provider',
    service_category:  serviceCategory || 'Home Service',
    time_preference:   timePreference || 'flexible',
    service_time:      formatServiceTime(timePreference),
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
      .doc(bookingId)
      .set(payload);

    console.log(`✅ Firebase write success — booking_id: ${bookingId}`);
    console.log(`✅ Document path: active_bookings/${bookingId}`);
  } catch (error) {
    console.error('❌ Firebase write failed:', error.message);
  }

  return payload;
};

module.exports = { executeBooking };
