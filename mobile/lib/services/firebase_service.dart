// Firebase Firestore service
// Listens to active_bookings collection for real-time UI updates

import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final _db = FirebaseFirestore.instance;

  // Stream for real-time booking updates (used in StreamBuilder)
  static Stream<DocumentSnapshot> bookingStream(String userId) {
    return _db.collection('active_bookings').doc(userId).snapshots();
  }

  // Write booking (called by Antigravity via REST, not Flutter directly)
  static Future<void> writeBooking(Map<String, dynamic> payload) async {
    await _db.collection('active_bookings').doc(payload['user_id']).set(payload);
  }
}
