import 'package:flutter/material.dart';
import 'booking_confirm_screen.dart';

class ResultsScreen extends StatelessWidget {
  final Map<String, dynamic>? apiResult;
  const ResultsScreen({super.key, this.apiResult});

  static const Color bg      = Color(0xFFF7F2EA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color ink     = Color(0xFF1A1415);
  static const Color inkMid  = Color(0xFF6B5E58);
  static const Color border  = Color(0xFFE4D9CF);
  static const Color accent  = Color(0xFF8C1616);
  static const Color accentBg = Color(0xFFFFEBEB);
  static const Color numGray = Color(0xFFD4C8BC);

  String _asText(dynamic value, {String fallback = ''}) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) {
      return fallback;
    }
    return text;
  }

  List<Map<String, dynamic>> _providers() {
    final fallback = [
      {'name': 'Zahid Electrician',    'distance': '2.1 km', 'rating': '4.8', 'price': 'Rs. 1,200', 'best': true,  'reasoning': 'Closest with highest rating in your area.'},
      {'name': 'Imran Repair Services','distance': '4.5 km', 'rating': '4.6', 'price': 'Rs. 950',   'best': false, 'reasoning': 'Reliable option at a lower price.'},
      {'name': 'Asif Pro-Electric',    'distance': '5.2 km', 'rating': '4.9', 'price': 'Rs. 1,500', 'best': false, 'reasoning': 'Top rated specialist, premium pricing.'},
    ];
    if (apiResult?['data']?['selected'] != null) {
      final s = apiResult!['data']['selected'];
      final reasoning = s['reasoning'] ?? apiResult!['data']['reasoning'] ?? 'Selected by HunarLink AI based on distance & rating.';
      return [
        {'name': s['name'] ?? 'Zahid Electrician', 'distance': s['distance'] ?? '2.1 km', 'rating': s['rating']?.toString() ?? '4.8', 'price': 'Rs. 1,200', 'best': true, 'reasoning': reasoning},
        ...fallback.where((p) => p['best'] != true),
      ];
    }
    return fallback;
  }

  String _intentText() {
    if (apiResult?['data']?['intent'] != null) {
      final i = apiResult!['data']['intent'];
      return '${i['service_type'] ?? 'Service'} · ${i['location'] ?? 'Islamabad'} · ${i['time_preference'] ?? 'ASAP'}';
    }
    return 'AC Technician · G-13 Islamabad · Tomorrow Morning';
  }

  @override
  Widget build(BuildContext context) {
    final providers = _providers();

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(children: [
          // Fixed header
          Container(
            color: bg,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: border)),
                  child: const Icon(Icons.arrow_back_rounded, color: ink, size: 20),
                ),
              ),
              const SizedBox(width: 14),
              RichText(text: const TextSpan(children: [
                TextSpan(text: 'Hunar', style: TextStyle(color: accent, fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Plus Jakarta Sans')),
                TextSpan(text: 'Link', style: TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Plus Jakarta Sans')),
              ])),
            ]),
          ),

          // Scrollable body
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Intent summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surface, borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: border),
                  ),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: accentBg, borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.auto_awesome_rounded, color: accent, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('AI MATCHED', style: TextStyle(color: accent, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2, fontFamily: 'Plus Jakarta Sans')),
                      const SizedBox(height: 2),
                      Text(_intentText(), style: const TextStyle(color: ink, fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Plus Jakarta Sans')),
                    ])),
                  ]),
                ),
                const SizedBox(height: 24),

                const Text('PROVIDERS FOUND', style: TextStyle(color: numGray, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.4, fontFamily: 'Plus Jakarta Sans')),
                const SizedBox(height: 12),

                ...providers.asMap().entries.map((e) => _providerCard(context, e.value, e.key)),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _providerCard(BuildContext context, Map<String, dynamic> p, int idx) {
    final isBest = p['best'] == true;
    final providerName = _asText(p['name'], fallback: 'Service Provider');
    final providerRating = _asText(p['rating'], fallback: '4.8');
    final providerDistance = _asText(p['distance'], fallback: '2.1 km');
    final providerPrice = _asText(p['price'], fallback: 'Rs. 1,000');
    final providerReasoning = _asText(p['reasoning'], fallback: 'Selected by HunarLink AI.');
    final providerInitial = providerName.isNotEmpty ? providerName.substring(0, 1).toUpperCase() : 'S';
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => BookingConfirmScreen(provider: p),
      )),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isBest ? accent : border, width: isBest ? 1.5 : 1),
          boxShadow: [BoxShadow(color: ink.withAlpha(isBest ? 12 : 6), blurRadius: isBest ? 16 : 8, offset: const Offset(0, 3))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Top row
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Avatar placeholder
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: isBest ? accentBg : const Color(0xFFF0E8E0),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    providerInitial,
                    style: TextStyle(color: isBest ? accent : inkMid, fontSize: 20, fontWeight: FontWeight.w800, fontFamily: 'Plus Jakarta Sans'),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(providerName, style: const TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Plus Jakarta Sans'))),
                  if (isBest) Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(6)),
                    child: const Text('TOP PICK', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.8, fontFamily: 'Plus Jakarta Sans')),
                  ),
                ]),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 15),
                  const SizedBox(width: 3),
                  Text(providerRating, style: const TextStyle(color: ink, fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Plus Jakarta Sans')),
                  const SizedBox(width: 10),
                  Icon(Icons.location_on_rounded, color: inkMid, size: 13),
                  const SizedBox(width: 2),
                  Text(providerDistance, style: const TextStyle(color: inkMid, fontSize: 13, fontFamily: 'Plus Jakarta Sans')),
                ]),
              ])),
            ]),
          ),

          // Divider
          Divider(height: 1, color: border),

          // Bottom row
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Estimated Cost', style: TextStyle(color: inkMid, fontSize: 11, fontFamily: 'Plus Jakarta Sans')),
                Text(providerPrice, style: const TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w800, fontFamily: 'Plus Jakarta Sans')),
              ]),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: isBest ? accent : surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isBest ? accent : border),
                ),
                child: Text('Book Now', style: TextStyle(
                  color: isBest ? Colors.white : accent,
                  fontWeight: FontWeight.w700, fontSize: 13, fontFamily: 'Plus Jakarta Sans',
                )),
              ),
            ]),
          ),

          // Reasoning
          if (isBest)
            Container(
              margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: accentBg, borderRadius: BorderRadius.circular(8)),
              child: Row(children: [
                const Icon(Icons.auto_awesome_rounded, color: accent, size: 14),
                const SizedBox(width: 8),
                Expanded(child: Text(providerReasoning, style: const TextStyle(color: accent, fontSize: 12, fontFamily: 'Plus Jakarta Sans'))),
              ]),
            ),
        ]),
      ),
    );
  }
}
