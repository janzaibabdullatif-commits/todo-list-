import 'package:flutter/material.dart';
import '../models/task.dart';
import '../widgets/empty_state.dart';
import '../main.dart';

class CompletedScreen extends StatefulWidget {
  final List<Task> tasks;
  final Function(String) onDelete;

  const CompletedScreen({super.key, required this.tasks, required this.onDelete});

  @override
  State<CompletedScreen> createState() => _CompletedScreenState();
}

class _CompletedScreenState extends State<CompletedScreen> {
  final Set<String> _selectedIds = {};
  bool _isSelectionMode = false;

  List<Task> get sortedCompletedTasks {
    final list = widget.tasks.where((t) => t.isDone).toList();
    list.sort((a, b) {
      final order = {'high': 0, 'medium': 1, 'low': 2};
      int cmp = (order[a.priority.toLowerCase()] ?? 3).compareTo(order[b.priority.toLowerCase()] ?? 3);
      if (cmp != 0) return cmp;
      return (b.completedAt ?? "").compareTo(a.completedAt ?? "");
    });
    return list;
  }

  void _toggleSelectAll(List<Task> tasks) {
    setState(() {
      if (_selectedIds.length == tasks.length) {
        _selectedIds.clear();
        _isSelectionMode = false;
      } else {
        _selectedIds.addAll(tasks.map((t) => t.id));
        _isSelectionMode = true;
      }
    });
  }

  void _handleBulkDelete() {
    if (_selectedIds.isEmpty) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Delete tasks?", style: TextStyle(color: Colors.white)),
        content: Text("Delete ${_selectedIds.length} selected tasks permanently?", style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          TextButton(
            onPressed: () {
              // Copy IDs to avoid modification errors during loop
              final idsToDelete = List<String>.from(_selectedIds);
              for (var id in idsToDelete) {
                widget.onDelete(id);
              }
              setState(() {
                _selectedIds.clear();
                _isSelectionMode = false;
              });
              Navigator.pop(context);
            },
            child: const Text("DELETE ALL", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = MyApp.of(context)!.isDarkMode;
    final Color primaryColor = isDark ? Colors.yellow.shade700 : Colors.blue.shade700;
    final tasks = sortedCompletedTasks;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.blue.shade700,
        elevation: 0,
        leading: _isSelectionMode 
          ? IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() { _isSelectionMode = false; _selectedIds.clear(); }))
          : null,
        title: Text(
          _isSelectionMode ? "${_selectedIds.length} Selected" : "Completed Tasks", 
          style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white)
        ),
        actions: [
          if (tasks.isNotEmpty) ...[
            if (_isSelectionMode)
              IconButton(
                icon: const Icon(Icons.select_all), 
                onPressed: () => _toggleSelectAll(tasks),
                tooltip: "Select All",
              ),
            if (_selectedIds.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
                onPressed: _handleBulkDelete,
                tooltip: "Delete All Selected",
              ),
            if (!_isSelectionMode)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (val) {
                  if (val == 'select') setState(() => _isSelectionMode = true);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'select', child: Text("Select Tasks")),
                ],
              ),
          ],
        ],
      ),
      body: tasks.isEmpty
          ? const EmptyState(
              message: "No completed tasks yet",
              icon: Icons.check_circle_outline,
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                bool showHeader = index == 0 || tasks[index-1].priority != task.priority;
                bool isSelected = _selectedIds.contains(task.id);

                return Column(
                  key: ValueKey(task.id), // Added ValueKey for reliable list updates
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showHeader) _buildPriorityHeader(task.priority, primaryColor),
                    
                    GestureDetector(
                      onLongPress: () {
                        setState(() {
                          _isSelectionMode = true;
                          _selectedIds.add(task.id);
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? primaryColor.withAlpha(40) 
                              : (isDark ? Colors.grey[900] : Colors.grey[100]),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: isSelected ? primaryColor : primaryColor.withAlpha(20),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: ListTile(
                          onTap: () {
                            if (_isSelectionMode) {
                              setState(() {
                                if (isSelected) {
                                  _selectedIds.remove(task.id);
                                  if (_selectedIds.isEmpty) _isSelectionMode = false;
                                } else {
                                  _selectedIds.add(task.id);
                                }
                              });
                            }
                          },
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          title: Text(
                            task.title,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: isDark ? Colors.white38 : Colors.black38,
                            ),
                          ),
                          subtitle: Text(
                            task.completedAt ?? "Completed",
                            style: const TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                          trailing: _isSelectionMode 
                            ? (isSelected ? Icon(Icons.check_circle, color: primaryColor) : Icon(Icons.circle_outlined, color: primaryColor.withAlpha(100)))
                            : IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                                onPressed: () {
                                  widget.onDelete(task.id);
                                  setState(() {}); // Trigger refresh
                                },
                              ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildPriorityHeader(String priority, Color primaryColor) {
    Color color;
    switch (priority.toLowerCase()) {
      case 'high': color = Colors.redAccent; break;
      case 'medium': color = Colors.orangeAccent; break;
      default: color = Colors.greenAccent;
    }

    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 12, top: 10),
      child: Row(
        children: [
          Container(width: 4, height: 14, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(
            priority.toUpperCase(),
            style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2),
          ),
        ],
      ),
    );
  }
}
