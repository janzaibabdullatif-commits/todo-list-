import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../main.dart';
import '../widgets/empty_state.dart';
import '../widgets/ai_chat_sheet.dart';

class TodayScreen extends StatefulWidget {
  final String userId;
  final List<Task> tasks;
  final Function(Task) onToggle;
  final Function(String) onDelete;
  final Function(Task, String) onUpdatePriority;
  final Function(Task, String) onUpdateDate;
  final Function(Task, String) onUpdateReminder;
  final Function(Task) onPickAttachments;

  const TodayScreen({
    super.key,
    required this.userId,
    required this.tasks,
    required this.onToggle,
    required this.onDelete,
    required this.onUpdatePriority,
    required this.onUpdateDate,
    required this.onUpdateReminder,
    required this.onPickAttachments,
  });

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  // ✅ Dynamic getter ensures tasks move in/out of the list instantly
  List<Task> get todayTasks => widget.tasks.where((t) => t.isForToday()).toList().reversed.toList();

  void _openAIChat() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AIChatSheet(),
    );
  }

  void _showTaskOptions(Task task) {
    final bool isDark = MyApp.of(context)!.isDarkMode;
    final Color bgColor = isDark ? Colors.grey[900]! : Colors.white;
    final Color primaryColor = isDark ? Colors.yellow.shade700 : Colors.blue.shade700;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.7,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(task.title, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
                      ),
                      _buildMenuAction(Icons.flag_rounded, "Set Priority", task.priority.toUpperCase(), () {
                        Navigator.pop(context);
                        _showPriorityPicker(task);
                      }, isDark, primaryColor),
                      _buildMenuAction(Icons.calendar_today_rounded, "Change Date", "Currently Today", () {
                        Navigator.pop(context);
                        _showDayPicker(task);
                      }, isDark, primaryColor),
                      _buildMenuAction(Icons.notifications_active_outlined, "Set Reminder", task.reminderTime ?? "None", () {
                        Navigator.pop(context);
                        _showReminderPicker(task);
                      }, isDark, primaryColor),
                      const Divider(indent: 20, endIndent: 20, height: 30),
                      _buildMenuAction(Icons.delete_outline_rounded, "Delete Task", "Remove permanently", () {
                        Navigator.pop(context);
                        widget.onDelete(task.id);
                      }, isDark, Colors.redAccent, isDelete: true),
                    ],
                  ),
                ),
              ],
            );
          }
        );
      },
    );
  }

  Widget _buildMenuAction(IconData icon, String title, String subtitle, VoidCallback onTap, bool isDark, Color color, {bool isDelete = false}) {
    return ListTile(
      onTap: onTap,
      leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 20)),
      title: Text(title, style: TextStyle(color: isDelete ? Colors.redAccent : (isDark ? Colors.white : Colors.black), fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
    );
  }

  void _showPriorityPicker(Task task) {
    final bool isDark = MyApp.of(context)!.isDarkMode;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: ["low", "medium", "high"].map((p) => ListTile(
          title: Text(p.toUpperCase(), style: TextStyle(color: _getPriorityColor(p, isDark), fontWeight: FontWeight.bold)),
          onTap: () async {
            await widget.onUpdatePriority(task, p);
            if (mounted) Navigator.pop(context);
          },
        )).toList(),
      ),
    );
  }

  void _showDayPicker(Task task) {
    final bool isDark = MyApp.of(context)!.isDarkMode;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: ["Today", "Tomorrow", "Select Date"].map((d) => ListTile(
          title: Text(d, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
          onTap: () async {
            String dateValue;
            if (d == "Select Date") {
              final DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2100));
              if (picked != null) dateValue = DateFormat('yyyy-MM-dd').format(picked);
              else return;
            } else if (d == "Tomorrow") {
              dateValue = DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 1)));
            } else {
              dateValue = DateFormat('yyyy-MM-dd').format(DateTime.now());
            }
            await widget.onUpdateDate(task, dateValue);
            if (mounted) Navigator.pop(context);
          },
        )).toList(),
      ),
    );
  }

  void _showReminderPicker(Task task) {
    final bool isDark = MyApp.of(context)!.isDarkMode;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => ListTile(
        leading: Icon(Icons.alarm, color: isDark ? Colors.yellow : Colors.blue),
        title: Text("Pick Date & Time", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        onTap: () async {
          DateTime? date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2100));
          if (date != null) {
            TimeOfDay? time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
            if (time != null) {
              final reminder = DateTime(date.year, date.month, date.day, time.hour, time.minute);
              await widget.onUpdateReminder(task, reminder.toIso8601String());
            }
          }
          if (mounted) Navigator.pop(context);
        },
      ),
    );
  }

  Color _getPriorityColor(String p, bool isDark) {
    switch (p.toLowerCase()) {
      case 'high': return isDark ? Colors.redAccent : Colors.red.shade700;
      case 'medium': return isDark ? Colors.orangeAccent : Colors.orange.shade700;
      default: return isDark ? Colors.greenAccent : Colors.green.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MyApp.of(context)!.isDarkMode;
    final primaryColor = isDark ? Colors.yellow.shade700 : Colors.blue.shade700;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.blue.shade700,
        elevation: 0,
        title: const Text("Today's Tasks", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
        actions: [
          IconButton(icon: const Icon(Icons.auto_awesome_rounded, color: Colors.white), onPressed: _openAIChat),
          const SizedBox(width: 10),
        ],
      ),
      body: todayTasks.isEmpty
          ? const EmptyState(message: "All clear for today!", icon: Icons.wb_sunny_rounded)
          : ListView.builder(
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: todayTasks.length,
        itemBuilder: (context, i) {
          final task = todayTasks[i];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primaryColor.withAlpha(30)),
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(isDark ? 100 : 20), blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: GestureDetector(
                onTap: () => widget.onToggle(task),
                child: Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: primaryColor, width: 2)),
                  child: task.isDone ? Icon(Icons.check, size: 14, color: primaryColor) : null,
                ),
              ),
              title: Text(task.title, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 16, decoration: task.isDone ? TextDecoration.lineThrough : null)),
              subtitle: _buildTaskSubtitle(task, isDark, primaryColor),
              onTap: () => _showTaskOptions(task),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTaskSubtitle(Task task, bool isDark, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 8,
        children: [
          _buildChip(Icons.wb_sunny, "Due Today", Colors.orange.withAlpha(50), Colors.orange),
          _buildChip(Icons.flag, task.priority.toUpperCase(), _getPriorityColor(task.priority, isDark).withAlpha(50), _getPriorityColor(task.priority, isDark)),
          if (task.reminderTime != null && task.reminderTime!.isNotEmpty)
            _buildChip(Icons.notifications_active_outlined, "Reminder Set", Colors.red.withAlpha(40), isDark ? Colors.redAccent : Colors.red.shade700),
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 12, color: textColor), const SizedBox(width: 4), Flexible(child: Text(label, style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis))]),
    );
  }
}
