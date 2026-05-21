import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'results_screen.dart';

class ProcessingScreen extends StatefulWidget {
  final String userInput;
  final String? userLocation;
  const ProcessingScreen({super.key, required this.userInput, this.userLocation});
  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _fadeCtrl;
  late Animation<double> _pulse;
  late Animation<double> _fadeIn;

  static const Color bg      = Color(0xFFF7F2EA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color ink     = Color(0xFF1A1415);
  static const Color inkMid  = Color(0xFF6B5E58);
  static const Color border  = Color(0xFFE4D9CF);
  static const Color accent  = Color(0xFF8C1616);
  static const Color numGray = Color(0xFFD4C8BC);

  final List<String> _steps = [
    'Understanding your request...',
    'Detecting language & intent',
    'Parsing service type & location',
    'Searching nearby providers...',
    'Ranking by distance & rating...',
    'Preparing your booking...',
  ];
  final List<bool> _done = [false, false, false, false, false, false];
  int _active = 0;
  Timer? _timer;
  bool _apiDone = false;
  bool _animDone = false;
  Map<String, dynamic>? _apiResult;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _fadeCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..forward();
    _pulse  = Tween<double>(begin: 1.0, end: 1.4).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _fadeIn = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fetchData();
    _runSteps();
  }

  void _fetchData() async {
    try {
      final res = await ApiService.processRequest(
        widget.userInput,
        location: widget.userLocation,
      );
      if (mounted) { setState(() { _apiResult = res; _apiDone = true; }); _tryNav(); }
    } catch (_) {
      if (mounted) { setState(() => _apiDone = true); _tryNav(); }
    }
  }

  void _runSteps() {
    _timer = Timer.periodic(const Duration(milliseconds: 1200), (t) {
      if (!mounted) return;
      setState(() {
        if (_active < _steps.length) { _done[_active] = true; _active++; }
        if (_active >= _steps.length) { t.cancel(); _animDone = true; _tryNav(); }
      });
    });
  }

  void _tryNav() {
    if (!_animDone || !_apiDone) return;
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      if (_apiResult != null) {
        Navigator.pushReplacement(context, PageRouteBuilder(
          pageBuilder: (_, a, __) => ResultsScreen(apiResult: _apiResult),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 350),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Could not reach server. Check your connection.'),
          backgroundColor: accent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _fadeCtrl.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: FadeTransition(
        opacity: _fadeIn,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const SizedBox(height: 20),
                RichText(text: const TextSpan(children: [
                  TextSpan(text: 'Hunar', style: TextStyle(color: accent, fontSize: 20, fontWeight: FontWeight.w900, fontFamily: 'Plus Jakarta Sans')),
                  TextSpan(text: 'Link', style: TextStyle(color: ink, fontSize: 20, fontWeight: FontWeight.w900, fontFamily: 'Plus Jakarta Sans')),
                  TextSpan(text: '  🇵🇰', style: TextStyle(fontSize: 18)),
                ])),
                const SizedBox(height: 40),

                // Pulsing icon
                Center(
                  child: AnimatedBuilder(
                    animation: _pulse,
                    builder: (_, __) => Stack(alignment: Alignment.center, children: [
                      Transform.scale(
                        scale: _pulse.value,
                        child: Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: accent.withAlpha(15)),
                        ),
                      ),
                      Container(
                        width: 64, height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle, color: surface,
                          border: Border.all(color: border, width: 1.5),
                          boxShadow: [BoxShadow(color: ink.withAlpha(10), blurRadius: 16)],
                        ),
                        child: const Icon(Icons.auto_awesome_rounded, color: accent, size: 28),
                      ),
                    ]),
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                const Center(
                  child: Text('Finding your provider...', style: TextStyle(color: ink, fontSize: 22, fontWeight: FontWeight.w800, fontFamily: 'Plus Jakarta Sans')),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    '"${widget.userInput}"',
                    textAlign: TextAlign.center,
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: inkMid, fontSize: 13, fontStyle: FontStyle.italic, fontFamily: 'Plus Jakarta Sans'),
                  ),
                ),
                const SizedBox(height: 40),

                // Steps card
                Container(
                  decoration: BoxDecoration(
                    color: surface, borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: border),
                    boxShadow: [BoxShadow(color: ink.withAlpha(8), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: List.generate(_steps.length, (i) {
                      final completed = _done[i];
                      final isActive  = i == _active;
                      return AnimatedOpacity(
                        opacity: i <= _active ? 1.0 : 0.3,
                        duration: const Duration(milliseconds: 400),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          child: Row(children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 22, height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: completed ? accent : Colors.transparent,
                                border: Border.all(
                                  color: completed ? accent : isActive ? accent : numGray,
                                  width: 1.5,
                                ),
                              ),
                              child: completed ? const Icon(Icons.check, color: Colors.white, size: 13) : null,
                            ),
                            const SizedBox(width: 14),
                            Expanded(child: Text(_steps[i], style: TextStyle(
                              color: completed ? ink : isActive ? ink : inkMid,
                              fontSize: 13.5, fontWeight: completed || isActive ? FontWeight.w600 : FontWeight.normal,
                              fontFamily: 'Plus Jakarta Sans',
                            ))),
                            if (isActive) SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 1.5, color: accent)),
                          ]),
                        ),
                      );
                    }),
                  ),
                ),

                const Spacer(),
                Center(child: Text('Powered by Gemini 2.5 Flash · Google Places',
                  style: TextStyle(color: numGray, fontSize: 11, fontFamily: 'Plus Jakarta Sans'))),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
