import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'processing_screen.dart';
import 'my_bookings_screen.dart';

const Map<String, Map<String, String>> _lang = {
  'EN': {
    'title': 'Find Any\nHome Service.',
    'subtitle': 'Pakistan\'s first AI-powered service orchestrator.',
    'hint': 'Describe what you need... (e.g. AC technician G-13)',
    'btn': 'Find Now',
    'popular': 'SERVICES',
    'bookings': 'My Bookings',
    'bookings_sub': 'Track your active & past bookings.',
    'assistant': 'Assistant',
    'profile': 'Profile',
    'home': 'Home',
    'chat_intro': 'Salaam! I am your HunarLink AI. Describe any service you need in any language.',
    'type_here': 'Type your service request...',
    'send': 'Send',
  },
  'UR': {
    'title': 'کوئی بھی\nسروس ڈھونڈیں۔',
    'subtitle': 'پاکستان کا پہلا AI سروس پلیٹ فارم۔',
    'hint': 'اپنی ضرورت بتائیں...',
    'btn': 'ڈھونڈیں',
    'popular': 'SERVICES',
    'bookings': 'میری بکنگز',
    'bookings_sub': 'اپنی بکنگز ٹریک کریں۔',
    'assistant': 'اسسٹنٹ',
    'profile': 'پروفائل',
    'home': 'ہوم',
    'chat_intro': 'سلام! میں آپ کا HunarLink AI ہوں۔ کوئی بھی سروس بتائیں۔',
    'type_here': 'اپنی سروس لکھیں...',
    'send': 'بھیجیں',
  },
  // Roman Urdu removed from UI toggle; keep EN/UR only.
};

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  bool _isLocating = false;
  String? _lastLocation;
  int _navIndex = 0;
  String _selectedLang = 'EN';

  static const Color bg      = Color(0xFFF7F2EA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color ink     = Color(0xFF1A1415);
  static const Color inkMid  = Color(0xFF6B5E58);
  static const Color border  = Color(0xFFE4D9CF);
  static const Color accent  = Color(0xFF8C1616);
  static const Color accentBg = Color(0xFFFFEBEB);
  static const Color numGray = Color(0xFFD4C8BC);

  String t(String key) => _lang[_selectedLang]?[key] ?? _lang['EN']![key]!;
  bool get isUrdu => _selectedLang == 'UR';

  String get _localeId => _selectedLang == 'UR' ? 'ur_PK' : 'en_US';

  @override
  void initState() {
    super.initState();
    _refreshLocation();
  }

  @override
  void dispose() {
    _speech.stop();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startListening() async {
    final available = await _speech.initialize();
    if (!available) return;
    if (_isListening) return;
    setState(() => _isListening = true);
    _speech.listen(
      onResult: (result) {
        setState(() {
          _controller.text = result.recognizedWords;
        });
      },
      localeId: _localeId,
    );
  }

  void _stopListening() {
    if (!_isListening) return;
    _speech.stop();
    setState(() => _isListening = false);
  }


  Future<String?> _getUserLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      return null;
    }

    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    return '${position.latitude},${position.longitude}';
  }

  Future<void> _refreshLocation() async {
    setState(() => _isLocating = true);
    final location = await _getUserLocation();
    if (!mounted) return;
    setState(() {
      _lastLocation = location;
      _isLocating = false;
    });
  }

  Future<void> _search(String query, {bool useLocation = false}) async {
    String? location;
    if (useLocation) {
      if (_lastLocation == null && !_isLocating) {
        await _refreshLocation();
      }
      location = _lastLocation;
    }
    if (!mounted) return;
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => ProcessingScreen(userInput: query, userLocation: location),
    ));
  }

  // ─── FIXED HEADER ───────────────────────────────────────────────────
  Widget _header() {
    return Container(
      color: bg,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: const TextSpan(children: [
              TextSpan(text: 'Hunar', style: TextStyle(color: Color(0xFF8C1616), fontSize: 20, fontWeight: FontWeight.w900, fontFamily: 'Plus Jakarta Sans')),
              TextSpan(text: 'Link', style: TextStyle(color: Color(0xFF1A1415), fontSize: 20, fontWeight: FontWeight.w900, fontFamily: 'Plus Jakarta Sans')),
              TextSpan(text: '  🇵🇰', style: TextStyle(fontSize: 18)),
            ]),
          ),
          Row(
            children: ['EN', 'UR'].map((l) {
              final sel = l == _selectedLang;
              return GestureDetector(
                onTap: () => setState(() => _selectedLang = l),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(left: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: sel ? accent : surface,
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: sel ? accent : border),
                  ),
                  child: Text(
                    l == 'UR' ? 'اردو' : 'EN',
                    style: TextStyle(color: sel ? Colors.white : inkMid, fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'Plus Jakarta Sans'),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      bottomNavigationBar: _bottomNav(),
    );
  }

  Widget _buildBody() {
    switch (_navIndex) {
      case 0: return _homeTab();
      case 1: return _bookingsTab();
      case 2: return _profileTab();
      default: return _homeTab();
    }
  }

  // ─── HOME TAB ───────────────────────────────────────────────────────
  Widget _homeTab() {
    final services = [
      {
        'num': '01',
        'icon': Icons.electric_bolt_rounded,
        'title_en': 'Electrician',
        'sub_en': 'Wiring, repairs, load shedding fixes & more.',
        'title_ur': 'الیکٹریشن',
        'sub_ur': 'وائرنگ، مرمت اور بجلی کے مسائل کا حل۔',
        'query': 'I need an electrician near me in Islamabad'
      },
      {
        'num': '02',
        'icon': Icons.plumbing_rounded,
        'title_en': 'Plumber',
        'sub_en': 'Pipe leaks, drainage, bathroom fitting & more.',
        'title_ur': 'پلمبر',
        'sub_ur': 'پائپ لیک، ڈرینیج، باتھ روم فٹنگ وغیرہ۔',
        'query': 'Urgent plumber needed in Islamabad now'
      },
      {
        'num': '03',
        'icon': Icons.ac_unit_rounded,
        'title_en': 'AC Repair',
        'sub_en': 'Gas refill, deep cleaning, installation & more.',
        'title_ur': 'اے سی سروس',
        'sub_ur': 'گیس ریفل، صفائی، انسٹالیشن وغیرہ۔',
        'query': 'AC technician G-13 Islamabad'
      },
      {
        'num': '04',
        'icon': Icons.cleaning_services_rounded,
        'title_en': 'Cleaning',
        'sub_en': 'Deep house cleaning, sofas & carpet wash.',
        'title_ur': 'کلیننگ',
        'sub_ur': 'گھر کی گہری صفائی، صوفہ اور کارپٹ واش۔',
        'query': 'Deep cleaning services G-13 Islamabad'
      },
      {
        'num': '05',
        'icon': Icons.handyman_rounded,
        'title_en': 'Carpenter',
        'sub_en': 'Furniture repair, doors & custom woodwork.',
        'title_ur': 'کارپینٹر',
        'sub_ur': 'فرنیچر مرمت، دروازے اور لکڑی کا کام۔',
        'query': 'Carpenter needed in Islamabad'
      },
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Hero
            Text(
              t('title'),
              textAlign: isUrdu ? TextAlign.right : TextAlign.left,
              textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
              style: TextStyle(color: ink.withOpacity(0.75), fontSize: 32, fontWeight: FontWeight.w900, height: 1.1, letterSpacing: -0.8, fontFamily: 'Plus Jakarta Sans'),
            ),
            const SizedBox(height: 8),
            Text(t('subtitle'), style: const TextStyle(color: inkMid, fontSize: 14, fontFamily: 'Plus Jakarta Sans')),
            const SizedBox(height: 24),

            // Search card
            Container(
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border),
                boxShadow: [BoxShadow(color: ink.withAlpha(10), blurRadius: 16, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _controller,
                    textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                    style: const TextStyle(color: ink, fontSize: 15, fontFamily: 'Plus Jakarta Sans'),
                    maxLines: 2, minLines: 2,
                    decoration: InputDecoration(
                      hintText: t('hint'),
                      hintStyle: const TextStyle(color: Color(0xFFAA9E96), fontSize: 14, fontFamily: 'Plus Jakarta Sans'),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('EN / اردو', style: TextStyle(color: Color(0xFFAA9E96), fontSize: 11, fontFamily: 'Plus Jakarta Sans')),
                        Row(
                          children: [
                            GestureDetector(
                              onLongPressStart: (_) => _startListening(),
                              onLongPressEnd: (_) => _stopListening(),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                height: 42,
                                width: 42,
                                decoration: BoxDecoration(
                                  color: _isListening ? accent.withOpacity(0.12) : Colors.transparent,
                                  shape: BoxShape.circle,
                                  boxShadow: _isListening
                                      ? [
                                          BoxShadow(
                                            color: accent.withOpacity(0.35),
                                            blurRadius: 18,
                                            spreadRadius: 2,
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Icon(
                                  _isListening ? Icons.mic : Icons.mic_none,
                                  color: _isListening ? accent : accent,
                                  size: 22,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              height: 42,
                              width: 42,
                              child: ElevatedButton(
                                onPressed: () {
                                  final q = _controller.text.trim();
                                  if (q.isNotEmpty) _search(q, useLocation: true);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accent,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: EdgeInsets.zero,
                                  shape: const CircleBorder(),
                                ),
                                child: const Icon(Icons.arrow_forward_rounded, size: 18),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),

            // Section label
            Text(t('popular'),
              style: const TextStyle(color: numGray, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.5, fontFamily: 'Plus Jakarta Sans'),
            ),
            const SizedBox(height: 16),

            // Sinceerly-style numbered service cards
            ...services.map((s) => _serviceCard(s)),
          ],
        ),
      ),
    );
  }

  Widget _serviceCard(Map<String, dynamic> s) {
    return GestureDetector(
      onTap: () => _search(s['query'] as String, useLocation: true),
      child: Container(
        margin: const EdgeInsets.only(bottom: 1),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: surface,
          border: Border(
            bottom: BorderSide(color: border),
            left: BorderSide.none,
            right: BorderSide.none,
            top: BorderSide(color: border),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s['num'] as String,
                  style: const TextStyle(color: numGray, fontSize: 28, fontWeight: FontWeight.w900, fontFamily: 'Plus Jakarta Sans', height: 1),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(isUrdu ? s['title_ur'] as String : s['title_en'] as String,
                    style: const TextStyle(color: ink, fontSize: 17, fontWeight: FontWeight.w800, fontFamily: 'Plus Jakarta Sans'),
                  ),
                  const SizedBox(height: 5),
                  Text(isUrdu ? s['sub_ur'] as String : s['sub_en'] as String,
                    style: const TextStyle(color: inkMid, fontSize: 13, height: 1.4, fontFamily: 'Plus Jakarta Sans'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(s['icon'] as IconData, color: accent, size: 22),
          ],
        ),
      ),
    );
  }

  // ─── BOOKINGS TAB ───────────────────────────────────────────────────
  Widget _bookingsTab() {
    return MyBookingsScreen(isStandalone: false);
  }

  // ─── PROFILE TAB ────────────────────────────────────────────────────
  Widget _profileTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      child: Column(children: [
        Center(child: Stack(children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: accent, width: 2.5),
              image: const DecorationImage(
                image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuDssL5c18tNaw6jcEGgNBGUjKKgoyxFBrVNDhodnPyzeNJnr7BN5lWoZZ2V7pUK-l4kfxWBwkViBd2dReHOoRMoaoFZSc3MPd2TgtAI9dqck9roxmauVaz9bOcfTNQ33aJCPA7dGPW6UK4dDXXgPGpcajStUcDsYBr8s9vDSuvExIFZJvGHqBIhss3VUH_1ns00s1DDdzgZOHikbNsAA9jbt5m7JsQRz0MqsZGfJTIUNZD8WRXIUFWLZBviRCH_fvCghb8_g5roNUM'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(bottom: 0, right: 0, child: Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
            child: const Icon(Icons.check, color: Colors.white, size: 14),
          )),
        ])),
        const SizedBox(height: 14),
        const Text('Ghulam Mustafa', style: TextStyle(color: ink, fontSize: 22, fontWeight: FontWeight.w800, fontFamily: 'Plus Jakarta Sans')),
        const Text('HunarLink MVP Guest', style: TextStyle(color: inkMid, fontSize: 13, fontFamily: 'Plus Jakarta Sans')),
        const SizedBox(height: 28),
        Container(
          decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: border)),
          child: Column(children: [
            _profileRow('Phone', '+92 300 1234567'),
            const Divider(height: 1, color: Color(0xFFF0E8E0)),
            _profileRow('Location', 'G-13, Islamabad'),
            const Divider(height: 1, color: Color(0xFFF0E8E0)),
            _profileRow('Status', '✓  Verified Client'),
          ]),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: accent),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text('Account Settings', style: TextStyle(color: accent, fontWeight: FontWeight.w700, fontFamily: 'Plus Jakarta Sans')),
        ),
      ]),
    );
  }

  Widget _profileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(color: inkMid, fontSize: 13, fontFamily: 'Plus Jakarta Sans')),
        Text(value, style: const TextStyle(color: ink, fontWeight: FontWeight.w700, fontSize: 14, fontFamily: 'Plus Jakarta Sans')),
      ]),
    );
  }

  // ─── BOTTOM NAV ─────────────────────────────────────────────────────
  Widget _bottomNav() {
    final items = [
      (Icons.home_rounded, Icons.home_outlined, t('home')),
      (Icons.receipt_long_rounded, Icons.receipt_long_outlined, t('bookings')),
      (Icons.person_rounded, Icons.person_outline_rounded, t('profile')),
    ];
    return Container(
      decoration: const BoxDecoration(
        color: surface,
        border: Border(top: BorderSide(color: border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final sel = _navIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _navIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: sel ? 14 : 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? accentBg : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(sel ? items[i].$1 : items[i].$2, color: sel ? accent : inkMid, size: 22),
                    if (sel) ...[
                      const SizedBox(width: 6),
                      Text(items[i].$3, style: const TextStyle(color: accent, fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'Plus Jakarta Sans')),
                    ],
                  ]),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
