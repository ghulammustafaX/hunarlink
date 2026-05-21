import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'log_detail_screen.dart';

class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E1A),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Agent Logs',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Text(
              'Live execution history',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('agent_logs')
            .where('user_id', isEqualTo: 'user_mustafa_001')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2563EB)),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          final logs = (snapshot.data!.docs.toList()
            ..sort((a, b) {
              final aLog = a.data() as Map<String, dynamic>;
              final bLog = b.data() as Map<String, dynamic>;
              return (bLog['timestamp'] ?? '').toString().compareTo((aLog['timestamp'] ?? '').toString());
            })).take(20).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index].data() as Map<String, dynamic>;
              return _buildLogCard(context, log);
            },
          );
        },
      ),
    );
  }

  Widget _buildLogCard(BuildContext context, Map<String, dynamic> log) {
    final result = log['final_result'] as Map<String, dynamic>? ?? {};
    final metrics = log['accuracy_metrics'] as Map<String, dynamic>? ?? {};
    final steps = log['pipeline_steps'] as List<dynamic>? ?? [];
    final duration = log['pipeline_duration_ms'] ?? 0;
    final score = metrics['top_score'] as num? ?? 0;
    final scorePercent = '${(score * 100).toStringAsFixed(0)}%';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => LogDetailScreen(log: log)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0x0DFFFFFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF059669).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF059669)),
                ),
                child: Text(
                  result['status'] ?? 'confirmed',
                  style: const TextStyle(
                    color: Color(0xFF059669),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${duration}ms',
                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
              ),
            ]),
            const SizedBox(height: 10),
            Text(
              '"${log['input'] ?? ''}"',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chip('Service: ${result['service_category'] ?? 'N/A'}', const Color(0xFF2563EB)),
                _chip('Location: ${result['location'] ?? 'N/A'}', const Color(0xFF7C3AED)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '-> ${result['selected_provider'] ?? 'N/A'}',
              style: const TextStyle(color: Color(0xFFBFDBFE), fontSize: 13),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _metric('Match', scorePercent),
                _metric('Rating', '${result['provider_rating'] ?? 'N/A'}'),
                _metric('Distance', '${result['provider_distance'] ?? 'N/A'}'),
                _metric('Steps', '${steps.length}/5'),
              ],
            ),
            const SizedBox(height: 8),
            Row(children: [
              Text(
                _formatTime(log['timestamp'] ?? ''),
                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11),
              ),
              const Spacer(),
              const Text(
                'Tap for full trace ->',
                style: TextStyle(color: Color(0xFF2563EB), fontSize: 11),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 11)),
    );
  }

  Widget _metric(String label, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 10)),
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    ]);
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('No logs yet', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('Make a booking to see agent execution logs', style: TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
      ]),
    );
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }
}
