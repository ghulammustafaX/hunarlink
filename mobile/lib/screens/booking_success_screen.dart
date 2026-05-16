import 'package:flutter/material.dart';

class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1B4B),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(color: Color(0xFF059669), shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 24),
              const Text('Booking Confirmed!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              const Text('Apka booking confirm ho gaya ✓', style: TextStyle(fontSize: 14, color: Color(0xFFBFDBFE))),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xFF374151), borderRadius: BorderRadius.circular(12)),
                child: Column(children: [
                  _receipt('Booking ID',  'BK-2025-001'),
                  _receipt('Provider',    'Ali AC Services'),
                  _receipt('Time',        '10:00 AM Tomorrow'),
                  _receipt('Distance',    '2.1 km'),
                  _receipt('Rating',      '⭐ 4.8'),
                  _receipt('Status',      '✅ Confirmed'),
                ]),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFF1F2937), borderRadius: BorderRadius.circular(12)),
                child: const Row(children: [
                  Icon(Icons.notifications_active, color: Color(0xFFFBBF24), size: 18),
                  SizedBox(width: 8),
                  Expanded(child: Text('Reminder will be sent 1 hour before your appointment.', style: TextStyle(color: Color(0xFFBFDBFE), fontSize: 13))),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _receipt(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      SizedBox(width: 100, child: Text(label, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13))),
      Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500))),
    ]),
  );
}
