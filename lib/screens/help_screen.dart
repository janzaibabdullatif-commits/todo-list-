import 'package:flutter/material.dart';
import '../main.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = isDark ? Colors.yellow.shade700 : Colors.blue.shade700;
    final Color titleColor = Colors.white; // Top heading in white for light theme

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.blue.shade700,
        elevation: 0,
        title: Text(
          "Help & Support Center", 
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.yellow.shade700 : titleColor,
          )
        ),
        iconTheme: IconThemeData(color: isDark ? Colors.yellow.shade700 : titleColor),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildHelpSection(
            "Welcome to Done It", 
            "At Done It, we are committed to providing you with the best tools to organize your life. This support center is designed to answer all your questions and help you master the app's features. Whether you're a first-time user or an expert looking for tips, we've got you covered.",
            Icons.rocket_launch_outlined,
            primaryColor,
            isDark,
          ),
          const SizedBox(height: 20),
          _buildHelpSection(
            "Direct Support & Contact", 
            "If you encounter any issues or have suggestions for new features, please don't hesitate to reach out to us directly. We value your feedback and aim to respond to all inquiries within 24 hours.\n\n"
            "📧 Email: janzaibabdullatif@gmail.com\n"
            "💬 WhatsApp: 03065159203\n\n"
            "Feel free to message us anytime for technical assistance or general queries.",
            Icons.contact_support_outlined,
            primaryColor,
            isDark,
          ),
          const SizedBox(height: 20),
          _buildHelpSection(
            "Advanced Task Management", 
            "Take control of your workflow with our advanced features. Use the '+' button to add tasks with specific priorities. Tapping the task check-circle doesn't just mark it as done; it creates a permanent log of your achievement, complete with the day, date, and exact time. You can view these logs anytime in the 'Completed Tasks' section found in the Browse menu.",
            Icons.task_alt,
            primaryColor,
            isDark,
          ),
          const SizedBox(height: 20),
          _buildHelpSection(
            "Calendar & Scheduling", 
            "Our century-spanning calendar is one of our most powerful features. Located in the 'Upcoming' tab, it allows you to plan your life years in advance. You can jump between years by tapping the year in the top bar, making long-term goal setting simpler than ever before. It's not just a list; it's your roadmap to success.",
            Icons.calendar_month_outlined,
            primaryColor,
            isDark,
          ),
          const SizedBox(height: 20),
          _buildHelpSection(
            "Cloud Sync & Security", 
            "We understand how important your data is. That's why we use state-of-the-art encryption to sync your tasks with our servers at trendosky.com. This ensures that even if you switch devices, your tasks, priorities, and completion history remain safe and accessible under your account. Your privacy is guaranteed.",
            Icons.security,
            primaryColor,
            isDark,
          ),
          const SizedBox(height: 30),
          Center(
            child: Text(
              "Designed with focus by the Done jahanzaib",
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHelpSection(String title, String content, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold, 
                    color: isDark ? Colors.white : Colors.black
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            content,
            style: TextStyle(
              fontSize: 14, 
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}