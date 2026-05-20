import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../services/firebase_service.dart';

class BookingSuccessScreen extends StatefulWidget {
  final Map<String, dynamic> provider;

  const BookingSuccessScreen({super.key, required this.provider});

  @override
  State<BookingSuccessScreen> createState() => _BookingSuccessScreenState();
}

class _BookingSuccessScreenState extends State<BookingSuccessScreen> {
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  bool _notificationTriggered = false;
  bool _completionNotificationTriggered = false;

  String _asText(dynamic value, {String fallback = ''}) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) {
      return fallback;
    }
    return text;
  }

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await _localNotifications.initialize(settings: initializationSettings);
  }

  Future<void> _showNotification(String reasoning) async {
    if (_notificationTriggered) return;
    _notificationTriggered = true;

    // Fire 10 seconds after screen loads/confirms booking
    await Future.delayed(const Duration(seconds: 10));

    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'hunarlink_channel',
      'HunarLink Reminders',
      channelDescription: 'Channel for HunarLink booking reminders',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await _localNotifications.show(
      id: 0,
      title: 'HunarLink Reminder',
      body: reasoning,
      notificationDetails: platformChannelSpecifics,
    );
  }

  Future<void> _showCompletionNotification(String message) async {
    if (_completionNotificationTriggered) return;
    _completionNotificationTriggered = true;

    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'hunarlink_completed_channel',
      'HunarLink Completion',
      channelDescription: 'Channel for HunarLink service completions',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await _localNotifications.show(
      id: 1,
      title: 'Service Completed 🎉',
      body: message,
      notificationDetails: platformChannelSpecifics,
    );
  }

  void _showReminderBottomSheet(BuildContext context, Map<String, dynamic> booking) {
    const Color surface = Color(0xFFFFFFFF);
    const Color ink = Color(0xFF1A1415);
    const Color border = Color(0xFFE4D9CF);
    const Color accent = Color(0xFF8C1616);
    const Color primaryTeal = Color(0xFF006053);

    final providerName = booking['provider_name'] ?? 'Your Provider';
    final serviceTime  = booking['service_time']  ?? 'Tomorrow, 10:00 AM';
    final reminderAt   = booking['reminder_at']   ?? '';
    final bookingId    = booking['booking_id']    ?? '#KAI-29402';
    final reasoning    = booking['reasoning']     ?? 'Selected as the best match.';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: border,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.notifications_active_rounded,
                      color: primaryTeal, size: 22),
                ),
                const SizedBox(width: 14),
                Text('Reminder Details',
                  style: TextStyle(
                    color: ink,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _reminderRow(Icons.person_outline_rounded, 'Provider', providerName),
            const Divider(height: 24, color: border),
            _reminderRow(Icons.access_time_rounded, 'Service Time', serviceTime),
            const Divider(height: 24, color: border),
            _reminderRow(Icons.receipt_long_rounded, 'Booking ID', bookingId),
            const Divider(height: 24, color: border),
            _reminderRow(Icons.auto_awesome_rounded, 'AI Reasoning', reasoning),
            if (reminderAt.isNotEmpty) ...[
              const Divider(height: 24, color: border),
              _reminderRow(Icons.alarm_rounded, 'Reminder Set For',
                reminderAt.length > 19
                  ? reminderAt.substring(0, 19).replaceAll('T', '  ')
                  : reminderAt),
            ],
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.notifications_rounded, size: 18),
                label: const Text('Test Notification Now',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _notificationTriggered = false; // Allow re-trigger for demo
                  _showNotification(reasoning);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reminderRow(IconData icon, String label, String value) {
    const Color ink = Color(0xFF1A1415);
    const Color inkMid = Color(0xFF6B5E58);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: inkMid),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                style: const TextStyle(
                  color: inkMid,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
              const SizedBox(height: 2),
              Text(value,
                style: const TextStyle(
                  color: ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Brand Colors
    const Color bg = Color(0xFFF7F2EA);
    const Color surface = Color(0xFFFFFFFF);
    const Color ink = Color(0xFF1A1415);
    const Color inkMid = Color(0xFF6B5E58);
    const Color border = Color(0xFFE4D9CF);
    const Color accent = Color(0xFF8C1616);
    const Color primaryTeal = Color(0xFF006053);

    // Dynamic arrival time text
    final String providerName = _asText(widget.provider['name'], fallback: 'Your Provider');
    final String arrivalTimeText = providerName == 'Zahid electrician'
        ? 'Ali AC Services will arrive tomorrow at 10:00 AM.' // Exact mockup text string
        : '$providerName will arrive today at 2:30 PM.';

    final String reminderDescription = providerName == 'Zahid electrician'
        ? "We'll notify you at 9:00 AM tomorrow so you're ready for the visit."
        : "We'll notify you 1 hour before so you're ready for the visit.";

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseService.bookingStream('user_mustafa_001'),
      builder: (context, snapshot) {
        bool isCompleted = false;
        String resolvedProviderName = providerName;
        String resolvedBookingId = '#KAI-29402';
        String resolvedArrivalText = arrivalTimeText;
        String resolvedReminderDesc = reminderDescription;
        String userId = 'user_mustafa_001';

        if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
          final booking = snapshot.data!.data() as Map<String, dynamic>;
          isCompleted = booking['status'] == 'completed';
          resolvedProviderName = booking['provider_name'] ?? providerName;
          resolvedBookingId = booking['booking_id'] ?? '#KAI-29402';
          userId = booking['user_id'] ?? 'user_mustafa_001';
          final serviceTime = booking['service_time'] ?? 'Tomorrow, 10:00 AM';

          if (isCompleted) {
            resolvedArrivalText = '$resolvedProviderName has completed your service. Thank you for choosing HunarLink!';
            resolvedReminderDesc = 'Service finished. Feedback and rating are active.';
            _showCompletionNotification('$resolvedProviderName has finished the job successfully.');
          } else {
            resolvedArrivalText = resolvedProviderName == 'Zahid electrician' || resolvedProviderName == 'Ali AC Services'
                ? 'Ali AC Services will arrive tomorrow at 10:00 AM.'
                : '$resolvedProviderName will arrive at $serviceTime.';
            resolvedReminderDesc = resolvedProviderName == 'Zahid electrician' || resolvedProviderName == 'Ali AC Services'
                ? "We'll notify you at 9:00 AM tomorrow so you're ready for the visit."
                : "We'll notify you 1 hour before so you're ready for the visit.";
            _showNotification(booking['reasoning'] ?? 'Your booking is confirmed.');
          }
        }

        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: bg,
            elevation: 0,
            leading: Center(
              child: GestureDetector(
                onTap: () {
                  // Navigate back to home screen cleanly
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
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
            centerTitle: true,
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
                  radius: 20,
                  borderWidth: 2,
                  borderColor: border,
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
                    painter: DotsPatternPainter(color: primaryTeal),
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
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
                                            color: primaryTeal.withOpacity(0.05),
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
                                            color: primaryTeal.withOpacity(0.1),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      // Colored Background Circle
                                      Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: primaryTeal.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      // Inner Core Check Circle
                                      Container(
                                        width: 76,
                                        height: 76,
                                        decoration: BoxDecoration(
                                          color: isCompleted ? Colors.green : primaryTeal,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: (isCompleted ? Colors.green : primaryTeal).withOpacity(0.4),
                                              blurRadius: 20,
                                              offset: const Offset(0, 8),
                                            )
                                          ],
                                        ),
                                        child: Icon(
                                          isCompleted ? Icons.star : Icons.check,
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
                              Text(
                                isCompleted ? "Service Completed! 🎉" : "You're all set!",
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  color: primaryTeal,
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
                                    color: inkMid,
                                    height: 1.5,
                                    fontFamily: 'Plus Jakarta Sans',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Reminder Scheduled Card / Service Completed Card
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isCompleted ? const Color(0xFFE8F5E9) : surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isCompleted ? Colors.green.withOpacity(0.3) : border,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryTeal.withOpacity(0.04),
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
                                        color: isCompleted ? Colors.green.withOpacity(0.1) : primaryTeal.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        isCompleted ? Icons.check_circle_outline : Icons.notifications_active,
                                        color: isCompleted ? Colors.green : primaryTeal,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            isCompleted ? 'Kaam Mukammal' : 'Reminder Scheduled',
                                            style: const TextStyle(
                                              color: ink,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              fontFamily: 'Plus Jakarta Sans',
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            resolvedReminderDesc,
                                            style: const TextStyle(
                                              color: inkMid,
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
                                        color: surface,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: border),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Icon(
                                            Icons.person_pin,
                                            color: primaryTeal,
                                            size: 24,
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'SERVICE PROVIDER',
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  color: inkMid,
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
                                                  color: ink,
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
                                        color: surface,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: border),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Icon(
                                            Icons.receipt_long,
                                            color: primaryTeal,
                                            size: 24,
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'BOOKING ID',
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  color: inkMid,
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
                                                  color: ink,
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
                      ),
                    ),
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
                        bg,
                        bg.withOpacity(0.9),
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
                          onPressed: isCompleted
                              ? null
                              : () async {
                                  try {
                                    await FirebaseFirestore.instance
                                        .collection('active_bookings')
                                        .doc(userId)
                                        .update({'status': 'completed'});
                                  } catch (e) {
                                    debugPrint('Error updating status: $e');
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isCompleted ? Colors.grey : accent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            isCompleted ? 'Service Done' : 'Complete Service (Kaam Mukammal)',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // View Reminder bottom sheet button
                      if (!isCompleted && snapshot.hasData && snapshot.data!.exists)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.notifications_active_outlined, size: 18),
                              label: const Text(
                                'View Reminder',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              onPressed: () {
                                final booking = snapshot.data!.data() as Map<String, dynamic>;
                                _showReminderBottomSheet(context, booking);
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: accent,
                                side: const BorderSide(color: accent, width: 1.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () {
                            // Back to Home
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: accent,
                            side: BorderSide(color: accent.withOpacity(0.2), width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Book Another Service',
                            style: TextStyle(
                              color: accent,
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
      },
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
