import 'package:flutter/material.dart';
import 'browse_screen.dart';
import '../models/task.dart';

class BrowseScreenWrapper extends StatefulWidget {
  final String userId;
  final bool isDark;
  final Function toggleTheme;
  final List<Task> tasks;
  final Function(String) onDelete;

  const BrowseScreenWrapper({
    super.key,
    required this.userId,
    required this.isDark,
    required this.toggleTheme,
    required this.tasks,
    required this.onDelete,
  });

  @override
  State<BrowseScreenWrapper> createState() => _BrowseScreenWrapperState();
}

class _BrowseScreenWrapperState extends State<BrowseScreenWrapper> {
  @override
  Widget build(BuildContext context) {
    return BrowseScreen(
      userId: widget.userId,
      isDark: widget.isDark,
      toggleTheme: widget.toggleTheme,
      tasks: widget.tasks,
      onDelete: widget.onDelete,
    );
  }
}