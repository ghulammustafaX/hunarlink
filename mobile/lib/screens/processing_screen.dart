import 'dart:async';
import 'package:flutter/material.dart';
import 'results_screen.dart';

class ProcessingScreen extends StatefulWidget {
  final String userInput;
  const ProcessingScreen({super.key, required this.userInput});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulsingController;
  late Animation<double> _pulseOuter;
  late Animation<double> _pulseInner;

  final List<String> _stepLabels = [
    'Understanding your request...',
    'Detecting language: Roman Urdu',
    'Parsed: AC Technician · G-13 · Tomorrow Morning',
    'Searching nearby providers...',
    'Ranking by distance + rating...',
    'Selected best provider. Preparing booking...',
  ];

  final List<bool> _isCompleted = [false, false, false, false, false, false];
  int _activeStepIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Set up pulsing animation for the AI Core
    _pulsingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _pulseOuter = Tween<double>(begin: 1.0, end: 1.6).animate(
      CurvedAnimation(parent: _pulsingController, curve: Curves.easeOut),
    );

    _pulseInner = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulsingController, curve: Curves.easeOut),
    );

    _runPipeline();
  }

  void _runPipeline() {
    const stepDuration = Duration(milliseconds: 1400);
    _timer = Timer.periodic(stepDuration, (timer) {
      if (!mounted) return;

      setState(() {
        if (_activeStepIndex < _stepLabels.length) {
          _isCompleted[_activeStepIndex] = true;
          _activeStepIndex++;
        }

        if (_activeStepIndex == _stepLabels.length) {
          _timer?.cancel();
          _navigateToResults();
        }
      });
    });
  }

  void _navigateToResults() {
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ResultsScreen()),
      );
    });
  }

  @override
  void dispose() {
    _pulsingController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color surfaceDark = Color(0xFF062E28);
    const Color primaryFixedDim = Color(0xFF7BD7C4);
    const Color primaryContainer = Color(0xFF0B7B6B);
    const Color textMint = Color(0xFFB3FFED);
    const Color outlineColor = Color(0xFF6E7A76);

    return Scaffold(
      backgroundColor: surfaceDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Row(
          children: [
            Icon(Icons.menu, color: primaryFixedDim),
            SizedBox(width: 8),
            Text(
              'Khidmat AI 🇵🇰',
              style: TextStyle(
                color: primaryFixedDim,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatarWidget(
              radius: 16,
              borderWidth: 1,
              borderColor: Color(0x4D7BD7C4),
              backgroundImage: NetworkImage(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuDwZX9mLcrFQrHxRqkCjQUaAcU7egyWAa0bEElMgFDqZM88HKtCyZAj1Vu3FUcR6Vp9DtFqHXsPwk52UneshwNZ6g0W7YejdE_akhjdcyTMWzzHVvqX4dN3dUZPJLUKjFJlTjK4eAQUMDrE_rCbHqbbuKXKKKBXHz3yGpV5wGSVrOIK7lNI7wT0Rv-iF6nJNPnFLWdj2ues8c4aYkEMfQQjNWWwbkBf0qk_vbcshVVs0qhxVglwS1gGK5Mk64PCxV9dMop3AVl4WvA',
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      // Header Text
                      const Text(
                        'Agent is working...',
                        style: TextStyle(
                          color: primaryFixedDim,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Securing the best service for your home',
                        style: TextStyle(
                          color: Color(0xCCBDC9C5),
                          fontSize: 15,
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Central Pulsing AI Engine
                      Center(
                        child: SizedBox(
                          width: 192,
                          height: 192,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Pulsing Outer Rings
                              AnimatedBuilder(
                                animation: _pulsingController,
                                builder: (context, child) {
                                  return Opacity(
                                    opacity: (1.6 - _pulseOuter.value).clamp(0.0, 1.0),
                                    child: Transform.scale(
                                      scale: _pulseOuter.value,
                                      child: Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: primaryContainer.withOpacity(0.3),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              AnimatedBuilder(
                                animation: _pulsingController,
                                builder: (context, child) {
                                  return Opacity(
                                    opacity: (1.3 - _pulseInner.value).clamp(0.0, 1.0),
                                    child: Transform.scale(
                                      scale: _pulseInner.value,
                                      child: Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: primaryContainer.withOpacity(0.5),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              // Core Ring
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: primaryFixedDim.withOpacity(0.6),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              // AI Core Icon
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: primaryContainer,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryContainer.withOpacity(0.4),
                                      blurRadius: 25,
                                      spreadRadius: 8,
                                    ),
                                  ],
                                  border: Border.all(
                                    color: primaryFixedDim.withOpacity(0.4),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.auto_awesome,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Intelligent Processing Steps (Bento vertical list)
                      Column(
                        children: List.generate(_stepLabels.length, (index) {
                          final isCompleted = _isCompleted[index];
                          final isActive = _activeStepIndex == index;
                          return _buildStepTile(
                            index: index,
                            text: _stepLabels[index],
                            isCompleted: isCompleted,
                            isActive: isActive,
                            primaryContainer: primaryContainer,
                            primaryFixedDim: primaryFixedDim,
                            textMint: textMint,
                            outlineColor: outlineColor,
                          );
                        }),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
            // Footer status
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0, left: 20.0, right: 20.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(9999),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF71DAB1),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'SYSTEM SECURE & ENCRYPTED',
                      style: TextStyle(
                        color: Color(0xFFBDC9C5),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepTile({
    required int index,
    required String text,
    required bool isCompleted,
    required bool isActive,
    required Color primaryContainer,
    required Color primaryFixedDim,
    required Color textMint,
    required Color outlineColor,
  }) {
    if (isCompleted) {
      // Completed Step Styling
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: primaryFixedDim, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: primaryFixedDim,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else if (isActive) {
      // Active Step Styling
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: primaryContainer.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: primaryContainer.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: textMint,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
              ),
              const Icon(
                Icons.location_on,
                color: Color(0x807BD7C4),
                size: 16,
              ),
            ],
          ),
        ),
      );
    } else {
      // Pending Step Styling
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Opacity(
            opacity: 0.4,
            child: Row(
              children: [
                Icon(Icons.radio_button_off, color: outlineColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: outlineColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}

// Custom CircleAvatar implementation to handle custom borderWidths nicely
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
