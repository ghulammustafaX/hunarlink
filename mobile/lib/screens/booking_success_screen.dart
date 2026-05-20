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
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accentBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.notifications_active_rounded, color: accent, size: 24),
                ),
                const SizedBox(width: 14),
                const Text(
                  'Reminder Details',
                  style: TextStyle(
                    color: ink,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
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
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.notifications_rounded, size: 18),
                label: const Text(
                  'Test Notification Now',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w800,
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reminderRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: inkMid),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: inkMid,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  color: ink,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
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
    // Dynamic arrival time text
    final String providerName = _asText(widget.provider['name'], fallback: 'Your Provider');
    final String arrivalTimeText = providerName == 'Zahid electrician'
        ? 'Ali AC Services will arrive tomorrow at 10:00 AM.'
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
                  child: const Icon(Icons.close_rounded, color: ink, size: 18),
                ),
              ),
            ),
            centerTitle: true,
            title: RichText(
              text: const TextSpan(children: [
                TextSpan(text: 'Hunar', style: TextStyle(color: accent, fontSize: 20, fontWeight: FontWeight.w900, fontFamily: 'Plus Jakarta Sans')),
                TextSpan(text: 'Link', style: TextStyle(color: ink, fontSize: 20, fontWeight: FontWeight.w900, fontFamily: 'Plus Jakarta Sans')),
              ]),
            ),
          ),
          body: Stack(
            children: [
              // Background pattern decoration
              Positioned.fill(
                child: Opacity(
                  opacity: 0.05,
                  child: CustomPaint(
                    painter: DotsPatternPainter(color: accent),
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 20),
                              // Hero Success Rings
                              Center(
                                child: SizedBox(
                                  width: 170,
                                  height: 170,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Outer ring 2
                                      Container(
                                        width: 170,
                                        height: 170,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: accent.withOpacity(0.05),
                                            width: 2.5,
                                          ),
                                        ),
                                      ),
                                      // Outer ring 1
                                      Container(
                                        width: 140,
                                        height: 140,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: accent.withOpacity(0.12),
                                            width: 2.5,
                                          ),
                                        ),
                                      ),
                                      // Soft glow fill
                                      Container(
                                        width: 108,
                                        height: 108,
                                        decoration: BoxDecoration(
                                          color: accentBg,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      // Inner active core
                                      Container(
                                        width: 82,
                                        height: 82,
                                        decoration: BoxDecoration(
                                          color: isCompleted ? const Color(0xFF2E7D32) : accent,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: (isCompleted ? const Color(0xFF2E7D32) : accent).withOpacity(0.35),
                                              blurRadius: 22,
                                              offset: const Offset(0, 10),
                                            )
                                          ],
                                        ),
                                        child: Icon(
                                          isCompleted ? Icons.check_circle_rounded : Icons.check_rounded,
                                          color: Colors.white,
                                          size: 44,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 36),

                              // Typography Header
                              Text(
                                isCompleted ? "Kaam Mukammal! 🎉" : "Booking Successful!",
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: ink,
                                  letterSpacing: -0.8,
                                  fontFamily: 'Plus Jakarta Sans',
                                ),
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text(
                                  resolvedArrivalText,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 15.5,
                                    color: inkMid,
                                    height: 1.5,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Plus Jakarta Sans',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 36),

                              // Status Info Box
                              Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: isCompleted ? const Color(0xFFE8F5E9) : surface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isCompleted ? const Color(0xFF81C784).withOpacity(0.5) : border,
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: ink.withOpacity(0.02),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    )
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: isCompleted ? const Color(0xFFC8E6C9) : accentBg,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        isCompleted ? Icons.stars_rounded : Icons.notifications_active_rounded,
                                        color: isCompleted ? const Color(0xFF2E7D32) : accent,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            isCompleted ? 'Kaam Mukammal' : 'Auto Reminder Scheduled',
                                            style: const TextStyle(
                                              color: ink,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 14.5,
                                              fontFamily: 'Plus Jakarta Sans',
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            resolvedReminderDesc,
                                            style: const TextStyle(
                                              color: inkMid,
                                              fontSize: 13,
                                              height: 1.45,
                                              fontFamily: 'Plus Jakarta Sans',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Bento Details Block
                              Row(
                                children: [
                                  // Provider Card
                                  Expanded(
                                    child: Container(
                                      height: 110,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: surface,
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(color: border),
                                        boxShadow: [
                                          BoxShadow(color: ink.withOpacity(0.015), blurRadius: 10, offset: const Offset(0, 4))
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Icon(Icons.person_pin_rounded, color: accent, size: 24),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'SERVICE PROVIDER',
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  color: inkMid,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: 0.5,
                                                  fontFamily: 'Plus Jakarta Sans',
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                resolvedProviderName == 'Zahid electrician' ? 'Ali AC Services' : resolvedProviderName,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 14.5,
                                                  fontWeight: FontWeight.w800,
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
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(color: border),
                                        boxShadow: [
                                          BoxShadow(color: ink.withOpacity(0.015), blurRadius: 10, offset: const Offset(0, 4))
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Icon(Icons.receipt_long_rounded, color: accent, size: 24),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'BOOKING ID',
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  color: inkMid,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: 0.5,
                                                  fontFamily: 'Plus Jakarta Sans',
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                resolvedBookingId,
                                                style: const TextStyle(
                                                  fontSize: 14.5,
                                                  fontWeight: FontWeight.w800,
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
                              const SizedBox(height: 140), // spacer for footer
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Sticky Footer Actions with smooth background fade overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.only(top: 20, bottom: 28, left: 24, right: 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        bg,
                        bg.withOpacity(0.95),
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
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                            shadowColor: accent.withOpacity(0.2),
                          ),
                          child: Text(
                            isCompleted ? 'Service Completed ✓' : 'Complete Service (Kaam Mukammal)',
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w855,
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // View Reminder Button
                      if (!isCompleted && snapshot.hasData && snapshot.data!.exists)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.notifications_active_outlined, size: 18),
                              label: const Text(
                                'View Reminder Details',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontWeight: FontWeight.w800,
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
                                  borderRadius: BorderRadius.circular(14),
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
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: ink,
                            side: BorderSide(color: border, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Back to Home Screen',
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
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

// Background custom painter for subtle dots pattern
class DotsPatternPainter extends CustomPainter {
  final Color color;

  DotsPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.04)
      ..style = PaintingStyle.fill;

    const double spacing = 28.0;
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
