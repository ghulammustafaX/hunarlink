import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import 'booking_success_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  final bool isStandalone;

  const MyBookingsScreen({super.key, this.isStandalone = false});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  // Constants matching the app design system
  static const Color bg = Color(0xFFF7F2EA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF1A1415);
  static const Color inkMid = Color(0xFF6B5E58);
  static const Color border = Color(0xFFE4D9CF);

  @override
  Widget build(BuildContext context) {
    const String userId = 'user_mustafa_001';

    Widget body = StreamBuilder<QuerySnapshot>(
      stream: FirebaseService.userBookingsStream(userId),
      builder: (context, snapshot) {
        final bookings = (snapshot.data?.docs ?? []).map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {'_doc_id': doc.id, ...data};
        }).toList()
          ..sort((a, b) => (b['created_at'] ?? '').toString().compareTo((a['created_at'] ?? '').toString()));
        final activeBookings = bookings
            .where((b) => (b['status'] ?? 'confirmed').toString().toLowerCase() != 'completed')
            .toList();
        final completedBookings = bookings
            .where((b) => (b['status'] ?? '').toString().toLowerCase() == 'completed')
            .toList();

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.isStandalone) ...[
                const SizedBox(height: 16),
                const Text(
                  'My Bookings',
                  style: TextStyle(
                    color: ink,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Track your active & past bookings.',
                  style: TextStyle(
                    color: inkMid,
                    fontSize: 14,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Active Booking Section
              const Text(
                'ACTIVE BOOKINGS',
                style: TextStyle(
                  color: Color(0xFFD4C8BC),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
              const SizedBox(height: 12),

              if (activeBookings.isNotEmpty) ...[
                ...activeBookings.map((booking) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _activeBookingCard(booking),
                )),
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: border),
                  ),
                  child: const Center(
                    child: Text(
                      'No active bookings.\nGo to the Home tab to book a service!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: inkMid,
                        fontSize: 14,
                        height: 1.4,
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Past Bookings Section
              const Text(
                'PAST BOOKINGS',
                style: TextStyle(
                  color: Color(0xFFD4C8BC),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
              const SizedBox(height: 12),

              if (completedBookings.isNotEmpty) ...[
                ...completedBookings.map((booking) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _pastBookingCard(
                    name: booking['provider_name'] ?? 'Provider',
                    service: booking['service_category'] ?? 'Home Service',
                    status: (booking['status'] ?? 'completed').toString().toUpperCase(),
                    statusTextColor: const Color(0xFF81C784),
                    statusBgColor: const Color(0xFFE8F5E9),
                    price: 'Rs. --',
                    time: booking['service_time'] ?? 'Flexible',
                    id: booking['booking_id'] ?? booking['_doc_id'] ?? '',
                  ),
                )),
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: border),
                  ),
                  child: const Text(
                    'Completed bookings will appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: inkMid,
                      fontSize: 13,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );

    if (widget.isStandalone) {
      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: bg,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: ink, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(child: body),
      );
    }

    return body;
  }

  Widget _activeBookingCard(Map<String, dynamic> booking) {
    final status = (booking['status'] ?? 'confirmed').toString().toUpperCase();
    final isCompleted = status == 'COMPLETED';
    final Color badgeTextColor = isCompleted ? const Color(0xFF81C784) : const Color(0xFFFFB300);
    final Color badgeBgColor = isCompleted ? const Color(0xFFE8F5E9).withOpacity(0.15) : const Color(0xFFFFF8E1).withOpacity(0.15);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookingSuccessScreen(
              provider: {
                'displayName': {'text': booking['provider_name'] ?? 'Provider'},
                'name': booking['provider_name'] ?? 'Provider',
                'booking_id': booking['booking_id'] ?? booking['_doc_id'],
                'booking_doc_id': booking['_doc_id'],
                'service_time': booking['service_time'],
                'formattedAddress': booking['provider_address'] ?? 'Islamabad',
                'rating': double.tryParse(booking['provider_rating']?.toString() ?? '4.5') ?? 4.5,
              },
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1B1A), // premium deep off-black background from screen styles
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF332E2D), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 16,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking['provider_name'] ?? 'Provider',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                      Text(
                        booking['service_category'] ?? 'Home Service',
                        style: const TextStyle(
                          color: Color(0xFFD4C8BC),
                          fontSize: 13,
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: badgeBgColor,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: badgeTextColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFF332E2D)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 16, color: Color(0xFFE57373)),
                    const SizedBox(width: 6),
                    Text(
                      booking['service_time'] ?? 'Today',
                      style: const TextStyle(
                        color: Color(0xFFE57373),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFFD4C8BC)),
                    const SizedBox(width: 4),
                    Text(
                      booking['provider_distance'] ?? '2.1 km',
                      style: const TextStyle(
                        color: Color(0xFFD4C8BC),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2224),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Tap to view tracking & details',
                    style: TextStyle(
                      color: Color(0xFFE57373),
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Color(0xFFE57373)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pastBookingCard({
    required String name,
    required String service,
    required String status,
    required Color statusTextColor,
    required Color statusBgColor,
    required String price,
    required String time,
    required String id,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: ink.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: ink,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                    ),
                    Text(
                      service,
                      style: const TextStyle(
                        color: inkMid,
                        fontSize: 13,
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusTextColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: border),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.history_rounded, size: 14, color: inkMid),
                  const SizedBox(width: 4),
                  Text(
                    time,
                    style: const TextStyle(
                      color: inkMid,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                ],
              ),
              Text(
                price,
                style: const TextStyle(
                  color: ink,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
