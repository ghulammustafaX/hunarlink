import 'dart:async';
import 'dart:convert';
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

  // ── Design tokens ──────────────────────────────────────────────────
  static const Color bg       = Color(0xFFF7F2EA);
  static const Color surface  = Color(0xFFFFFFFF);
  static const Color ink      = Color(0xFF1A1415);
  static const Color inkMid   = Color(0xFF6B5E58);
  static const Color border   = Color(0xFFE4D9CF);
  static const Color accent   = Color(0xFF8C1616);
  static const Color numGray  = Color(0xFFD4C8BC);
  static const Color consoleBg = Color(0xFF0A0E1A);
  static const Color neonGreen = Color(0xFF00FF87);
  static const Color warnYellow = Color(0xFFFFF3CD);
  static const Color warnBorder = Color(0xFFFFD600);

  // ── Step definitions ───────────────────────────────────────────────
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

  // ── API state ──────────────────────────────────────────────────────
  bool _apiDone    = false;
  bool _animDone   = false;
  Map<String, dynamic>? _apiResult;

  // ── New: trace + radius expansion state ───────────────────────────
  List<dynamic> _traces       = [];
  bool   _radiusExpanded      = false;
  bool   _readyToProceed      = false;
  String _agentTraceJson      = '';

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
      if (mounted) {
        setState(() {
          _apiResult = res;
          _apiDone   = true;
          // Extract traces and radiusExpanded from response
          if (res != null) {
            _traces         = res['traces'] as List<dynamic>? ?? [];
            _radiusExpanded = res['radiusExpanded'] == true;
            _agentTraceJson = const JsonEncoder.withIndent('  ').convert(_traces);
          }
        });
        _tryFinish();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _apiDone = true);
        _tryFinish();
      }
    }
  }

  void _runSteps() {
    _timer = Timer.periodic(const Duration(milliseconds: 1200), (t) {
      if (!mounted) return;
      setState(() {
        if (_active < _steps.length) { _done[_active] = true; _active++; }
        if (_active >= _steps.length) { t.cancel(); _animDone = true; _tryFinish(); }
      });
    });
  }

  void _tryFinish() {
    if (!_animDone || !_apiDone) return;
    // Auto-navigate to ResultsScreen once both API and animation are done
    if (!mounted) return;
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      Navigator.pushReplacement(context, PageRouteBuilder(
        pageBuilder: (_, a, __) => ResultsScreen(apiResult: _apiResult),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ));
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _fadeCtrl.dispose();
    _timer?.cancel();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: FadeTransition(
        opacity: _fadeIn,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ─────────────────────────────────────────
                const SizedBox(height: 20),
                RichText(text: const TextSpan(children: [
                  TextSpan(text: 'Hunar', style: TextStyle(color: accent, fontSize: 20, fontWeight: FontWeight.w900, fontFamily: 'Plus Jakarta Sans')),
                  TextSpan(text: 'Link', style: TextStyle(color: ink, fontSize: 20, fontWeight: FontWeight.w900, fontFamily: 'Plus Jakarta Sans')),
                  TextSpan(text: '  🇵🇰', style: TextStyle(fontSize: 18)),
                ])),
                const SizedBox(height: 40),

                // ── Pulsing logo ───────────────────────────────────
                Center(
                  child: AnimatedBuilder(
                    animation: _pulse,
                    builder: (_, __) => Stack(alignment: Alignment.center, children: [
                      // Outer pulse ring
                      Transform.scale(
                        scale: _pulse.value,
                        child: Container(
                          width: 96, height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accent.withAlpha(12),
                          ),
                        ),
                      ),
                      // Logo container with round white bg
                      Container(
                        width: 72, height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: border, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: accent.withAlpha(30),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
                const SizedBox(height: 32),

                // ── Title ──────────────────────────────────────────
                Center(
                  child: Text(
                    'Finding your provider...',
                    style: const TextStyle(color: ink, fontSize: 22, fontWeight: FontWeight.w800, fontFamily: 'Plus Jakarta Sans'),
                  ),
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
                const SizedBox(height: 28),

                // ── Radius Expansion Banner ────────────────────────
                if (_radiusExpanded)
                  _buildRadiusBanner(),

                // ── Steps card ─────────────────────────────────────
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
                            if (isActive && !_readyToProceed)
                              SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 1.5, color: accent)),
                          ]),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Agent Trace ExpansionTile ───────────────────────
                if (_traces.isNotEmpty)
                  _buildAgentTraceTile(),

                // ── Footer ─────────────────────────────────────────
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'Powered by Gemini 2.5 Flash · Google Places',
                    style: TextStyle(color: numGray, fontSize: 11, fontFamily: 'Plus Jakarta Sans'),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Radius Expansion Banner ────────────────────────────────────────
  Widget _buildRadiusBanner() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: warnYellow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: warnBorder.withOpacity(0.6), width: 1.2),
        ),
        child: Row(
          children: [
            const Text('🔍', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'No providers found nearby.\nExpanding search radius to 10km...',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF5C4200),
                  fontFamily: 'Plus Jakarta Sans',
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Agent Trace Panel ──────────────────────────────────────────────
  Widget _buildAgentTraceTile() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            backgroundColor: consoleBg,
            collapsedBackgroundColor: consoleBg,
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Row(
              children: const [
                Text('🤖', style: TextStyle(fontSize: 16)),
                SizedBox(width: 8),
                Text(
                  'Agent Trace',
                  style: TextStyle(
                    color: Color(0xFF60A5FA),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
              ],
            ),
            trailing: const Icon(Icons.expand_more_rounded, color: Color(0xFF60A5FA)),
            children: [
              Container(
                width: double.infinity,
                color: consoleBg,
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
                child: SelectableText(
                  _agentTraceJson,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    color: neonGreen,
                    fontSize: 10.5,
                    height: 1.6,
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
