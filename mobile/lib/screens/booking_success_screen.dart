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
  static const Color softSuccess = Color(0xFF81C784);

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
    final serviceTime  = booking['service_time']  ?? 'Flexible';
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

  // ── Visual Booking Status Timeline ──────────────────────────────────
  Widget _buildStatusTimeline(AsyncSnapshot<DocumentSnapshot> snapshot) {
    // Derive real time strings from booking data
    String receivedTime  = '';
    String providersTime = '';
    String matchTime     = '';
    String confirmedTime = '';
    String serviceTime   = '';
    String reminderTime  = '';

    if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
      final booking = snapshot.data!.data() as Map<String, dynamic>;
      final rawCreated = booking['created_at']?.toString() ?? '';
      final rawService = booking['service_time']?.toString() ?? 'Flexible';
      final rawReminder = booking['reminder_at']?.toString() ?? '';

      // Parse created_at → hh:mm AM/PM
      if (rawCreated.isNotEmpty) {
        try {
          final dt = DateTime.parse(rawCreated);
          final h  = dt.toLocal().hour;
          final m  = dt.toLocal().minute.toString().padLeft(2, '0');
          final period = h >= 12 ? 'PM' : 'AM';
          final hr = h > 12 ? h - 12 : (h == 0 ? 12 : h);
          final stamp = '$hr:$m $period';
          receivedTime  = stamp;
          providersTime = stamp;
          matchTime     = stamp;
          confirmedTime = stamp;
        } catch (_) {}
      }
      serviceTime  = rawService;
      reminderTime = rawReminder.length > 16
          ? rawReminder.substring(0, 16).replaceAll('T', '  ')
          : rawReminder;
    }

    final bool isCompleted = snapshot.hasData
      && snapshot.data != null
      && snapshot.data!.exists
      && ((snapshot.data!.data() as Map<String, dynamic>)['status'] == 'completed');

    const Color timelineGreen  = softSuccess;
    const Color timelinePending = Color(0xFF9E9E9E);

    final List<_TimelineStep> steps = [
      _TimelineStep(icon: Icons.inbox_rounded,           label: 'Request Received',    time: receivedTime,  color: timelineGreen),
      _TimelineStep(icon: Icons.person_search_rounded,   label: 'Providers Found',     time: providersTime, color: timelineGreen),
      _TimelineStep(icon: Icons.auto_awesome_rounded,    label: 'Best Match Selected', time: matchTime,     color: timelineGreen),
      _TimelineStep(icon: Icons.receipt_long_rounded,    label: 'Booking Confirmed',   time: confirmedTime, color: timelineGreen),
      _TimelineStep(icon: Icons.access_time_rounded,     label: 'Service Scheduled',   time: serviceTime,   color: isCompleted ? timelineGreen : timelinePending),
      _TimelineStep(icon: Icons.notifications_active_rounded, label: 'Reminder Set',   time: reminderTime,  color: isCompleted ? timelineGreen : timelinePending),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(color: ink.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.timeline_rounded, color: accent, size: 18),
              ),
              const SizedBox(width: 12),
              const Text(
                'Booking Timeline',
                style: TextStyle(
                  color: ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...List.generate(steps.length, (i) {
            final step = steps[i];
            final isLast = i == steps.length - 1;
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon circle + connector column
                  SizedBox(
                    width: 36,
                    child: Column(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: step.color.withOpacity(0.12),
                            border: Border.all(
                              color: step.color.withOpacity(0.35),
                              width: 1.2,
                            ),
                          ),
                          child: Icon(
                            step.icon,
                            color: step.color,
                            size: 15,
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Center(
                              child: Container(
                                width: 1.5,
                                margin: const EdgeInsets.symmetric(vertical: 3),
                                color: border,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Label + time
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 16, top: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step.label,
                            style: TextStyle(
                              color: step.color,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                          ),
                          if (step.time.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              step.time,
                              style: const TextStyle(
                                color: inkMid,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Plus Jakarta Sans',
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String providerName = _asText(widget.provider['name'], fallback: 'Your Provider');
    final String fallbackBookingId = _asText(widget.provider['booking_id']);
    final String fallbackBookingDocId = _asText(widget.provider['booking_doc_id'], fallback: fallbackBookingId);
    final String fallbackServiceTime = _asText(widget.provider['service_time'], fallback: 'Flexible');
    final String arrivalTimeText = '$providerName will arrive at $fallbackServiceTime.';
    const String reminderDescription = "We'll notify you 1 hour before so you're ready for the visit.";

    return StreamBuilder<DocumentSnapshot>(
      stream: fallbackBookingDocId.isNotEmpty
          ? FirebaseService.bookingStreamById(fallbackBookingDocId)
          : FirebaseService.latestBookingStream('user_mustafa_001'),
      builder: (context, snapshot) {
        bool isCompleted = false;
        String resolvedProviderName = providerName;
        String resolvedBookingId = fallbackBookingId.isNotEmpty ? fallbackBookingId : '#KAI-29402';
        String resolvedArrivalText = arrivalTimeText;
        String resolvedReminderDesc = reminderDescription;
        String bookingDocId = resolvedBookingId;

        if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
          final booking = snapshot.data!.data() as Map<String, dynamic>;
          isCompleted = booking['status'] == 'completed';
          resolvedProviderName = booking['provider_name'] ?? providerName;
          resolvedBookingId = booking['booking_id'] ?? '#KAI-29402';
          bookingDocId = snapshot.data!.id;
          final serviceTime = booking['service_time'] ?? fallbackServiceTime;

          if (isCompleted) {
            resolvedArrivalText = '$resolvedProviderName has completed your service. Thank you for choosing HunarLink!';
            resolvedReminderDesc = 'Service finished. Feedback and rating are active.';
            _showCompletionNotification('$resolvedProviderName has finished the job successfully.');
          } else {
            resolvedArrivalText = '$resolvedProviderName will arrive at $serviceTime.';
            resolvedReminderDesc = reminderDescription;
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
                                          color: isCompleted ? softSuccess : accent,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: (isCompleted ? softSuccess : accent).withOpacity(0.35),
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
                                        color: isCompleted ? softSuccess : accent,
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
                                                resolvedProviderName,
                                                maxLines: 1,
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
                                                maxLines: 1,
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
                                ],
                              ),
                              const SizedBox(height: 20),

                               // ── Booking Status Timeline ──────────────────
                              _buildStatusTimeline(snapshot),

                              const SizedBox(height: 260), // spacer for footer
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
                      // View Reminder Button
                      if (!isCompleted && snapshot.hasData && snapshot.data!.exists) ...[
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.notifications_active_outlined, size: 18),
                            label: const Text(
                              'View Reminder Details',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.w800,
                                fontSize: 14.5,
                              ),
                            ),
                            onPressed: () {
                              final booking = snapshot.data!.data() as Map<String, dynamic>;
                              _showReminderBottomSheet(context, booking);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentBg,
                              foregroundColor: accent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: const BorderSide(color: accent, width: 1.2),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton.icon(
                          onPressed: isCompleted
                              ? null
                              : () async {
                                  try {
                                    await FirebaseFirestore.instance
                                        .collection('active_bookings')
                                        .doc(bookingDocId)
                                        .update({'status': 'completed'});
                                  } catch (e) {
                                    debugPrint('Error updating status: $e');
                                  }
                                },
                          icon: Icon(
                            isCompleted ? Icons.check_circle_rounded : Icons.task_alt_rounded,
                            size: 18,
                          ),
                          label: Text(
                            isCompleted ? 'Service Completed' : 'Complete Service',
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isCompleted ? Colors.grey.shade400 : accent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 3,
                            shadowColor: accent.withOpacity(0.25),
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

// Data class for timeline steps
class _TimelineStep {
  final IconData icon;
  final String label;
  final String time;
  final Color  color;
  const _TimelineStep({
    required this.icon,
    required this.label,
    required this.time,
    required this.color,
  });
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
