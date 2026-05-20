import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import 'booking_success_screen.dart';

class BookingConfirmScreen extends StatelessWidget {
  final Map<String, dynamic> provider;

  const BookingConfirmScreen({super.key, required this.provider});

  static const Color bg       = Color(0xFFF7F2EA); // warm almond beige
  static const Color surface  = Color(0xFFFFFFFF); // clean white
  static const Color ink      = Color(0xFF1A1415); // deep charcoal
  static const Color inkMid   = Color(0xFF6B5E58); // warm taupe
  static const Color border   = Color(0xFFE4D9CF); // light warm border
  static const Color accent   = Color(0xFF8C1616); // brand crimson
  static const Color accentBg = Color(0xFFFFEBEB); // light pink-red tint
  static const Color numGray  = Color(0xFFD4C8BC); // warm gray

  String _asText(dynamic value, {String fallback = ''}) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) {
      return fallback;
    }
    return text;
  }

  Widget _avatarFallback(String providerName, Color borderColor) {
    return Container(
      color: const Color(0xFFF0E8E0),
      alignment: Alignment.center,
      child: Text(
        providerName.isNotEmpty ? providerName.substring(0, 1).toUpperCase() : 'S',
        style: TextStyle(
          color: borderColor,
          fontSize: 22,
          fontWeight: FontWeight.w900,
          fontFamily: 'Plus Jakarta Sans',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String providerName = _asText(provider['name'], fallback: 'Service Provider');
    final String providerImageUrl = _asText(provider['imageUrl']);
    final String providerDistance = _asText(provider['distance'], fallback: '2.1 km');
    final String providerRating = _asText(provider['rating'], fallback: '4.8');
    final String providerReasoning = _asText(provider['reasoning'], fallback: 'Selected by HunarLink AI.');
    
    // Choose dynamic service time based on provider details
    final String serviceTimeText = providerName.toLowerCase().contains('zahid') 
        ? 'Today, 2:30 PM' 
        : 'Tomorrow, 10:00 AM';

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Center(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: border),
                boxShadow: [
                  BoxShadow(
                    color: ink.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: ink, size: 16),
            ),
          ),
        ),
        title: RichText(
          text: const TextSpan(children: [
            TextSpan(text: 'Hunar', style: TextStyle(color: accent, fontSize: 20, fontWeight: FontWeight.w900, fontFamily: 'Plus Jakarta Sans')),
            TextSpan(text: 'Link', style: TextStyle(color: ink, fontSize: 20, fontWeight: FontWeight.w900, fontFamily: 'Plus Jakarta Sans')),
          ]),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              children: [
                // Ticket / Voucher Container
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: border),
                    boxShadow: [
                      BoxShadow(
                        color: ink.withOpacity(0.05),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header Visual
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                        decoration: BoxDecoration(
                          color: accentBg,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(23),
                            topRight: Radius.circular(23),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.task_alt_rounded, color: accent, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'CONFIRM BOOKING',
                                    style: TextStyle(
                                      color: accent,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.5,
                                      fontFamily: 'Plus Jakarta Sans',
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Review Booking Details',
                                    style: TextStyle(
                                      color: ink,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      fontFamily: 'Plus Jakarta Sans',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Provider details block
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                        child: Row(
                          children: [
                            // Provider Avatar Frame
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: accent, width: 2),
                              ),
                              child: ClipOval(
                                child: providerImageUrl.isNotEmpty
                                    ? Image.network(
                                        providerImageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => _avatarFallback(providerName, accent),
                                      )
                                    : _avatarFallback(providerName, accent),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          providerName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                            color: ink,
                                            fontFamily: 'Plus Jakarta Sans',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: accentBg,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'VERIFIED',
                                          style: TextStyle(
                                            color: accent,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.5,
                                            fontFamily: 'Plus Jakarta Sans',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.star_rounded, color: Colors.orange, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        providerRating,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: ink,
                                          fontFamily: 'Plus Jakarta Sans',
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      const Icon(Icons.navigation_rounded, color: inkMid, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        providerDistance,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: inkMid,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Plus Jakarta Sans',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      const ReceiptDivider(),
                      const SizedBox(height: 16),

                      // Details panels
                      Padding(
                        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Details grid
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: bg.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: border),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: const [
                                            Icon(Icons.calendar_month_rounded, color: accent, size: 16),
                                            SizedBox(width: 6),
                                            Text(
                                              'Service Time',
                                              style: TextStyle(
                                                color: inkMid,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                fontFamily: 'Plus Jakarta Sans',
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          serviceTimeText,
                                          style: const TextStyle(
                                            color: ink,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            fontFamily: 'Plus Jakarta Sans',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: bg.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: border),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: const [
                                            Icon(Icons.payments_rounded, color: accent, size: 16),
                                            SizedBox(width: 6),
                                            Text(
                                              'Payment Mode',
                                              style: TextStyle(
                                                color: inkMid,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                fontFamily: 'Plus Jakarta Sans',
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Cash on Service',
                                          style: TextStyle(
                                            color: ink,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            fontFamily: 'Plus Jakarta Sans',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 20),

                            // AI Reasoning Block
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: accentBg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: accent.withOpacity(0.12)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: const [
                                      Icon(Icons.auto_awesome, color: accent, size: 18),
                                      SizedBox(width: 8),
                                      Text(
                                        'AI Matching Reasoning',
                                        style: TextStyle(
                                          color: accent,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 12,
                                          fontFamily: 'Plus Jakarta Sans',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    providerReasoning,
                                    style: const TextStyle(
                                      color: ink,
                                      fontSize: 13.5,
                                      height: 1.45,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Plus Jakarta Sans',
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 28),

                            // Main Confirm Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: () {
                                  final bookingPayload = {
                                    'booking_id': 'BK-${DateTime.now().millisecondsSinceEpoch}',
                                    'user_id': 'user_mustafa_001',
                                    'status': 'confirmed',
                                    'provider_name': providerName,
                                    'service_time': serviceTimeText,
                                    'provider_distance': providerDistance,
                                    'provider_rating': providerRating,
                                    'reasoning': providerReasoning,
                                    'created_at': DateTime.now().toIso8601String(),
                                  };

                                  try {
                                    FirebaseService.writeBooking(bookingPayload);
                                  } catch (e) {
                                    debugPrint('Firebase Firestore write failed: $e');
                                  }

                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => BookingSuccessScreen(provider: {
                                        ...provider,
                                        'name': providerName,
                                        'distance': providerDistance,
                                        'rating': providerRating,
                                        'reasoning': providerReasoning,
                                      }),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 2,
                                  shadowColor: accent.withOpacity(0.3),
                                ),
                                child: const Text(
                                  'Confirm Booking',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    fontFamily: 'Plus Jakarta Sans',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'By confirming, you agree to our terms of service. You will receive a verification SMS shortly.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: inkMid,
                      fontSize: 12,
                      height: 1.4,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ReceiptDivider extends StatelessWidget {
  const ReceiptDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            children: List.generate(40, (index) {
              return Expanded(
                child: Container(
                  height: 1.5,
                  margin: const EdgeInsets.symmetric(horizontal: 2.0),
                  color: const Color(0xFFE4D9CF),
                ),
              );
            }),
          ),
          const Positioned(left: -8, child: CircleCutout()),
          const Positioned(right: -8, child: CircleCutout()),
        ],
      ),
    );
  }
}

class CircleCutout extends StatelessWidget {
  const CircleCutout({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: const BoxDecoration(
        color: Color(0xFFF7F2EA),
        shape: BoxShape.circle,
      ),
    );
  }
}
