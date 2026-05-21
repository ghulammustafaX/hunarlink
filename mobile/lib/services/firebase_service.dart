// Firebase Firestore service
// Listens to active_bookings collection for real-time UI updates

import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final _db = FirebaseFirestore.instance;

  static Stream<DocumentSnapshot> bookingStreamById(String bookingId) {
    return _db.collection('active_bookings').doc(bookingId).snapshots();
  }

  static Stream<QuerySnapshot> userBookingsStream(String userId) {
    return _db
        .collection('active_bookings')
        .where('user_id', isEqualTo: userId)
        .snapshots();
  }

  static Stream<DocumentSnapshot> latestBookingStream(String userId) {
    return userBookingsStream(userId).asyncMap((snapshot) async {
      final docs = snapshot.docs.toList()
        ..sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          return (bData['created_at'] ?? '').toString().compareTo((aData['created_at'] ?? '').toString());
        });
      if (docs.isNotEmpty) {
        return docs.first;
      }
      return _db.collection('active_bookings').doc('__missing__').get();
    });
  }

  static Future<void> writeBooking(Map<String, dynamic> payload) async {
    final bookingId = payload['booking_id']?.toString();
    if (bookingId == null || bookingId.isEmpty) {
      throw ArgumentError('booking_id is required');
    }
    await _db.collection('active_bookings').doc(bookingId).set(payload);
  }
}
