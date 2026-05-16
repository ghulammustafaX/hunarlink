// Reusable agent step tile
// Used in ProcessingScreen
import 'package:flutter/material.dart';

class AgentStepTile extends StatelessWidget {
  final int index;
  final String text;
  final bool isDone;
  final bool isActive;
  const AgentStepTile({super.key, required this.index, required this.text, required this.isDone, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: isDone ? const Color(0xFF059669) : isActive ? const Color(0xFF2563EB) : const Color(0xFF374151),
            shape: BoxShape.circle,
          ),
          child: Center(child: isDone
            ? const Icon(Icons.check, color: Colors.white, size: 16)
            : isActive ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text('${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 12))),
        ),
        const SizedBox(width: 14),
        Expanded(child: Text(text, style: TextStyle(color: isDone ? Colors.white : const Color(0xFF6B7280), fontSize: 14))),
      ]),
    );
  }
}
