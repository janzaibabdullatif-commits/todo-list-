import 'package:flutter/material.dart';

class TaskUtils {
  static void showTaskOptions({
    required BuildContext context,
    required Function(DateTime) onDateSelected,
    required Function(String) onPrioritySelected,
    required VoidCallback onDelete,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              const Text(
                "Task Options",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              ListTile(
                leading: const Icon(Icons.date_range),
                title: const Text("Set Date"),
                onTap: () async {
                  Navigator.pop(context);

                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );

                  if (picked != null) {
                    onDateSelected(picked);
                  }
                },
              ),

              ListTile(
                leading: const Icon(Icons.flag),
                title: const Text("Set Priority"),
                onTap: () {
                  Navigator.pop(context);

                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Select Priority"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              title: const Text("Low"),
                              onTap: () {
                                Navigator.pop(context);
                                onPrioritySelected("Low");
                              },
                            ),
                            ListTile(
                              title: const Text("Medium"),
                              onTap: () {
                                Navigator.pop(context);
                                onPrioritySelected("Medium");
                              },
                            ),
                            ListTile(
                              title: const Text("High"),
                              onTap: () {
                                Navigator.pop(context);
                                onPrioritySelected("High");
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text("Delete Task"),
                onTap: () {
                  Navigator.pop(context);
                  onDelete();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}