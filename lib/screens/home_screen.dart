import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:ui';
import 'dart:typed_data';

import '../models/task.dart';
import '../main.dart';
import '../services/notification_service.dart';
import '../services/api_service.dart';
import '../widgets/ai_chat_sheet.dart';
import 'inbox_screen.dart';
import 'today_screen.dart';
import 'upcoming_screen.dart';
import 'browse_screen.dart';
import 'add_task_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userId;
  const HomeScreen({super.key, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;
  List<Task> tasks = [];
  bool isLoading = false;

  final String baseUrl = "https://trendosky.com/runit/";

  @override
  void initState() {
    super.initState();
    _loadLocalTasks();
    loadTasks();
  }

  Future<void> _loadLocalTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? localData = prefs.getString("tasks_${widget.userId}");
    if (localData != null) {
      setState(() {
        Iterable l = jsonDecode(localData);
        tasks = List<Task>.from(l.map((e) => Task.fromJson(e)));
      });
    }
  }

  Future<void> _saveTasksLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString("tasks_${widget.userId}", encoded);
  }

  Future<void> loadTasks() async {
    setState(() => isLoading = true);
    try {
      final res = await http.get(Uri.parse("${baseUrl}get_tasks.php?user_id=${widget.userId}"));
      if (res.statusCode == 200) {
        List data = jsonDecode(res.body);
        setState(() {
          tasks = data.map((e) => Task.fromJson(e)).toList();
          isLoading = false;
        });
        await _saveTasksLocally();
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void toggleDone(Task task) async {
    setState(() {
      task.isDone = !task.isDone;
      if (task.isDone) {
        task.completedAt = DateFormat('EEEE, d MMMM yyyy | hh:mm a').format(DateTime.now());
      }
      tasks = List.from(tasks);
    });

    if (task.isDone) {
      NotificationService().showTaskCompletedNotification(task.title);
      _showTopNotification("Task Completed", "Well done! '${task.title}' is finished.");
    }

    await ApiService.updateTask(task.id, {"is_done": task.isDone ? "1" : "0"});
    _saveTasksLocally();
  }

  void _showTopNotification(String title, String body) {
    final bool isDark = MyApp.of(context)!.isDarkMode;
    OverlayState? overlayState = Overlay.of(context);
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 10, right: 10,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder(
            duration: const Duration(milliseconds: 500),
            tween: Tween<Offset>(begin: const Offset(0, -1.5), end: const Offset(0, 0)),
            curve: Curves.elasticOut,
            builder: (context, Offset offset, child) => Transform.translate(offset: offset * 100, child: child),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.blue.shade700,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black.withAlpha(80), blurRadius: 10, spreadRadius: 2)],
                border: Border.all(color: isDark ? Colors.yellow.shade800 : Colors.white, width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                        Text(body, style: const TextStyle(fontSize: 12, color: Colors.white70), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    overlayState.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), () { if (overlayEntry.mounted) overlayEntry.remove(); });
  }

  void deleteTask(String id) async {
    setState(() {
      tasks.removeWhere((t) => t.id == id);
      tasks = List.from(tasks);
    });
    await http.post(Uri.parse("${baseUrl}delete_task.php"), body: {"id": id});
    _saveTasksLocally();
  }

  void _openAddTaskSheet() {
    final bool isDark = MyApp.of(context)!.isDarkMode;
    final Color accentColor = isDark ? Colors.yellow.shade700 : Colors.blue.shade700;
    final TextEditingController controller = TextEditingController();
    String priority = "low";
    String selectedDateLabel = "Today"; 
    DateTime selectedDate = DateTime.now();
    DateTime? reminderTime;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, left: 20, right: 20, top: 20),
              decoration: BoxDecoration(
                color: isDark ? Colors.black.withOpacity(0.85) : Colors.white.withOpacity(0.85),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
                border: Border.all(color: accentColor.withOpacity(0.2)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 20),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18),
                    decoration: InputDecoration(hintText: "What's on your mind?", hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38), border: InputBorder.none),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _sheetAction(Icons.flag_rounded, priority.toUpperCase(), () {
                        setSheetState(() {
                          if (priority == "low") priority = "medium";
                          else if (priority == "medium") priority = "high";
                          else priority = "low";
                        });
                      }, isDark, accentColor),
                      _sheetAction(Icons.calendar_today_rounded, selectedDateLabel, () {
                        setSheetState(() {
                           if (selectedDateLabel == "Today") {
                             selectedDateLabel = "Tomorrow";
                             selectedDate = DateTime.now().add(const Duration(days: 1));
                           } else {
                             selectedDateLabel = "Today";
                             selectedDate = DateTime.now();
                           }
                        });
                      }, isDark, accentColor),
                      _sheetAction(Icons.notifications_active_outlined, reminderTime == null ? "Remind" : DateFormat('hh:mm a').format(reminderTime!), () async {
                        DateTime? d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2100));
                        if (d != null) {
                          TimeOfDay? t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                          if (t != null) setSheetState(() => reminderTime = DateTime(d.year, d.month, d.day, t.hour, t.minute));
                        }
                      }, isDark, accentColor),
                    ],
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: accentColor, minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                    onPressed: () async {
                      if (controller.text.isEmpty) return;
                      final title = controller.text;
                      Navigator.pop(context);
                      setState(() => isLoading = true);
                      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
                      final success = await ApiService.addTask(widget.userId, title, priority: priority, dueDate: dateStr, reminderDateTime: reminderTime?.toIso8601String());
                      if (success) loadTasks();
                    },
                    child: Text("SAVE TASK", style: TextStyle(color: isDark ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  void _openAIChat() {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => const AIChatSheet());
  }

  Widget _sheetAction(IconData icon, String label, VoidCallback onTap, bool isDark, Color accent) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(color: (isDark ? Colors.white : Colors.black).withOpacity(0.08), borderRadius: BorderRadius.circular(15), border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.1))),
        child: Row(children: [Icon(icon, size: 18, color: accent), const SizedBox(width: 8), Text(label, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 12, fontWeight: FontWeight.w600))]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = MyApp.of(context)!.isDarkMode;
    final Color accentColor = isDark ? Colors.yellow.shade700 : Colors.blue.shade700;
    final Color barColor = isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05);
    final Color idleColor = isDark ? Colors.white30 : Colors.black38;

    final screens = [
      InboxScreen(
        tasks: tasks,
        onToggle: toggleDone,
        onDelete: deleteTask,
        onUpdatePriority: (task, p) async {
           setState(() { task.priority = p; tasks = List.from(tasks); }); 
           await ApiService.updateTask(task.id, {"priority": p});
        }, 
        onUpdateDate: (task, d) async {
          setState(() { task.date = d; tasks = List.from(tasks); }); 
          await ApiService.updateTask(task.id, {"due_date": d});
        },
        onUpdateReminder: (task, r) async {
          setState(() { task.reminderTime = r; tasks = List.from(tasks); }); 
          await ApiService.updateTask(task.id, {"reminder": r});
        },
        onPickAttachments: (_) {},
      ),
      TodayScreen(
        userId: widget.userId,
        tasks: tasks,
        onToggle: toggleDone,
        onDelete: deleteTask,
        onUpdatePriority: (task, p) async {
           setState(() { task.priority = p; tasks = List.from(tasks); }); 
           await ApiService.updateTask(task.id, {"priority": p});
        },
        onUpdateDate: (task, d) async {
          setState(() { task.date = d; tasks = List.from(tasks); }); 
          await ApiService.updateTask(task.id, {"due_date": d});
        },
        onUpdateReminder: (task, r) async {
          setState(() { task.reminderTime = r; tasks = List.from(tasks); });
          await ApiService.updateTask(task.id, {"reminder": r});
        },
        onPickAttachments: (_) {},
      ),
      UpcomingScreen(tasks: tasks),
      BrowseScreen(userId: widget.userId, tasks: tasks, onDelete: deleteTask, toggleTheme: () { MyApp.of(context)!.toggleTheme(); setState(() {}); }, isDark: isDark),
    ];

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: Stack(
        children: [
          IndexedStack(index: index, children: screens),
          Positioned(
            left: 50, right: 50, bottom: 25,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(color: barColor, border: Border.all(color: accentColor.withOpacity(0.15)), borderRadius: BorderRadius.circular(30)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _navItem(Icons.inbox_outlined, "Inbox", 0, accentColor, idleColor),
                      _navItem(Icons.today_outlined, "Today", 1, accentColor, idleColor),
                      GestureDetector(onTap: _openAIChat, child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: accentColor.withOpacity(0.1), shape: BoxShape.circle), child: Icon(Icons.auto_awesome_rounded, color: accentColor, size: 28))),
                      _navItem(Icons.calendar_month_outlined, "Plan", 2, accentColor, idleColor),
                      _navItem(Icons.grid_view_rounded, "More", 3, accentColor, idleColor),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (isLoading) Center(child: CircularProgressIndicator(color: accentColor)),
        ],
      ),
      floatingActionButton: (index == 0 || index == 1)
          ? Padding(padding: const EdgeInsets.only(bottom: 90), child: FloatingActionButton(mini: true, backgroundColor: accentColor, onPressed: _openAddTaskSheet, child: Icon(Icons.add, color: isDark ? Colors.black : Colors.white, size: 24)))
          : null,
    );
  }

  Widget _navItem(IconData icon, String label, int i, Color accent, Color idle) {
    bool selected = index == i;
    return GestureDetector(
      onTap: () => setState(() => index = i),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(width: 50, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: selected ? accent : idle, size: 18), const SizedBox(height: 2), Text(label, style: TextStyle(color: selected ? accent : idle, fontSize: 8, fontWeight: selected ? FontWeight.bold : FontWeight.normal))])),
    );
  }
}
