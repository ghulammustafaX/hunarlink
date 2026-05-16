import 'package:flutter/material.dart';
import 'results_screen.dart';

class ProcessingScreen extends StatefulWidget {
  final String userInput;
  const ProcessingScreen({super.key, required this.userInput});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  final List<String> _steps = [
    'Understanding your request...',
    'Detecting language: Roman Urdu ✓',
    'Parsed: AC Technician · G-13 · Tomorrow Morning ✓',
    'Searching nearby providers via Maps...',
    'Found 3 providers. Ranking by distance + rating...',
    'Best match selected. Preparing booking...',
  ];

  final List<bool> _done = List.filled(6, false);
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _runSteps();
  }

  Future<void> _runSteps() async {
    for (int i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      setState(() { _done[i] = true; _current = i + 1; });
    }
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ResultsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1B4B),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text('HunarLink is thinking...', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              Text('"${widget.userInput}"', style: const TextStyle(fontSize: 13, color: Color(0xFFBFDBFE), fontStyle: FontStyle.italic)),
              const SizedBox(height: 40),
              ..._steps.asMap().entries.map((e) => _buildStep(e.key, e.value)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(int index, String text) {
    final isDone = _done[index];
    final isActive = _current == index;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: isDone ? const Color(0xFF059669) : (isActive ? const Color(0xFF2563EB) : const Color(0xFF374151)),
              shape: BoxShape.circle,
            ),
            child: Center(child: isDone
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : isActive
                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text('${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 12))),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(text, style: TextStyle(color: isDone ? Colors.white : const Color(0xFF6B7280), fontSize: 14))),
        ],
      ),
    );
  }
}
