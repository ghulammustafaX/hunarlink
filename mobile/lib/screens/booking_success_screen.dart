import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import 'home_screen.dart';

class BookingSuccessScreen extends StatelessWidget {
  final Map<String, dynamic> provider;

  const BookingSuccessScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    // Brand Colors
    const Color brandPrimary = Color(0xFF006053);
    const Color brandPrimaryContainer = Color(0xFF0B7B6B);
    const Color brandBackground = Colors.white; // bg-surface-container-lowest in light theme
    const Color brandOnBackground = Color(0xFF0B1C30);
    const Color textSecondary = Color(0xFF5D5F5F);

    // Dynamic arrival time text
    final String providerName = provider['name'];
    final String arrivalTimeText = providerName == 'Zahid electrician'
        ? 'Ali AC Services will arrive tomorrow at 10:00 AM.' // Exact mockup text string
        : '$providerName will arrive today at 2:30 PM.';

    final String reminderDescription = providerName == 'Zahid electrician'
        ? "We'll notify you at 9:00 AM tomorrow so you're ready for the visit."
        : "We'll notify you 1 hour before so you're ready for the visit.";

    return Scaffold(
      backgroundColor: brandBackground,
      appBar: AppBar(
        backgroundColor: brandBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: brandPrimary),
          onPressed: () {
            // Navigate back to home screen cleanly
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
        centerTitle: true,
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
              radius: 20,
              borderWidth: 2,
              borderColor: Color(0x330B7B6B),
              backgroundImage: NetworkImage(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuBChnwjrYEGK3B5gWPeF82S7_Eb6sBUR9NC4U6kw1LgFFrHEpdH5jhXtQfDA0yVUUad7xWTPqcLChU1PC1jhMh9jq3gd4kKuSCfMy-MMXuZHboV7_yzNug0ridSHnkp67ed-foWpJddQ1CFQBwV2gVWIU72FWI37z0vc1lcwwsP880hkz6DE0Zm3YqvlDsTPgTfbTYPXOP86-SZAPsGJl22AwBo1EmiVMViFYvXXGQowgIc5KX6aKXRYVBv-hvWjbIBHsZvlbIwJWY',
              ),
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          // Background grid/confetti-like pattern decoration
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: CustomPaint(
                painter: DotsPatternPainter(color: brandPrimaryContainer),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseService.bookingStream('user_mustafa_001'),
                    builder: (context, snapshot) {
                      String resolvedProviderName = providerName;
                      String resolvedBookingId = '#KAI-29402';
                      String resolvedArrivalText = arrivalTimeText;
                      String resolvedReminderDesc = reminderDescription;

                      if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
                        final booking = snapshot.data!.data() as Map<String, dynamic>;
                        resolvedProviderName = booking['provider_name'] ?? providerName;
                        resolvedBookingId = booking['booking_id'] ?? '#KAI-29402';
                        final serviceTime = booking['service_time'] ?? 'Tomorrow, 10:00 AM';
                        resolvedArrivalText = resolvedProviderName == 'Zahid electrician' || resolvedProviderName == 'Ali AC Services'
                            ? 'Ali AC Services will arrive tomorrow at 10:00 AM.'
                            : '$resolvedProviderName will arrive at $serviceTime.';
                        resolvedReminderDesc = resolvedProviderName == 'Zahid electrician' || resolvedProviderName == 'Ali AC Services'
                            ? "We'll notify you at 9:00 AM tomorrow so you're ready for the visit."
                            : "We'll notify you 1 hour before so you're ready for the visit.";
                      }

                      return SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 24),
                              // Hero Animation/Icon Area (Nested Rings)
                              Center(
                                child: SizedBox(
                                  width: 160,
                                  height: 160,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Outer Ring 2
                                      Container(
                                        width: 160,
                                        height: 160,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: brandPrimaryContainer.withOpacity(0.05),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      // Outer Ring 1
                                      Container(
                                        width: 130,
                                        height: 130,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: brandPrimaryContainer.withOpacity(0.1),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      // Colored Background Circle
                                      Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: brandPrimaryContainer.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      // Inner Core Check Circle
                                      Container(
                                        width: 76,
                                        height: 76,
                                        decoration: BoxDecoration(
                                          color: brandPrimaryContainer,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: brandPrimaryContainer.withOpacity(0.4),
                                              blurRadius: 20,
                                              offset: const Offset(0, 8),
                                            )
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 40,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Typography Header
                              const Text(
                                "You're all set!",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  color: brandPrimary,
                                  letterSpacing: -0.8,
                                  fontFamily: 'Plus Jakarta Sans',
                                ),
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                child: Text(
                                  resolvedArrivalText,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: textSecondary,
                                    height: 1.5,
                                    fontFamily: 'Plus Jakarta Sans',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Reminder Scheduled Card
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8F9FF),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFBDC9C5).withOpacity(0.3),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: brandPrimary.withOpacity(0.04),
                                      blurRadius: 20,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF006147).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.notifications_active,
                                        color: Color(0xFF006147),
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Reminder Scheduled',
                                            style: TextStyle(
                                              color: brandOnBackground,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              fontFamily: 'Plus Jakarta Sans',
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            resolvedReminderDesc,
                                            style: const TextStyle(
                                              color: textSecondary,
                                              fontSize: 13,
                                              height: 1.4,
                                              fontFamily: 'Plus Jakarta Sans',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Bento-style Provider Details Preview
                              Row(
                                children: [
                                  // Provider Card
                                  Expanded(
                                    child: Container(
                                      height: 110,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF4FF),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Icon(
                                            Icons.person_pin,
                                            color: brandPrimaryContainer,
                                            size: 24,
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'SERVICE PROVIDER',
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  color: Color(0x9A3E4946),
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0.5,
                                                  fontFamily: 'Plus Jakarta Sans',
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                resolvedProviderName == 'Zahid electrician' ? 'Ali AC Services' : resolvedProviderName,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: brandOnBackground,
                                                  fontFamily: 'Plus Jakarta Sans',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Booking ID Card
                                  Expanded(
                                    child: Container(
                                      height: 110,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF4FF),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Icon(
                                            Icons.receipt_long,
                                            color: brandPrimaryContainer,
                                            size: 24,
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'BOOKING ID',
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  color: Color(0x9A3E4946),
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0.5,
                                                  fontFamily: 'Plus Jakarta Sans',
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                resolvedBookingId,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: brandOnBackground,
                                                  fontFamily: 'Plus Jakarta Sans',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 120), // Padding to avoid clipping footer buttons
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),,
              ],
            ),
          ),
          // Sticky Footer Actions
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 16, bottom: 24, left: 20, right: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    brandBackground,
                    brandBackground.withOpacity(0.9),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'View Booking Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () {
                        // Back to Home
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: brandPrimaryContainer.withOpacity(0.2), width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Book Another Service',
                        style: TextStyle(
                          color: brandPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Background custom painter for subtle dot confetti pattern
class DotsPatternPainter extends CustomPainter {
  final Color color;

  DotsPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    const double spacing = 24.0;
    const double radius = 1.5;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom CircleAvatar Widget Helper
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
