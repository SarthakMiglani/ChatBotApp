import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String apiKey = 'REMOVED_API_KEY';
  static const String apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  Future<String> sendMessage(String message) async {
    try {
      final url = '$apiUrl?key=$apiKey';
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': message}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['candidates'] != null && 
            data['candidates'].isNotEmpty &&
            data['candidates'][0]['content'] != null &&
            data['candidates'][0]['content']['parts'] != null &&
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          return data['candidates'][0]['content']['parts'][0]['text'];
        } else {
          return 'Error: Invalid response format from AI';
        }
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        return 'Error: ${errorData['error']['message'] ?? 'Bad request'}';
      } else if (response.statusCode == 429) {
        return 'Error: Rate limit exceeded. Please try again later';
      } else if (response.statusCode == 404) {
        return 'Error: Model not found. Check API endpoint';
      } else {
        return 'Error: Server returned ${response.statusCode}';
      }
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }
}