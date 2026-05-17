import 'dart:convert';
import 'package:http/http.dart' as http;

/// ApiService handles all backend and LLM agent interactions for HunarLink.
class ApiService {
  // Replace this with your actual Antigravity or backend agent endpoint URL
  static const String baseUrl = 'YOUR_ANTIGRAVITY_ENDPOINT_HERE';

  /// Sends the user's natural language service request to the agent
  /// and returns the structured list of parsed fields and matched providers.
  static Future<Map<String, dynamic>?> processRequest(String userInput) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'input': userInput}),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        print('API Service Error: Received status code ${response.statusCode}');
      }
    } catch (e) {
      print('API Service Exception: $e');
    }
    return null;
  }
}
