import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LogDetailScreen extends StatelessWidget {
  final Map<String, dynamic> log;

  const LogDetailScreen({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    final steps = log['pipeline_steps'] as List<dynamic>? ?? [];
    final metrics = log['accuracy_metrics'] as Map<String, dynamic>? ?? {};
    final result = log['final_result'] as Map<String, dynamic>? ?? {};

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E1A),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          log['log_id'] ?? 'Log Detail',
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy, color: Colors.white),
            onPressed: () {
              Clipboard.setData(ClipboardData(
                text: const JsonEncoder.withIndent('  ').convert(log),
              ));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Full log copied to clipboard')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('User Input'),
            _glassCard(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '"${log['input'] ?? ''}"',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                _row('Language', log['language_detected'] ?? 'auto'),
                _row('Timestamp', log['timestamp'] ?? ''),
                _row('Duration', '${log['pipeline_duration_ms'] ?? 0}ms'),
              ],
            )),
            const SizedBox(height: 16),
            _sectionTitle('Accuracy Metrics'),
            _glassCard(Column(children: [
              _row('Match Score', '${((metrics['top_score'] as num? ?? 0) * 100).toStringAsFixed(0)}%'),
              _row('Providers Found', '${metrics['total_providers_found'] ?? 0}'),
              _row('Formula', metrics['ranking_formula'] ?? ''),
              _row('Model Used', metrics['model_used'] ?? ''),
              _row('Radius Expanded', metrics['radius_expanded'] == true ? 'Yes' : 'No'),
              _row('Mock Mode', metrics['mock_mode'] == true ? 'Yes (Dev)' : 'No (Live)'),
            ])),
            const SizedBox(height: 16),
            _sectionTitle('Pipeline Steps (${steps.length}/5)'),
            ...steps.asMap().entries.map((e) => _buildStepCard(e.key, e.value)),
            const SizedBox(height: 16),
            _sectionTitle('Final Result'),
            _glassCard(Column(children: [
              _row('Service', result['service_category'] ?? ''),
              _row('Location', result['location'] ?? ''),
              _row('Time', result['time_preference'] ?? ''),
              _row('Provider', result['selected_provider'] ?? ''),
              _row('Distance', result['provider_distance'] ?? ''),
              _row('Rating', '${result['provider_rating'] ?? ''}'),
              _row('Score', '${result['provider_score'] ?? ''}'),
              _row('Booking ID', result['booking_id'] ?? ''),
              _row('Status', result['status'] ?? ''),
            ])),
            const SizedBox(height: 16),
            _sectionTitle('Raw Agent Trace (JSON)'),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1117),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF30363D)),
              ),
              child: SelectableText(
                const JsonEncoder.withIndent('  ').convert(log),
                style: const TextStyle(
                  color: Color(0xFF39D353),
                  fontFamily: 'monospace',
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard(int index, dynamic step) {
    final s = step as Map<String, dynamic>? ?? {};
    final status = s['status'] ?? 'success';
    final isSuccess = status == 'success';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isSuccess
            ? const Color(0xFF059669).withOpacity(0.05)
            : const Color(0xFFDC2626).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSuccess
              ? const Color(0xFF059669).withOpacity(0.3)
              : const Color(0xFFDC2626).withOpacity(0.3),
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.error,
            color: isSuccess ? const Color(0xFF059669) : const Color(0xFFDC2626),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Step ${s['step'] ?? index + 1} - ${s['tool'] ?? 'Unknown'}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${s['duration_ms'] ?? 0}ms',
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
          ),
        ]),
        const SizedBox(height: 8),
        Text(
          s['reasoning'] ?? '',
          style: const TextStyle(color: Color(0xFFBFDBFE), fontSize: 13),
        ),
      ]),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _glassCard(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x0DFFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: child,
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ]),
    );
  }
}
