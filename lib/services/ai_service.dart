import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class AIService {
  static const String _apiKey = "AIzaSyBtxZ4cLTTE1WR0xXTIKS9NCZWpEvLnSIE"; // 🔑 Sirf yahan change karo
  static const String _baseUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-001:generateContent";
  // Cache — same prompt dobara API call nahi karega
  static final Map<String, String> _cache = {};

  // Rate Limiter: 15 requests per minute
  static final List<DateTime> _requestTimes = [];
  static const int _maxRequestsPerMinute = 12; // 15 se kam rakha safety ke liye

  static bool _checkRateLimit() {
    final now = DateTime.now();
    _requestTimes.removeWhere((time) => now.difference(time).inMinutes >= 1);
    if (_requestTimes.length >= _maxRequestsPerMinute) {
      return false;
    }
    _requestTimes.add(now);
    return true;
  }

  static Future<String> sendMessage(String prompt, {BuildContext? context}) async {
    // Cache check
    if (_cache.containsKey(prompt)) {
      debugPrint("Cache se mila response ✅");
      return _cache[prompt]!;
    }

    // Rate limit check
    if (!_checkRateLimit()) {
      const msg = "AI busy hai, thoda wait karo (15/min limit).";
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(msg),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return "RATE_LIMIT_REACHED";
    }

    int retryCount = 0;
    const int maxRetries = 3; // 5 se kam kiya — zyada wait nahi hoga

    while (retryCount <= maxRetries) {
      try {
        final response = await http.post(
          Uri.parse("$_baseUrl?key=$_apiKey"),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "contents": [
              {
                "parts": [
                  {"text": prompt}
                ]
              }
            ]
          }),
        ).timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['candidates'] != null && data['candidates'].isNotEmpty) {
            final result = data['candidates'][0]['content']['parts'][0]['text'];
            _cache[prompt] = result; // Cache mein save karo
            return result;
          }
          return "AI response nahi de saka.";

        } else if (response.statusCode == 429) {
          if (retryCount == maxRetries) {
            if (context != null && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("AI abhi bahut busy hai. Baad mein try karo."),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 4),
                ),
              );
            }
            return "AI is extremely busy. Please try again later.";
          }
          int waitTime = 1 << (retryCount + 1); // 2, 4, 8 seconds
          debugPrint("Rate limited (429). Retrying in $waitTime seconds...");
          await Future.delayed(Duration(seconds: waitTime));
          retryCount++;

        } else {
          return "Error: ${response.statusCode}";
        }
      } on TimeoutException {
        return "Connection timeout. Check your internet.";
      } catch (e) {
        return "Connection error: $e";
      }
    }
    return "Failed after multiple retries.";
  }

  static Future<Map<String, dynamic>?> suggestTaskDetails(
      String taskTitle, {BuildContext? context}) async {
    final prompt = """
Task: "$taskTitle"
Current Time: ${DateTime.now()}

Return ONLY a raw JSON object with:
"priority": (low/medium/high),
"due_date": (extracted date in yyyy-mm-dd, or "Today"/"Tomorrow"),
"reminder": (logical reminder in yyyy-mm-dd hh:mm:ss, or null),
"suggestion": (short professional tip for this task).

Do NOT include markdown like \`\`\`json. Return ONLY the object.
""";

    try {
      final response = await sendMessage(prompt, context: context);
      if (response == "RATE_LIMIT_REACHED") return null;

      final cleaned = response
          .replaceAll("```json", "")
          .replaceAll("```", "")
          .trim();

      final Map<String, dynamic> result = jsonDecode(cleaned);
      return result;
    } catch (e) {
      debugPrint("suggestTaskDetails error: $e");
      return null;
    }
  }
}