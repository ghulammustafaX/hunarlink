import 'package:flutter/material.dart';
import 'booking_confirm_screen.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  int _currentNavIndex = 2; // AI Assistant active by default in this flow

  final List<Map<String, dynamic>> providers = const [
    {
      "name": "Zahid electrician",
      "distance": "2.1 km",
      "rating": "4.8",
      "price": "Rs. 1,200",
      "best": true,
      "reasoning": "Closest available with highest rating",
      "imageUrl": "https://lh3.googleusercontent.com/aida-public/AB6AXuAoHBS2x_7o59qdcpQTXqvgGLfIZvEQjEBP6Nb1xMXvnqdJcLsgDYsfFHu9sYfNm_g8JBVBOv1RDGpfY7v5xr8NikvYyYO_3zUI3tfgD_BGnTHXUVrhcQ4_N4g9wq3optmCg67t4ifnQ1aFODbe-tNe1fKug2HYIIX23OpBKLGpqEEma6XcnBdqNnjuBTMhFrilZej7bMzj94sM4R7J97qo2oC5v3bKKdAKFYWOZAVkMXETbeVXPf8_m8skCfBeBu3rmk_d0_vMvgo",
    },
    {
      "name": "Imran Repair Services",
      "distance": "4.5 km",
      "rating": "4.6",
      "price": "Rs. 950",
      "best": false,
      "reasoning": "Reliable option, slightly further away",
      "imageUrl": "https://lh3.googleusercontent.com/aida-public/AB6AXuARYsL_DdANjf4Efd_dCCtK654gEjHhQ0o5giF_IAxjHowr8TNc5wdwyKHGUddYvq7QGzEWbri5AkzmoIKvWOW-dV7rZ4DTmsKJZmZ-pooT7rCRBX4sLGY-nhM4Izd2BeanNh3n5wlpXuV4TH_xT89AI7KNI5-K_ENJ67JD9RroA-j6U_z96KINcW6KNqS6Onp_E6sfC-tu4XeF3NDQkuZXGYMtGOhGdhIBcqLOOMhCZFqrZ6m-DtSlJ-7WatJTkqDsvzs5PyYMKOs",
    },
    {
      "name": "Asif Pro-Electric",
      "distance": "5.2 km",
      "rating": "4.9",
      "price": "Rs. 1,500",
      "best": false,
      "reasoning": "Top rated specialist, premium pricing",
      "imageUrl": "https://lh3.googleusercontent.com/aida-public/AB6AXuAJu8kaz1jVDexb2QVnUCqS7XBK4Vg2Ax7X6T4O51oavJcYt3SzSUjwxc9yFwm7TrPkfT5XOjjIAnrjJ9WG_XlaeL4kyx12EjRKcINlzqcAoDB6ltuYQBSw3sjSPgLQ48V3RzLuPIBylL05pZSAFjsIZ97GR4it1uPspEopvDhNwvsLjM_pe-F1yFU5CUiqMTVuLs7gmTAA4Ldj9tc29u4Z1-cqSA8jjg11niXYX0yjzVnSU2QwdI6ZsiohMqNhz85d2T86gxn1EUM",
    }
  ];

  @override
  Widget build(BuildContext context) {
    // Brand Colors
    const Color brandPrimary = Color(0xFF006053);
    const Color brandPrimaryContainer = Color(0xFF0B7B6B);
    const Color brandBackground = Color(0xFFF8F9FF);
    const Color brandOnBackground = Color(0xFF0B1C30);
    const Color textSecondary = Color(0xFF5D5F5F);

    return Scaffold(
      backgroundColor: brandBackground,
      appBar: AppBar(
        backgroundColor: brandBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: brandPrimary),
          onPressed: () {},
        ),
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
            child: CircleAvatar(
              radius: 16,
              borderWidth: 1,
              borderColor: Color(0xFFBDC9C5),
              backgroundImage: NetworkImage(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuC9aIXaronIGpgzCaAbT9OjTtcygqHlIA42R_nvvQapJQrjnukGOqJmTwzbYVMuRR2s-rkE52PJ8vGF89dqKO8udreKgnfD5sYjok1PiyFZ4sDGsJz8Lf8mLAmlz7kR8FV4KYm5n4wDJH1nGd-i5CATLMm7qNRr6QPoSml-3fMrkZt9rE1LPVrB8GthKh_zTW16Pqz1SXaZJ0EnKBThj9aitDqrBBRV6MLfa1p5TjRPLvEp5DrMfzS_rx5-r6ae2KseHr9clcKEeNY',
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Results Header
              const Center(
                child: Column(
                  children: [
                    Text(
                      'Top Providers Found',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: brandOnBackground,
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'AI selected matches based on your preferences',
                      style: TextStyle(
                        fontSize: 15,
                        color: textSecondary,
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Provider Stack (Vertical List)
              Column(
                children: providers.map((provider) {
                  final isBest = provider['best'] == true;
                  return _buildProviderCard(
                    context: context,
                    provider: provider,
                    isBest: isBest,
                    brandPrimary: brandPrimary,
                    brandPrimaryContainer: brandPrimaryContainer,
                    brandOnBackground: brandOnBackground,
                    textSecondary: textSecondary,
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // AI Reasoning Section (Khidmat Intelligence Insight)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF4FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: brandPrimary.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: brandPrimary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'KHIDMAT INTELLIGENCE INSIGHT',
                          style: TextStyle(
                            color: brandPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            letterSpacing: 1.2,
                            fontFamily: 'Plus Jakarta Sans',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: textSecondary,
                          fontSize: 14,
                          height: 1.5,
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                        children: [
                          const TextSpan(text: "We've analyzed 24 local providers for your request. "),
                          TextSpan(
                            text: "Zahid electrician",
                            style: TextStyle(
                              color: brandPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const TextSpan(
                            text: " was selected as the best match due to their 100% completion rate for similar tasks and proximity, ensuring they can reach you in under 20 minutes.",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 120), // Padding to avoid clipping with bottom nav
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 8, bottom: 20, left: 16, right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: brandPrimary.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home, 'Home', brandPrimaryContainer),
            _buildNavItem(1, Icons.calendar_month, 'Bookings', brandPrimaryContainer),
            _buildNavItem(2, Icons.auto_awesome, 'AI Assistant', brandPrimaryContainer),
            _buildNavItem(3, Icons.person, 'Profile', brandPrimaryContainer),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderCard({
    required BuildContext context,
    required Map<String, dynamic> provider,
    required bool isBest,
    required Color brandPrimary,
    required Color brandPrimaryContainer,
    required Color brandOnBackground,
    required Color textSecondary,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isBest ? brandPrimaryContainer : Colors.black12.withOpacity(0.05),
          width: isBest ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: brandPrimary.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Stack(
        children: [
          Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Provider Image
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(provider['imageUrl']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Provider Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider['name'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: brandOnBackground,
                            fontFamily: 'Plus Jakarta Sans',
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '📍 ${provider['distance']}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF5D5F5F),
                                  fontFamily: 'Plus Jakarta Sans',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Row(
                              children: [
                                Icon(Icons.star, color: brandPrimary, size: 16),
                                const SizedBox(width: 3),
                                Text(
                                  provider['rating'],
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: brandPrimary,
                                    fontFamily: 'Plus Jakarta Sans',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (isBest) ...[
                          const SizedBox(height: 8),
                          Text(
                            '"${provider['reasoning']}"',
                            style: const TextStyle(
                              color: Color(0xFF006147),
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Action Bottom Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'STARTING FROM',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0x9A3E4946),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        provider['price'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isBest ? brandPrimary : brandOnBackground,
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookingConfirmScreen(provider: provider),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isBest ? brandPrimaryContainer : Colors.transparent,
                        foregroundColor: isBest ? Colors.white : brandPrimaryContainer,
                        elevation: isBest ? 2 : 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: isBest
                              ? BorderSide.none
                              : BorderSide(color: brandPrimaryContainer, width: 2),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                      ),
                      child: const Text(
                        'Book Now',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (isBest)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'BEST MATCH',
                      style: TextStyle(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.bold,
                        fontSize: 9,
                        letterSpacing: 0.5,
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                    ),
                    SizedBox(width: 3),
                    Icon(
                      Icons.check_circle,
                      color: Color(0xFF2E7D32),
                      size: 11,
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, Color primaryColor) {
    final isSelected = _currentNavIndex == index;
    return isSelected
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
              ],
            ),
          )
        : GestureDetector(
            onTap: () {
              setState(() {
                _currentNavIndex = index;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: const Color(0xFF3E4946), size: 20),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF3E4946),
                      fontSize: 10,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}

// Custom CircleAvatar Helper
class CircleAvatar extends StatelessWidget {
  final double radius;
  final double borderWidth;
  final Color borderColor;
  final ImageProvider backgroundImage;

  const CircleAvatar({
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
