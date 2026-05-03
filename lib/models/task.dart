import 'package:intl/intl.dart';

class Task {
  String id;
  String title;
  String? date;
  String priority;
  bool isDone;
  String? completedAt;
  String? createdAt;
  String? reminderTime;
  List<String>? attachments;
  String userId;

  Task({
    required this.id,
    required this.title,
    required this.userId,
    this.date,
    this.priority = "low",
    this.isDone = false,
    this.completedAt,
    this.createdAt,
    this.reminderTime,
    this.attachments,
  });

  String _safe(String? val) {
    if (val == null) return "";
    final v = val.toString().trim();
    if (v.isEmpty || v == "null" || v == "NaN" || v.contains("NaN")) return "";
    return v;
  }

  bool isForToday() {
    if (isDone) return false;
    final now = DateTime.now();

    bool isSameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;

    String dStr = _safe(date);
    String cStr = _safe(createdAt);

    if (dStr.toLowerCase() == "today") return true;
    try {
      DateTime? d = DateTime.tryParse(dStr);
      if (d != null && isSameDay(d, now)) return true;
    } catch (_) {}

    final f1 = DateFormat('d/M/yyyy').format(now);
    final f2 = DateFormat('dd/MM/yyyy').format(now);
    if (dStr == f1 || dStr == f2) return true;

    if (dStr.isEmpty) {
      try {
        DateTime? c = DateTime.tryParse(cStr);
        if (c != null && isSameDay(c, now)) return true;
      } catch (_) {}
      if (cStr.contains(DateFormat('yyyy-MM-dd').format(now))) return true;
    }

    return false;
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    String? rawDate = (json['due_date'] ?? json['date'])?.toString();

    List<String> parsedAttachments = [];
    var attData = json['attachments'] ?? json['attachment'];
    if (attData != null) {
      if (attData is String && attData.isNotEmpty && attData != "null") {
        parsedAttachments = attData.split(',');
      } else if (attData is List) {
        parsedAttachments = List<String>.from(attData);
      }
    }

    return Task(
      id: json['id'].toString(),
      title: json['title'] ?? "",
      userId: (json['user_id'] ?? "").toString(),
      date: (rawDate != null && rawDate != "null" && !rawDate.contains("NaN"))
          ? rawDate
          : null,
      priority: json['priority'] ?? "low",
      isDone: json['is_done'].toString() == "1",
      completedAt: json['completed_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      reminderTime: json['reminder_time']?.toString(),
      attachments: parsedAttachments,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "user_id": userId,
      "due_date": date ?? "",
      "priority": priority,
      "is_done": isDone ? "1" : "0",
      "completed_at": completedAt ?? "",
      "created_at": createdAt ?? "",
      "reminder_time": reminderTime ?? "",
      "attachments": attachments?.join(',') ?? "",
    };
  }
}