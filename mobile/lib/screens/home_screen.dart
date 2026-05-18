import 'package:flutter/material.dart';
import 'processing_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  int _currentNavIndex = 0;

  // Colors
  static const Color brandPrimary = Color(0xFF006053);
  static const Color brandPrimaryContainer = Color(0xFF0B7B6B);
  static const Color brandBackground = Color(0xFFF8F9FF);
  static const Color brandOnBackground = Color(0xFF0B1C30);
  static const Color inputBg = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF6E7A76);

  void _submit({String? presetQuery}) {
    final queryText = presetQuery ?? _controller.text.trim();
    final query = queryText.isEmpty 
        ? "Mujhe AC technician G-13 Islamabad me chahiye subah 10 baje"
        : queryText;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProcessingScreen(userInput: query),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: brandBackground,
      appBar: AppBar(
        backgroundColor: brandBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: brandPrimary),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Menu drawer details triggered!'),
                backgroundColor: brandPrimaryContainer,
              ),
            );
          },
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _currentNavIndex = 3; // Swaps to Profile
                });
              },
              child: const CircleAvatar(
                radius: 16,
                borderWidth: 1,
                borderColor: Color(0xFFBDC9C5),
                backgroundImage: NetworkImage(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuDssL5c18tNaw6jcEGgNBGUjKKgoyxFBrVNDhodnPyzeNJnr7BN5lWoZZ2V7pUK-l4kfxWBwkViBd2dReHOoRMoaoFZSc3MPd2TgtAI9dqck9roxmauVaz9bOcfTNQ33aJCPA7dGPW6UK4dDXXgPGpcajStUcDsYBr8s9vDSuvExIFZJvGHqBIhss3VUH_1ns00s1DDdzgZOHikbNsAA9jbt5m7JsQRz0MqsZGfJTIUNZD8WRXIUFWLZBviRCH_fvCghb8_g5roNUM',
                ),
              ),
            ),
          ),
        ],
      ),
      body: _buildCurrentBody(),
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
            _buildNavItem(index: 0, icon: Icons.home, label: 'Home'),
            _buildNavItem(index: 1, icon: Icons.calendar_month, label: 'Bookings'),
            _buildNavItem(index: 2, icon: Icons.auto_awesome, label: 'Assistant'),
            _buildNavItem(index: 3, icon: Icons.person, label: 'Profile'),
          ],
        ),
      ),
    );
  }

  // Switches between full MVP activities programmatically!
  Widget _buildCurrentBody() {
    switch (_currentNavIndex) {
      case 0:
        return _buildHomeDashboardTab();
      case 1:
        return _buildBookingsTab();
      case 2:
        return _buildAssistantTab();
      case 3:
        return _buildProfileTab();
      default:
        return _buildHomeDashboardTab();
    }
  }

  // ================= TAB 0: HOME DASHBOARD =================
  Widget _buildHomeDashboardTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Hero Heading
            const Text(
              'Apni Zaroorat\nBatayein',
              style: TextStyle(
                color: brandOnBackground,
                fontSize: 32,
                fontWeight: FontWeight.w800,
                height: 1.2,
                letterSpacing: -0.8,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
            const SizedBox(height: 20),

            // Search Input Container
            Container(
              decoration: BoxDecoration(
                color: inputBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: brandOnBackground, fontSize: 16),
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Koi bhi service dhundein... (e.g. AC technician G-13)',
                  hintStyle: TextStyle(color: Color(0x9A3E4946), fontSize: 15),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Language Badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: brandPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: brandPrimary, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'EN / UR / Roman UR supported',
                        style: TextStyle(
                          color: brandPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Primary Action Button (Dhundein)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => _submit(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandPrimaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  shadowColor: brandPrimary.withOpacity(0.3),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Dhundein',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Bento Grid header
            const Text(
              'Popular Services',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: brandOnBackground,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
            const SizedBox(height: 16),

            // 1. Bento Banner: Khidmat Assistant (INTERACTIVE)
            GestureDetector(
              onTap: () {
                _controller.text = "Mujhe AC technician chahiye G-13 Islamabad me subah 10 baje";
                _submit(presetQuery: "Mujhe AC technician chahiye G-13 Islamabad me subah 10 baje");
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF4FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: brandPrimary.withOpacity(0.08)),
                  boxShadow: [
                    BoxShadow(
                      color: brandPrimary.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: const Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI POWERED',
                          style: TextStyle(
                            color: brandPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                            fontFamily: 'Plus Jakarta Sans',
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Khidmat Assistant',
                          style: TextStyle(
                            color: brandOnBackground,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Plus Jakarta Sans',
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Tap to match AC tech, plumbers, tutors instantly!',
                          style: TextStyle(
                            color: Color(0xFF3E4946),
                            fontSize: 13,
                            fontFamily: 'Plus Jakarta Sans',
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: Icon(
                        Icons.auto_awesome,
                        color: brandPrimary,
                        size: 44,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 2. Grid Items: Electrician & Cleaning (INTERACTIVE)
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _controller.text = "Need an Electrician near me in Islamabad";
                      _submit(presetQuery: "Need an Electrician near me in Islamabad");
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black.withOpacity(0.05)),
                        boxShadow: [
                          BoxShadow(
                            color: brandPrimary.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: brandPrimary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.electric_bolt, color: brandPrimary),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Electrician Services',
                            style: TextStyle(
                              color: brandOnBackground,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _controller.text = "Deep Cleaning services in G-13 Islamabad";
                      _submit(presetQuery: "Deep Cleaning services in G-13 Islamabad");
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black.withOpacity(0.05)),
                        boxShadow: [
                          BoxShadow(
                            color: brandPrimary.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: brandPrimary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.cleaning_services, color: brandPrimary),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Cleaning Services',
                            style: TextStyle(
                              color: brandOnBackground,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ================= TAB 1: MY BOOKINGS ACTIVITY =================
  Widget _buildBookingsTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Bookings',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: brandOnBackground,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Real-time status of your local services',
              style: TextStyle(fontSize: 14, color: textSecondary, fontFamily: 'Plus Jakarta Sans'),
            ),
            const SizedBox(height: 20),

            // Active Booking Card (Zahid)
            _buildBookingCard(
              providerName: "Zahid Electrician",
              serviceName: "AC & Fan Specialist",
              statusText: "CONFIRMED",
              statusColor: Colors.green,
              price: "Rs. 1,200",
              distance: "📍 2.1 km away",
              timeSlot: "Today, 2:30 PM",
              bookingId: "BK-940291",
            ),
            const SizedBox(height: 16),

            // Pre-existing Mock Booking Card
            _buildBookingCard(
              providerName: "Ali Deep Cleaning",
              serviceName: "Full House Wash & Sofa Clean",
              statusText: "COMPLETED",
              statusColor: Colors.blue,
              price: "Rs. 3,500",
              distance: "📍 3.4 km away",
              timeSlot: "12th May, 11:00 AM",
              bookingId: "BK-829104",
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard({
    required String providerName,
    required String serviceName,
    required String statusText,
    required Color statusColor,
    required String price,
    required String distance,
    required String timeSlot,
    required String bookingId,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: brandPrimary.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: brandPrimary.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  borderWidth: 1,
                  borderColor: brandPrimary.withOpacity(0.1),
                  backgroundImage: const NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuDssL5c18tNaw6jcEGgNBGUjKKgoyxFBrVNDhodnPyzeNJnr7BN5lWoZZ2V7pUK-l4kfxWBwkViBd2dReHOoRMoaoFZSc3MPd2TgtAI9dqck9roxmauVaz9bOcfTNQ33aJCPA7dGPW6UK4dDXXgPGpcajStUcDsYBr8s9vDSuvExIFZJvGHqBIhss3VUH_1ns00s1DDdzgZOHikbNsAA9jbt5m7JsQRz0MqsZGfJTIUNZD8WRXIUFWLZBviRCH_fvCghb8_g5roNUM',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            providerName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: brandOnBackground,
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                                fontFamily: 'Plus Jakarta Sans',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        serviceName,
                        style: const TextStyle(fontSize: 13, color: textSecondary, fontFamily: 'Plus Jakarta Sans'),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14, color: brandPrimary.withOpacity(0.7)),
                          const SizedBox(width: 4),
                          Text(
                            timeSlot,
                            style: const TextStyle(fontSize: 12, color: brandPrimary, fontWeight: FontWeight.w600, fontFamily: 'Plus Jakarta Sans'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "ID: $bookingId",
                  style: const TextStyle(fontSize: 12, color: textSecondary, fontWeight: FontWeight.w500),
                ),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: brandPrimary,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= TAB 2: AI ASSISTANT CHAT SCREEN =================
  Widget _buildAssistantTab() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            physics: const BouncingScrollPhysics(),
            children: [
              const SizedBox(height: 10),
              // AI Welcome Bubble
              _buildChatBubble(
                isAI: true,
                message: "Salaam! I am your Khidmat AI assistant. I can match you with the highest-rated service providers in G-13 Islamabad in seconds. What do you need today?",
              ),
              const SizedBox(height: 16),
              // Preset suggestions
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildChatPresetChip("💡 AC technician in G-13 tomorrow morning"),
                  _buildChatPresetChip("💡 Urgent Plumber required now"),
                  _buildChatPresetChip("💡 Deep cleaner in G-13 Islamabad"),
                ],
              ),
            ],
          ),
        ),
        
        // Dynamic bottom message bar
        Container(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, -2),
              )
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Type service request in English or Roman Urdu...",
                      hintStyle: TextStyle(fontSize: 14, color: textSecondary),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 22,
                borderWidth: 0,
                borderColor: Colors.transparent,
                backgroundImage: const NetworkImage('https://cdn-icons-png.flaticon.com/512/1077/1077114.png'), // placeholder
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white, size: 18),
                  onPressed: () => _submit(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChatBubble({required bool isAI, required String message}) {
    return Row(
      mainAxisAlignment: isAI ? MainAxisAlignment.start : MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isAI) ...[
          const CircleAvatar(
            radius: 16,
            borderWidth: 0,
            borderColor: Colors.transparent,
            backgroundImage: NetworkImage('https://cdn-icons-png.flaticon.com/512/8649/8649607.png'),
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isAI ? Colors.white : brandPrimary,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isAI ? 4 : 16),
                bottomRight: Radius.circular(isAI ? 16 : 4),
              ),
              boxShadow: [
                if (isAI)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  )
              ],
            ),
            child: Text(
              message,
              style: TextStyle(
                color: isAI ? brandOnBackground : Colors.white,
                fontSize: 14,
                height: 1.4,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChatPresetChip(String promptText) {
    return ActionChip(
      label: Text(
        promptText,
        style: const TextStyle(fontSize: 12, color: brandPrimary, fontWeight: FontWeight.w600, fontFamily: 'Plus Jakarta Sans'),
      ),
      backgroundColor: const Color(0xFFEFF4FF),
      side: BorderSide(color: brandPrimary.withOpacity(0.05)),
      onPressed: () {
        _controller.text = promptText.replaceFirst("💡 ", "");
        _submit(presetQuery: _controller.text);
      },
    );
  }

  // ================= TAB 3: USER PROFILE SCREEN =================
  Widget _buildProfileTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Avatar with verified badge
            Stack(
              children: [
                CircleAvatar(
                  radius: 54,
                  borderWidth: 3,
                  borderColor: brandPrimary,
                  backgroundImage: const NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuDssL5c18tNaw6jcEGgNBGUjKKgoyxFBrVNDhodnPyzeNJnr7BN5lWoZZ2V7pUK-l4kfxWBwkViBd2dReHOoRMoaoFZSc3MPd2TgtAI9dqck9roxmauVaz9bOcfTNQ33aJCPA7dGPW6UK4dDXXgPGpcajStUcDsYBr8s9vDSuvExIFZJvGHqBIhss3VUH_1ns00s1DDdzgZOHikbNsAA9jbt5m7JsQRz0MqsZGfJTIUNZD8WRXIUFWLZBviRCH_fvCghb8_g5roNUM',
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 16),
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),

            // Profile info
            const Text(
              'Ghulam Mustafa',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: brandOnBackground, fontFamily: 'Plus Jakarta Sans'),
            ),
            const Text(
              'HunarLink MVP Hackathon Guest',
              style: TextStyle(fontSize: 13, color: textSecondary, fontFamily: 'Plus Jakarta Sans'),
            ),
            const SizedBox(height: 24),

            // Bento Details Box
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: brandPrimary.withOpacity(0.06)),
              ),
              child: const Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Registered Phone', style: TextStyle(color: textSecondary, fontSize: 13)),
                      Text('+92 300 1234567', style: TextStyle(color: brandOnBackground, fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  Divider(height: 24, thickness: 1, color: Color(0xFFF1F5F9)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Primary Location', style: TextStyle(color: textSecondary, fontSize: 13)),
                      Text('G-13, Islamabad', style: TextStyle(color: brandOnBackground, fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  Divider(height: 24, thickness: 1, color: Color(0xFFF1F5F9)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Account Status', style: TextStyle(color: textSecondary, fontSize: 13)),
                      Row(
                        children: [
                          Icon(Icons.verified, color: Colors.green, size: 16),
                          SizedBox(width: 4),
                          Text('VERIFIED CLIENT', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Log out mockup action button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile settings locked in hackathon mode.'),
                      backgroundColor: brandPrimaryContainer,
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: brandPrimary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Account Settings',
                  style: TextStyle(color: brandPrimary, fontWeight: FontWeight.bold, fontFamily: 'Plus Jakarta Sans'),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ================= COMMON BOTTOM NAV NAVIGATOR ITEM =================
  Widget _buildNavItem({required int index, required IconData icon, required String label}) {
    final isSelected = _currentNavIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentNavIndex = index;
        });
      },
      child: isSelected
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: brandPrimaryContainer,
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
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                ],
              ),
            )
          : Padding(
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

// Custom CircleAvatar Helper with Border
class CircleAvatar extends StatelessWidget {
  final double radius;
  final double borderWidth;
  final Color borderColor;
  final ImageProvider backgroundImage;
  final Widget? child;

  const CircleAvatar({
    super.key,
    required this.radius,
    required this.borderWidth,
    required this.borderColor,
    required this.backgroundImage,
    this.child,
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
      child: child,
    );
  }
}
