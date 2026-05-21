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
  static const Color accent = Color(0xFF8C1616);
  static const Color primaryTeal = Color(0xFF8C1616);

  @override
  Widget build(BuildContext context) {
    const String userId = 'user_mustafa_001';

    Widget body = StreamBuilder<DocumentSnapshot>(
      stream: FirebaseService.bookingStream(userId),
      builder: (context, snapshot) {
        final hasActive = snapshot.hasData && snapshot.data != null && snapshot.data!.exists;
        Map<String, dynamic>? activeBooking;
        if (hasActive) {
          activeBooking = snapshot.data!.data() as Map<String, dynamic>?;
        }

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

              if (hasActive && activeBooking != null) ...[
                _activeBookingCard(activeBooking),
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

              _pastBookingCard(
                name: 'Zahid Electrician',
                service: 'AC & Fan Specialist',
                status: 'CONFIRMED',
                statusColor: primaryTeal,
                price: 'Rs. 1,200',
                time: 'Yesterday, 2:30 PM',
                id: 'BK-940291',
              ),
              const SizedBox(height: 12),
              _pastBookingCard(
                name: 'Ali Deep Cleaning',
                service: 'Full House Wash',
                status: 'COMPLETED',
                statusColor: Colors.green,
                price: 'Rs. 3,500',
                time: '12 May, 11:00 AM',
                id: 'BK-829104',
              ),
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
    final statusColor = isCompleted ? Colors.green : primaryTeal;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookingSuccessScreen(
              provider: {
                'displayName': {'text': booking['provider_name'] ?? 'Provider'},
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
          color: surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isCompleted ? border : primaryTeal, width: 2),
          boxShadow: [
            BoxShadow(
              color: isCompleted ? ink.withOpacity(0.05) : primaryTeal.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
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
                          color: ink,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                      Text(
                        booking['service_category'] ?? 'Home Service',
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: border),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 16, color: accent),
                    const SizedBox(width: 6),
                    Text(
                      booking['service_time'] ?? 'Today',
                      style: const TextStyle(
                        color: accent,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: inkMid),
                    const SizedBox(width: 4),
                    Text(
                      booking['provider_distance'] ?? '2.1 km',
                      style: const TextStyle(
                        color: inkMid,
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Tap to view tracking & details',
                    style: TextStyle(
                      color: primaryTeal,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, size: 10, color: primaryTeal),
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
    required Color statusColor,
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
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
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
