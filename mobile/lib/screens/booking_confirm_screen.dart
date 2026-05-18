import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import 'booking_success_screen.dart';

class BookingConfirmScreen extends StatelessWidget {
  final Map<String, dynamic> provider;

  const BookingConfirmScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    // Brand Colors
    const Color brandPrimary = Color(0xFF006053);
    const Color brandPrimaryContainer = Color(0xFF0B7B6B);
    const Color brandBackground = Color(0xFFEFF4FF); // surface-container-low in light theme
    const Color brandOnBackground = Color(0xFF0B1C30);
    const Color textSecondary = Color(0xFF5D5F5F);

    // Dynamic service time
    final String serviceTimeText = provider['name'] == 'Zahid electrician' 
        ? 'Today, 2:30 PM' 
        : 'Tomorrow, 10:00 AM';

    return Scaffold(
      backgroundColor: brandBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: brandPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Khidmat AI 🇵🇰',
          style: TextStyle(
            color: brandPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            fontFamily: 'Plus Jakarta Sans',
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatarWidget(
              radius: 16,
              borderWidth: 1,
              borderColor: Color(0xFFBDC9C5),
              backgroundImage: NetworkImage(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuCQoDO5HDML_-jCDeX5iu-UxrdV6wXQiBlgM1h9_b_8maOFPnEeRelYojiFuyFWENs50VmEPD0faASRAQPcL6NIJPMxmAoz4HDjtbD0eMvB7Mw0JjQHxFWZ8p3s6j4ThujK7PtV8VUyRSgBTCtdzLExPjAg-cwV8uaHRIC7LdtWzk4agX6l4oIVDF67hnlGrtfj2WEDTTBg1mJWpWNUQgiFMSBrJFbeP2F6bLZks9ZNVWHT3h8nFiUnx-7orZp7xqkRb_deE7uelic',
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: Column(
              children: [
                // Receipt Card Container
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      // Banner Image Section
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
                                    colors: [
                                      Colors.white,
                                      Colors.transparent,
                                    ],
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
                            const Text(
                              'Booking Confirmed 🎉',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: brandPrimary,
                                fontFamily: 'Plus Jakarta Sans',
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Your professional is on the way.',
                              style: TextStyle(
                                fontSize: 15,
                                color: textSecondary,
                                fontFamily: 'Plus Jakarta Sans',
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),
                      // Dashed Divider with Punched Out Circles
                      const ReceiptDivider(),
                      const SizedBox(height: 16),

                      Padding(
                        padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Provider info block
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Provider Name',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: textSecondary,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Plus Jakarta Sans',
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          provider['name'],
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: brandOnBackground,
                                            fontFamily: 'Plus Jakarta Sans',
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: brandPrimary.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'VERIFIED',
                                            style: TextStyle(
                                              color: brandPrimary,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                              fontFamily: 'Plus Jakarta Sans',
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: brandPrimaryContainer, width: 2),
                                    image: DecorationImage(
                                      image: NetworkImage(provider['imageUrl']),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Grid of Info
                            Row(
                              children: [
                                // Service Time Card
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: brandBackground.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Row(
                                          children: [
                                            Icon(Icons.schedule, color: brandPrimary, size: 16),
                                            SizedBox(width: 4),
                                            Text(
                                              'Service Time',
                                              style: TextStyle(
                                                color: brandPrimary,
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
                                          style: TextStyle(
                                            color: brandOnBackground,
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
                                // Distance Card
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: brandBackground.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Row(
                                          children: [
                                            Icon(Icons.map, color: brandPrimary, size: 16),
                                            SizedBox(width: 4),
                                            Text(
                                              'Distance',
                                              style: TextStyle(
                                                color: brandPrimary,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Plus Jakarta Sans',
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '${provider['distance']} away',
                                          style: TextStyle(
                                            color: brandOnBackground,
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

                            // Rating Detail
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Provider Rating',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: textSecondary,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Plus Jakarta Sans',
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 18),
                                    const SizedBox(width: 4),
                                    Text(
                                      provider['rating'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: brandOnBackground,
                                        fontFamily: 'Plus Jakarta Sans',
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      '(128 reviews)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF6E7A76),
                                        fontFamily: 'Plus Jakarta Sans',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // AI Reasoning Bento Box
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: brandPrimary.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: brandPrimary.withOpacity(0.1)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.auto_awesome, color: brandPrimary, size: 18),
                                      SizedBox(width: 8),
                                      Text(
                                        'AI Matching Reason',
                                        style: TextStyle(
                                          color: brandPrimary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          fontFamily: 'Plus Jakarta Sans',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '"${provider['name']} is your top-rated specialist. They have completed 12 similar tasks in your neighborhood this week with a 100% satisfaction rate."',
                                    style: TextStyle(
                                      color: brandOnBackground,
                                      fontSize: 14,
                                      height: 1.4,
                                      fontStyle: FontStyle.italic,
                                      fontFamily: 'Plus Jakarta Sans',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Confirm Done Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: () {
                                  // Attempt to write the booking to Firestore if Firebase is configured
                                  final bookingPayload = {
                                    'booking_id': 'BK-${DateTime.now().millisecondsSinceEpoch}',
                                    'user_id': 'user_mustafa_001',
                                    'status': 'confirmed',
                                    'provider_name': provider['name'],
                                    'service_time': provider['name'] == 'Zahid electrician' ? 'Today, 2:30 PM' : 'Tomorrow, 10:00 AM',
                                    'provider_distance': provider['distance'],
                                    'provider_rating': provider['rating'],
                                    'reasoning': provider['reasoning'] ?? 'Selected by Khidmat AI.',
                                    'created_at': DateTime.now().toIso8601String(),
                                  };
                                  
                                  try {
                                    FirebaseService.writeBooking(bookingPayload);
                                  } catch (e) {
                                    debugPrint('Firebase Firestore write skipped or failed: $e');
                                  }

                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => BookingSuccessScreen(provider: provider)),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: brandPrimaryContainer,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                  shadowColor: brandPrimary.withOpacity(0.3),
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
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Supportive text
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'A confirmation email and SMS with contact details has been sent to your registered device.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF6E7A76),
                      fontSize: 12,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Footer Help Trigger
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Need help with this booking?',
                    style: TextStyle(
                      color: brandPrimary,
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

// Custom receipt divider with cut circles
class ReceiptDivider extends StatelessWidget {
  const ReceiptDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Dashed Line
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
          // Left Circle Cutout
          const Positioned(
            left: -8,
            child: CircleCutout(),
          ),
          // Right Circle Cutout
          const Positioned(
            right: -8,
            child: CircleCutout(),
          ),
        ],
      ),
    );
  }
}

// Circle cutout helper
class CircleCutout extends StatelessWidget {
  const CircleCutout({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: const BoxDecoration(
        color: Color(0xFFEFF4FF), // Matches the scaffold background color
        shape: BoxShape.circle,
      ),
    );
  }
}

// Circle Avatar Widget Helper
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
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        image: DecorationImage(
          image: backgroundImage,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
