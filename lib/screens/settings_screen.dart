import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  final String userId;

  const SettingsScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {

    return ListView(
      children: [

        ListTile(
          title: Text("About App"),
          subtitle: Text("Task Manager App v1"),
        ),

        ListTile(
          title: Text("Help & Privacy"),
        ),

        SwitchListTile(
          title: Text("Dark Mode"),
          value: false,
          onChanged: (v) {},
        ),

      ],
    );
  }
}