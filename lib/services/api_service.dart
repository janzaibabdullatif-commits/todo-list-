import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/task.dart';

class ApiService {
  static const String baseUrl = "https://trendosky.com/runit/";

  static Future<List<Task>> fetchTodayTasks(String userId) async {
    try {
      final response = await http.get(
        Uri.parse("${baseUrl}today_tasks.php?user_id=$userId"),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((json) => Task.fromJson(json)).toList();
      } else {
        throw Exception("Server error");
      }
    } catch (e) {
      rethrow;
    }
  }

  // ✅ Optimized for Web and Mobile (No dart:io File used here)
  static Future<bool> addTask(
    String userId,
    String title, {
    String priority = 'low',
    String? reminderDateTime,
    String? dueDate,
    Uint8List? attachmentBytes,
    String? attachmentName,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("${baseUrl}add_task.php"),
      );

      request.fields['user_id'] = userId;
      request.fields['title'] = title;
      request.fields['priority'] = priority;
      request.fields['due_date'] = dueDate ?? "";
      request.fields['reminder'] = reminderDateTime ?? "";

      if (attachmentBytes != null && attachmentName != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'attachment',
            attachmentBytes,
            filename: attachmentName,
          ),
        );
      }

      var streamedResponse = await request.send().timeout(const Duration(seconds: 15));
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final resData = jsonDecode(response.body);
        return resData['status'] == 'success';
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateTask(String id, Map<String, String> data) async {
    try {
      final response = await http.post(
        Uri.parse("${baseUrl}update_task.php"),
        body: {"id": id, ...data},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final resData = jsonDecode(response.body);
        return resData['status'] == 'success' || resData['status'] == '1';
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
