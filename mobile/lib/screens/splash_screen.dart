import 'dart:async';
import 'package:flutter/material.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color brandPrimary = Color(0xFF006053);
    const Color accentColor = Color(0xFF8C1616);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F2EA), // Matches HomeScreen.bg
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Animated Hero Text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Hunar',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Plus Jakarta Sans',
                      letterSpacing: -1.0,
                    ),
                  ),
                  Text(
                    'Link',
                    style: TextStyle(
                      color: Color(0xFF1A1415),
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Plus Jakarta Sans',
                      letterSpacing: -1.0,
                    ),
                  ),
                  Text(
                    ' 🇵🇰',
                    style: TextStyle(fontSize: 36),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Book any home service in seconds — in your language',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF6B5E58), // Matches inkMid
                    fontSize: 14,
                    height: 1.4,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(brandPrimary),
              ),
              const SizedBox(height: 48),
              const Text(
                'Google Antigravity Hackathon 2026',
                style: TextStyle(
                  color: Color(0xFFD4C8BC), // Matches numGray
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
