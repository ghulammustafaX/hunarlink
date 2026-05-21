import 'dart:async';
import 'package:flutter/material.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _loadingController;

  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _logoRotate;
  
  late Animation<double> _textFade;
  late Animation<double> _textSlide;

  late Animation<double> _loadingProgress;

  @override
  void initState() {
    super.initState();

    // 1. Logo Animation (0ms to 1200ms)
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _logoScale = CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
    );

    _logoFade = CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
    );

    _logoRotate = Tween<double>(begin: -0.2, end: 0.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.2, 0.9, curve: Curves.easeOutBack),
      ),
    );

    // 2. Text/Tagline Animation (500ms to 1800ms)
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _textFade = CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeIn),
    );

    _textSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 1.0, curve: Curves.fastLinearToSlowEaseIn),
      ),
    );

    // 3. Horizontal Loading Progress Animation (1200ms to 2600ms)
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _loadingProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _loadingController,
        curve: Curves.easeInOutSine,
      ),
    );

    // Start animations in sequence
    _logoController.forward().then((_) {
      _textController.forward();
      _loadingController.forward();
    });

    // Navigate to HomeScreen after animations complete (approx 3.0s total)
    Timer(const Duration(milliseconds: 3200), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const HomeScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color bg = Color(0xFFF7F2EA); // warm almond beige
    const Color accent = Color(0xFF8C1616); // Brand Crimson
    const Color ink = Color(0xFF1A1415); // Deep Charcoal
    const Color inkMid = Color(0xFF6B5E58); // Taupe

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Stack(
          children: [
            // Top background ambient radial glow (subtle)
            Positioned(
              top: -100,
              left: -100,
              right: -100,
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        accent.withOpacity(0.04),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),
                  
                  // 1. Dynamic Animated App Logo
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, 0),
                        child: Transform.rotate(
                          angle: _logoRotate.value,
                          child: Transform.scale(
                            scale: _logoScale.value,
                            child: Opacity(
                              opacity: _logoFade.value,
                              child: child,
                            ),
                          ),
                        ),
                      );
                    },
                    child: SizedBox(
                      width: 140,
                      height: 140,
                      child: Image.asset(
                        'assets/icon/app_icon.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),

                  // 2. Animated App Title & Tagline
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _textFade.value,
                        child: Transform.translate(
                          offset: Offset(0, _textSlide.value),
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'Hunar',
                              style: TextStyle(
                                color: accent,
                                fontSize: 44,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Plus Jakarta Sans',
                                letterSpacing: -1.5,
                              ),
                            ),
                            Text(
                              'Link',
                              style: TextStyle(
                                color: ink,
                                fontSize: 44,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Plus Jakarta Sans',
                                letterSpacing: -1.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 48),
                          child: Text(
                            'Book any home service in seconds with Just a Text',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: inkMid,
                              fontSize: 14,
                              height: 1.4,
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 2),

                  // 3. Animated Minimalist Progress Track
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 80),
                    child: Column(
                      children: [
                        // Progress Track Container
                        Container(
                          height: 3,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE4D9CF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Stack(
                            children: [
                              AnimatedBuilder(
                                animation: _loadingController,
                                builder: (context, _) {
                                  return FractionallySizedBox(
                                    widthFactor: _loadingProgress.value,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: accent,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: accent.withOpacity(0.4),
                                            blurRadius: 4,
                                            spreadRadius: 1,
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── CUSTOM LOGO WIDGET ──────────────────────────────────────────────────────
// Interlocking loops representing Hunar (Skills/Handcraft) and Link (Digital Connection)
class HunarLinkLogoWidget extends StatelessWidget {
  const HunarLinkLogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    const Color brandCrimson = Color(0xFF8C1616);
    const Color brandDark = Color(0xFF1A1415);
    
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: brandDark.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: brandCrimson.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: CustomPaint(
        painter: _LogoPainter(
          colorOne: brandCrimson,
          colorTwo: brandDark,
        ),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  final Color colorOne;
  final Color colorTwo;

  _LogoPainter({required this.colorOne, required this.colorTwo});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Draw stylized interlocking infinity / chain nodes representation
    final paint1 = Paint()
      ..color = colorOne
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9.0
      ..strokeCap = StrokeCap.round;

    final paint2 = Paint()
      ..color = colorTwo
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9.0
      ..strokeCap = StrokeCap.round;

    // Draw Left Node (Hunar - Crimson)
    final path1 = Path();
    path1.addArc(
      Rect.fromCircle(center: Offset(w * 0.38, h * 0.5), radius: w * 0.26),
      -0.65 * 3.14,
      1.75 * 3.14,
    );
    canvas.drawPath(path1, paint1);

    // Draw Right Node (Link - Charcoal)
    final path2 = Path();
    path2.addArc(
      Rect.fromCircle(center: Offset(w * 0.62, h * 0.5), radius: w * 0.26),
      0.35 * 3.14,
      1.75 * 3.14,
    );
    canvas.drawPath(path2, paint2);

    // Draw interlocking dots at centers
    final dotPaint1 = Paint()
      ..color = colorOne
      ..style = PaintingStyle.fill;
    final dotPaint2 = Paint()
      ..color = colorTwo
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(w * 0.38, h * 0.5), 3.5, dotPaint1);
    canvas.drawCircle(Offset(w * 0.62, h * 0.5), 3.5, dotPaint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
