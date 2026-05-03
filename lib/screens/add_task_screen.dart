import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'dart:ui';
import '../services/api_service.dart';

class AddTaskScreen extends StatefulWidget {
  final String userId;
  final bool isTodayTab;

  const AddTaskScreen({
    super.key,
    required this.userId,
    this.isTodayTab = false,
  });

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  TextEditingController controller = TextEditingController();
  String priority = 'low';
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  Uint8List? attachmentBytes;
  String? attachmentName;

  final List<String> priorities = ['low', 'medium', 'high'];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.isTodayTab) {
      selectedDate = DateTime.now();
    }
  }

  // ✅ Combined Date & Time Reminder Flow
  Future<void> pickReminder() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          selectedDate = date;
          selectedTime = time;
        });
      }
    }
  }

  Future<void> pickAttachment() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        attachmentBytes = result.files.first.bytes;
        attachmentName = result.files.first.name;
      });
    }
  }

  void saveTask() async {
    if (controller.text.isEmpty) return;

    String? reminderISO;
    if (selectedDate != null && selectedTime != null) {
      final dt = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );
      reminderISO = dt.toIso8601String();
    }

    final dateStr = selectedDate != null
        ? DateFormat('yyyy-MM-dd').format(selectedDate!)
        : null;

    final success = await ApiService.addTask(
      widget.userId,
      controller.text,
      priority: priority,
      reminderDateTime: reminderISO,
      dueDate: dateStr,
      attachmentBytes: attachmentBytes,
      attachmentName: attachmentName,
    );

    if (mounted) {
      if (success) {
        Navigator.pop(context, true); // ✅ Signal refresh
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to save task"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.yellow.shade700 : Colors.blue.shade700;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(widget.isTodayTab ? "Add Today's Task" : "Add Task"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  labelText: "What needs to be done?",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 30),

              Text("Priority", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: priorities.map((p) {
                  final selected = priority == p;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(p.toUpperCase()),
                      selected: selected,
                      onSelected: (_) => setState(() => priority = p),
                      selectedColor: primaryColor,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),

              Text("Schedule", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  // ✅ Today Shortcut
                  _shortcutButton("Today", () {
                    setState(() => selectedDate = DateTime.now());
                  }, selectedDate != null && DateFormat('d/M/y').format(selectedDate!) == DateFormat('d/M/y').format(DateTime.now())),
                  const SizedBox(width: 10),
                  // ✅ Tomorrow Shortcut
                  _shortcutButton("Tomorrow", () {
                    setState(() => selectedDate = DateTime.now().add(const Duration(days: 1)));
                  }, selectedDate != null && DateFormat('d/M/y').format(selectedDate!) == DateFormat('d/M/y').format(DateTime.now().add(const Duration(days: 1)))),
                ],
              ),
              const SizedBox(height: 30),

              Text("Reminder", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: pickReminder,
                icon: const Icon(Icons.alarm),
                label: Text(selectedTime == null
                    ? "Set Reminder"
                    : "${DateFormat('d MMM').format(selectedDate!)} at ${selectedTime!.format(context)}"),
              ),
              const SizedBox(height: 30),

              Text("Attachment", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: pickAttachment,
                icon: const Icon(Icons.attach_file),
                label: Text(attachmentName ?? "Add Attachment"),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: saveTask,
                  child: Text("SAVE TASK", style: TextStyle(color: isDark ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _shortcutButton(String label, VoidCallback onTap, bool isSelected) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.yellow.shade700 : Colors.grey.withOpacity(0.1),
          foregroundColor: isSelected ? Colors.black : Colors.grey,
          elevation: 0,
        ),
        onPressed: onTap,
        child: Text(label),
      ),
    );
  }
}