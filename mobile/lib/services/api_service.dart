import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// ApiService handles all backend and LLM agent interactions for HunarLink.
class ApiService {
  // Production server URL on Railway
  static const String baseUrl = 'https://hunarlink-production.up.railway.app/';

  // Replace with the developer's actual IPv4 address when testing on physical devices (same Wi-Fi)
  // Run 'ipconfig' (Windows) or 'ifconfig' (macOS/Linux) to find it.
  static const String developerIp = '192.168.18.45';

  // Adaptive development base endpoints supporting physical devices, host machine, and emulator loopbacks.
  static const List<String> endpoints = [
    '${baseUrl}request',
    'http://192.168.18.45:3000/request', // Physical device test IP (Change to your PC's IP)
    'http://10.0.2.2:3000/request',      // Android emulator default
    'http://localhost:3000/request',     // iOS simulator, web & desktop default
  ];

  /// Shows a user-friendly SnackBar error message.
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF8C1616),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Sends the user's natural language service request to the agent
  /// and returns the structured list of parsed fields and matched providers.
  /// Timeout: 30 seconds as per §8.3 spec requirement.
  static Future<Map<String, dynamic>?> processRequest(
    String userInput, {
    BuildContext? context,
    String? location,
  }) async {
    for (final url in endpoints) {
      try {
        final payload = {
          'input': userInput,
          'userId': 'user_mustafa_001',
          if (location != null && location.isNotEmpty) 'location': location,
        };
        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        ).timeout(const Duration(seconds: 30)); // §8.3 — 30 second timeout

        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic> && decoded['success'] == true) {
            return decoded;
          }
        }
      } catch (e) {
        // Fallback silently to the next endpoint to ensure offline resiliency
      }
    }

    // All endpoints failed — show SnackBar if context is available
    if (context != null && context.mounted) {
      showError(context, 'Server unreachable. Please check your Wi-Fi or ensure the agent server is running.');
    }
    return null; // Return null to trigger self-healing mock fallback in UI
  }

  /// Checks if the backend server is reachable and healthy.
  /// Calls GET /health as per §8.3 spec requirement.
  static Future<bool> checkHealth() async {
    for (final url in endpoints) {
      try {
        final healthUrl = url.replaceAll('/request', '/health');
        final response = await http.get(
          Uri.parse(healthUrl),
        ).timeout(const Duration(seconds: 5));
        if (response.statusCode == 200) {
          return true;
        }
      } catch (e) {
        // Fallback silently
      }
    }
    return false;
  }
}

