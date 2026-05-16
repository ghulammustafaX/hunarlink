import 'package:flutter/material.dart';
import 'booking_success_screen.dart';

class BookingConfirmScreen extends StatelessWidget {
  final Map<String, dynamic> provider;
  const BookingConfirmScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1B4B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1B4B),
        title: const Text('Confirm Booking', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFF374151), borderRadius: BorderRadius.circular(12)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Booking Summary', style: TextStyle(color: Color(0xFFBFDBFE), fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _row('Provider',  provider['name']),
                _row('Service',   'AC Technician'),
                _row('Time',      provider['time']),
                _row('Distance',  provider['distance']),
                _row('Rating',    '⭐ ${provider['rating']}'),
                _row('Location',  'G-13, Islamabad'),
              ]),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF1F2937), borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                const Icon(Icons.info_outline, color: Color(0xFFBFDBFE), size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(provider['reasoning'], style: const TextStyle(color: Color(0xFFBFDBFE), fontSize: 13))),
              ]),
            ),
            const Spacer(),
            SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const BookingSuccessScreen())),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Confirm Booking ✓', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
            )),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      SizedBox(width: 80, child: Text(label, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13))),
      Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500))),
    ]),
  );
}
