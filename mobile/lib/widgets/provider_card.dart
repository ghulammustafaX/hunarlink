// Reusable provider card widget
// Used in ResultsScreen
import 'package:flutter/material.dart';

class ProviderCard extends StatelessWidget {
  final Map<String, dynamic> provider;
  final VoidCallback onBook;
  const ProviderCard({super.key, required this.provider, required this.onBook});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF374151),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: provider['best'] == true ? const Color(0xFF059669) : Colors.transparent, width: 2),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(provider['name'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('${provider['distance']} · ⭐ ${provider['rating']}', style: const TextStyle(color: Color(0xFFBFDBFE), fontSize: 13)),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: onBook, child: const Text('Book Now')),
      ]),
    );
  }
}
