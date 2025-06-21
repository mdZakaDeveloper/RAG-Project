import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class FlaskPromptRepo {
  static const String flaskUrl = 'https://rag-project-1-banq.onrender.com/ask'; // Replace with your Cloudflare tunnel URL

  static Future<String> sendQueryToFlask(String query) async {
    final uri = Uri.parse(flaskUrl);

    try {
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'query': query}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] ?? '';
      } else {
        log("❌ Backend error: ${response.statusCode} - ${response.body}");
        return '';
      }
    } catch (e) {
      log("❌ Exception while calling Flask: $e");
      return '';
    }
  }
}
