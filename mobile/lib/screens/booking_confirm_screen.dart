import 'package:flutter/material.dart';

import '../services/firebase_service.dart';
import 'booking_success_screen.dart';

class BookingConfirmScreen extends StatelessWidget {
  final Map<String, dynamic> provider;

  const BookingConfirmScreen({super.key, required this.provider});

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
          fontSize: 20,
          fontWeight: FontWeight.w800,
          fontFamily: 'Plus Jakarta Sans',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color bg = Color(0xFFF7F2EA);
    const Color surface = Color(0xFFFFFFFF);
    const Color ink = Color(0xFF1A1415);
    const Color inkMid = Color(0xFF6B5E58);
    const Color border = Color(0xFFE4D9CF);
    const Color accent = Color(0xFF8C1616);
    const Color primaryTeal = Color(0xFF006053);

    final String providerName = _asText(provider['name'], fallback: 'Service Provider');
    final String providerImageUrl = _asText(provider['imageUrl']);
    final String providerDistance = _asText(provider['distance'], fallback: '2.1 km');
    final String providerRating = _asText(provider['rating'], fallback: '4.8');
    final String providerReasoning = _asText(provider['reasoning'], fallback: 'Selected by Khidmat AI.');
    final String serviceTimeText = providerName == 'Zahid electrician' ? 'Today, 2:30 PM' : 'Tomorrow, 10:00 AM';

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: Center(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: border),
              ),
              child: const Icon(Icons.close_rounded, color: ink, size: 18),
            ),
          ),
        ),
        title: RichText(
          text: const TextSpan(children: [
            TextSpan(text: 'Hunar', style: TextStyle(color: accent, fontSize: 20, fontWeight: FontWeight.w900, fontFamily: 'Plus Jakarta Sans')),
            TextSpan(text: 'Link', style: TextStyle(color: ink, fontSize: 20, fontWeight: FontWeight.w900, fontFamily: 'Plus Jakarta Sans')),
            TextSpan(text: '  🇵🇰', style: TextStyle(fontSize: 18)),
          ]),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatarWidget(
              radius: 16,
              borderWidth: 1,
              borderColor: border,
              backgroundImage: NetworkImage(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuCQoDO5HDML_-jCDeX5iu-UxrdV6wXQiBlgM1h9_b_8maOFPnEeRelYojiFuyFWENs50VmEPD0faASRAQPcL6NIJPMxmAoz4HDjtbD0eMvB7Mw0JjQHxFWZ8p3s6j4ThujK7PtV8VUyRSgBTCtdzLExPjAg-cwV8uaHRIC7LdtWzk4agX6l4oIVDF67hnlGrtfj2WEDTTBg1mJWpWNUQgiFMSBrJFbeP2F6bLZks9ZNVWHT3h8nFiUnx-7orZp7xqkRb_deE7uelic',
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: border),
                    boxShadow: [
                      BoxShadow(
                        color: ink.withOpacity(0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: SizedBox(
                          height: 180,
                          width: double.infinity,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuATLwY7hGP65eanuR5053dH2nBmfz_XYNP3c5FeobTdQMFcISa4Mm5RAfORuz8kj4mqHGtZE3phtiM6jIzai0bGYBF4Qw_Jh3ySH9lYASz65djTsVe-t1ztJPHzfzwVw-J3DhatiqcWtMIzUPnMoo5b3U-hxkdix4DMeJMD9z6pyUv8wV32Ieq8Uwa1D-8vcteaN406LNJu3Wk05zjgYUU7PGgpF-_MMrM-qZdq7zQvLX1Ve8DB2bwVmnGecRJoxPte79GAZYAdHOY',
                                fit: BoxFit.cover,
                              ),
                              Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [Colors.white, Colors.transparent],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                        child: Column(
                          children: [
                            Text(
                              'Booking Confirmed 🎉',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: primaryTeal,
                                fontFamily: 'Plus Jakarta Sans',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Your professional is on the way.',
                              style: TextStyle(
                                fontSize: 15,
                                color: inkMid,
                                fontFamily: 'Plus Jakarta Sans',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const ReceiptDivider(),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Provider Name',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: inkMid,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Plus Jakarta Sans',
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          providerName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: ink,
                                            fontFamily: 'Plus Jakarta Sans',
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: primaryTeal.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'VERIFIED',
                                            style: TextStyle(
                                              color: primaryTeal,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                              fontFamily: 'Plus Jakarta Sans',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: primaryTeal, width: 2),
                                  ),
                                  child: ClipOval(
                                    child: providerImageUrl.isNotEmpty
                                        ? Image.network(
                                            providerImageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => _avatarFallback(providerName, primaryTeal),
                                          )
                                        : _avatarFallback(providerName, primaryTeal),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: primaryTeal.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Row(
                                          children: [
                                            Icon(Icons.schedule, color: primaryTeal, size: 16),
                                            SizedBox(width: 4),
                                            Text(
                                              'Service Time',
                                              style: TextStyle(
                                                color: primaryTeal,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Plus Jakarta Sans',
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          serviceTimeText,
                                          style: const TextStyle(
                                            color: ink,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
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
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: primaryTeal.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Row(
                                          children: [
                                            Icon(Icons.map, color: primaryTeal, size: 16),
                                            SizedBox(width: 4),
                                            Text(
                                              'Distance',
                                              style: TextStyle(
                                                color: primaryTeal,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Plus Jakarta Sans',
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '$providerDistance away',
                                          style: const TextStyle(
                                            color: ink,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Plus Jakarta Sans',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Provider Rating',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: inkMid,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Plus Jakarta Sans',
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 18),
                                    const SizedBox(width: 4),
                                    Text(
                                      providerRating,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: ink,
                                        fontFamily: 'Plus Jakarta Sans',
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      '(128 reviews)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: inkMid,
                                        fontFamily: 'Plus Jakarta Sans',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: primaryTeal.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: primaryTeal.withOpacity(0.1)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.auto_awesome, color: primaryTeal, size: 18),
                                      SizedBox(width: 8),
                                      Text(
                                        'AI Matching Reason',
                                        style: TextStyle(
                                          color: primaryTeal,
                                          fontWeight: FontWeight.bold,
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
                                      fontSize: 14,
                                      height: 1.4,
                                      fontFamily: 'Plus Jakarta Sans',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
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
                                    debugPrint('Firebase Firestore write skipped or failed: $e');
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
                                        'imageUrl': providerImageUrl,
                                      }),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                  shadowColor: accent.withOpacity(0.3),
                                ),
                                child: const Text(
                                  'Done',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
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
                    'A confirmation email and SMS with contact details has been sent to your registered device.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: inkMid,
                      fontSize: 12,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Need help with this booking?',
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
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
                  color: const Color(0xFFBDC9C5).withOpacity(0.6),
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

class CircleAvatarWidget extends StatelessWidget {
  final double radius;
  final double borderWidth;
  final Color borderColor;
  final ImageProvider backgroundImage;

  const CircleAvatarWidget({
    super.key,
    required this.radius,
    required this.borderWidth,
    required this.borderColor,
    required this.backgroundImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: borderWidth),
        image: DecorationImage(image: backgroundImage, fit: BoxFit.cover),
      ),
    );
  }
}
