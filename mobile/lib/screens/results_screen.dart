import 'package:flutter/material.dart';
import 'booking_confirm_screen.dart';

class ResultsScreen extends StatelessWidget {
  final Map<String, dynamic>? apiResult;
  const ResultsScreen({super.key, this.apiResult});

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
        {
          'name': s['name'] ?? 'Zahid Electrician',
          'distance': s['distance'] ?? '2.1 km',
          'rating': s['rating']?.toString() ?? '4.8',
          'price': 'Rs. 1,200',
          'best': true,
          'reasoning': reasoning
        },
        ...fallback.where((p) => p['best'] != true),
      ];
    }
    return fallback;
  }

  String _intentText() {
    if (apiResult?['data']?['intent'] != null) {
      final i = apiResult!['data']['intent'];
      final cat = i['service_category'] ?? i['service_type'] ?? 'Service';
      final loc = i['location'] ?? 'Islamabad';
      final time = i['time_preference'] ?? 'ASAP';
      return '$cat  ·  $loc  ·  ${time.replaceAll('_', ' ')}';
    }
    return 'AC Technician  ·  G-13 Islamabad  ·  Tomorrow Morning';
  }

  @override
  Widget build(BuildContext context) {
    final providers = _providers();

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Immersive Header
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              decoration: const BoxDecoration(
                color: bg,
                border: Border(bottom: BorderSide(color: border, width: 0.8)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
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
                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: ink, size: 16),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(text: 'Hunar', style: TextStyle(color: accent, fontSize: 20, fontWeight: FontWeight.w900, fontFamily: 'Plus Jakarta Sans')),
                              TextSpan(text: 'Link', style: TextStyle(color: ink, fontSize: 20, fontWeight: FontWeight.w900, fontFamily: 'Plus Jakarta Sans')),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'AI Service Matching Results',
                          style: TextStyle(color: inkMid, fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'Plus Jakarta Sans'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Results Panel
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Intent Summary Card with Glassmorphic overlay look
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: border),
                        boxShadow: [
                          BoxShadow(
                            color: ink.withOpacity(0.03),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: accentBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.psychology_rounded, color: accent, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'PARSED AI INTENT',
                                  style: TextStyle(
                                    color: accent,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.5,
                                    fontFamily: 'Plus Jakarta Sans',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _intentText(),
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
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'MATCHED PROFESSIONALS',
                          style: TextStyle(
                            color: numGray,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            fontFamily: 'Plus Jakarta Sans',
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: border.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${providers.length} Found',
                            style: const TextStyle(color: inkMid, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Plus Jakarta Sans'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Cards list
                    ...providers.asMap().entries.map((e) => _providerCard(context, e.value, e.key)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _providerCard(BuildContext context, Map<String, dynamic> p, int idx) {
    final isBest = p['best'] == true;
    final providerName = _asText(p['name'], fallback: 'Service Provider');
    final providerRating = _asText(p['rating'], fallback: '4.8');
    final providerDistance = _asText(p['distance'], fallback: '2.1 km');
    final providerPrice = _asText(p['price'], fallback: 'Rs. 1,200');
    final providerReasoning = _asText(p['reasoning'], fallback: 'Selected by HunarLink AI.');
    final providerInitial = providerName.isNotEmpty ? providerName.substring(0, 1).toUpperCase() : 'S';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isBest ? accent : border, width: isBest ? 2 : 1),
        boxShadow: [
          BoxShadow(
            color: ink.withOpacity(isBest ? 0.08 : 0.03),
            blurRadius: isBest ? 24 : 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ribbon / Top picker bar
          if (isBest)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: const BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(17),
                  topRight: Radius.circular(17),
                ),
              ),
              child: Row(
                children: const [
                  Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                  SizedBox(width: 8),
                  Text(
                    'HUNARLINK RECOMMENDED TOP PICK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Image Frame
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isBest ? accentBg : const Color(0xFFF0E8E0),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isBest ? accent.withOpacity(0.3) : border,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          providerInitial,
                          style: TextStyle(
                            color: isBest ? accent : ink,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Plus Jakarta Sans',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            providerName,
                            style: const TextStyle(
                              color: ink,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              // Rating Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFECE0),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.star_rounded, color: Colors.orange, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      providerRating,
                                      style: const TextStyle(
                                        color: Color(0xFFC25D00),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        fontFamily: 'Plus Jakarta Sans',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Distance indicator
                              const Icon(Icons.navigation_rounded, color: accent, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                providerDistance,
                                style: const TextStyle(
                                  color: inkMid,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Plus Jakarta Sans',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 18),
                Divider(height: 1, color: border.withOpacity(0.6)),
                const SizedBox(height: 18),

                // Pricing and Action Panel
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Estimated Fair Price',
                          style: TextStyle(color: inkMid, fontSize: 11, fontWeight: FontWeight.w500, fontFamily: 'Plus Jakarta Sans'),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          providerPrice,
                          style: const TextStyle(
                            color: ink,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Plus Jakarta Sans',
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookingConfirmScreen(provider: p),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isBest ? accent : surface,
                        foregroundColor: isBest ? Colors.white : accent,
                        elevation: isBest ? 2 : 0,
                        side: BorderSide(color: accent, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Book Now',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: isBest ? Colors.white : accent,
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: isBest ? Colors.white : accent,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // AI Matching Reasoning Block
                if (isBest) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: accentBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: accent.withOpacity(0.12)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2.0),
                          child: Icon(Icons.auto_awesome, color: accent, size: 15),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            providerReasoning,
                            style: const TextStyle(
                              color: accent,
                              fontSize: 12.5,
                              height: 1.4,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
