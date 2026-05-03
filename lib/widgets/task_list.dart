import 'package:flutter/material.dart';

class TaskList extends StatelessWidget {
  final List tasks;

  const TaskList({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {

        var t = tasks[index];

        return Card(
          child: ListTile(
            title: Text(t['title']),
            subtitle: Text(t['date'] ?? ""),

            leading: Checkbox(
              value: t['is_done'] == "1",
              onChanged: (_) {},
            ),

            trailing: Icon(Icons.delete),
          ),
        );
      },
    );
  }
}