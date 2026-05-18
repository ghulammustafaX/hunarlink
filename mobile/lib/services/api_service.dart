import 'dart:convert';
import 'package:http/http.dart' as http;

/// ApiService handles all backend and LLM agent interactions for HunarLink.
class ApiService {
  // Adaptive development base endpoints supporting both host machine and emulator loopbacks.
  static const List<String> endpoints = [
    'http://10.0.2.2:3000/request', // Android emulator default
    'http://localhost:3000/request', // iOS simulator, web & desktop default
  ];

  /// Sends the user's natural language service request to the agent
  /// and returns the structured list of parsed fields and matched providers.
  static Future<Map<String, dynamic>?> processRequest(String userInput) async {
    for (final url in endpoints) {
      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'input': userInput,
            'userId': 'user_mustafa_001',
          }),
        ).timeout(const Duration(seconds: 4));
        
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
    return null; // Gracefully return null to trigger self-healing mock fallback
  }
}
