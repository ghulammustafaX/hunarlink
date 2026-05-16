import 'package:flutter/material.dart';
import 'booking_confirm_screen.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  final List<Map<String, dynamic>> providers = const [
    {"name": "Ali AC Services",    "distance": "2.1 km", "rating": "4.8", "best": true,  "time": "10:00 AM", "reasoning": "Closest provider with highest rating"},
    {"name": "Khan Cooling Works", "distance": "3.4 km", "rating": "4.5", "best": false, "time": "11:00 AM", "reasoning": "Good rating, slightly further"},
    {"name": "Quick Fix AC",       "distance": "5.0 km", "rating": "4.1", "best": false, "time": "2:00 PM",  "reasoning": "Available but lower rating"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1B4B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1B4B),
        title: const Text('Nearby Providers', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: providers.length,
        itemBuilder: (_, i) {
          final p = providers[i];
          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookingConfirmScreen(provider: p))),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF374151),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: p['best'] ? const Color(0xFF059669) : Colors.transparent, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(child: Text(p['name'], style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
                    if (p['best']) Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFF059669), borderRadius: BorderRadius.circular(8)),
                      child: const Text('BEST MATCH', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.location_on, color: Color(0xFFBFDBFE), size: 14),
                    Text(' ${p['distance']}', style: const TextStyle(color: Color(0xFFBFDBFE), fontSize: 13)),
                    const SizedBox(width: 16),
                    const Icon(Icons.star, color: Color(0xFFFBBF24), size: 14),
                    Text(' ${p['rating']}', style: const TextStyle(color: Color(0xFFBFDBFE), fontSize: 13)),
                    const SizedBox(width: 16),
                    const Icon(Icons.access_time, color: Color(0xFFBFDBFE), size: 14),
                    Text(' ${p['time']}', style: const TextStyle(color: Color(0xFFBFDBFE), fontSize: 13)),
                  ]),
                  const SizedBox(height: 8),
                  Text(p['reasoning'], style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12, fontStyle: FontStyle.italic)),
                  const SizedBox(height: 12),
                  SizedBox(width: double.infinity, child: ElevatedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookingConfirmScreen(provider: p))),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Book Now', style: TextStyle(color: Colors.white)),
                  )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
