import 'package:flutter/material.dart';
import '../models/task.dart';
import '../main.dart';

class ActivityScreen extends StatefulWidget {
  final List<Task> tasks;

  const ActivityScreen({super.key, required this.tasks});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = MyApp.of(context)!.isDarkMode;
    final Color primaryColor = isDark ? Colors.yellow.shade700 : Colors.blue.shade700;
    final Color headingColor = Colors.white;

    // Statistics Calculation for ALL tasks (Overall)
    final int total = widget.tasks.length;
    final int completed = widget.tasks.where((t) => t.isDone).length;
    final int pending = total - completed;
    final double completionRate = total > 0 ? (completed / total) : 0;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.blue.shade700,
        elevation: 0,
        title: Text("Performance Dashboard", 
          style: TextStyle(fontWeight: FontWeight.bold, color: headingColor)),
        iconTheme: IconThemeData(color: headingColor),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- TOP ANIMATED CIRCULAR GRAPH ---
            Center(
              child: _buildCircularEfficiency(completionRate, primaryColor, isDark),
            ),
            const SizedBox(height: 40),
            
            _buildSectionHeader("Key Statistics", isDark),
            const SizedBox(height: 20),
            
            // Stats Grid
            Row(
              children: [
                _buildStatCard("Total Work", total.toString(), Icons.analytics_rounded, primaryColor, isDark),
                const SizedBox(width: 15),
                _buildStatCard("Success", completed.toString(), Icons.verified_user_rounded, Colors.green, isDark),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                _buildStatCard("Remaining", pending.toString(), Icons.hourglass_top_rounded, Colors.orange, isDark),
                const SizedBox(width: 15),
                _buildStatCard("Score", "${(completionRate * 100).toStringAsFixed(0)}%", Icons.emoji_events_rounded, Colors.purple, isDark),
              ],
            ),
            
            const SizedBox(height: 40),
            _buildSectionHeader("Productivity Analytics", isDark),
            const SizedBox(height: 25),
            
            // --- ANIMATED HORIZONTAL BARS ---
            _buildAnimatedGraph(completed, pending, total, isDark, primaryColor),
            
            const SizedBox(height: 40),
            _buildProfessionalInsight(completed, total, isDark, primaryColor),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w900,
        color: isDark ? Colors.white : Colors.black,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildCircularEfficiency(double rate, Color color, bool isDark) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: rate),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.fastOutSlowIn,
      builder: (context, value, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withAlpha(10),
                boxShadow: [
                  BoxShadow(color: color.withAlpha(20), blurRadius: 30, spreadRadius: 5)
                ],
              ),
            ),
            SizedBox(
              width: 150,
              height: 150,
              child: CircularProgressIndicator(
                value: value,
                strokeWidth: 12,
                backgroundColor: color.withAlpha(30),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeCap: StrokeCap.round,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${(value * 100).toStringAsFixed(0)}%",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  "Efficiency",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade500,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: color.withAlpha(40), width: 1.5),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withAlpha(20), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 15),
            Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
            Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedGraph(int completed, int pending, int total, bool isDark, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: primaryColor.withAlpha(20)),
      ),
      child: Column(
        children: [
          _buildGraphBar("Tasks Accomplished", completed, total, Colors.green),
          const SizedBox(height: 25),
          _buildGraphBar("Tasks Outstanding", pending, total, Colors.orange),
          const SizedBox(height: 25),
          _buildGraphBar("Total Capability", total, total, primaryColor),
        ],
      ),
    );
  }

  Widget _buildGraphBar(String label, int value, int total, Color color) {
    double factor = total > 0 ? (value / total) : 0;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade600, fontSize: 13)),
            Text("$value", style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 15)),
          ],
        ),
        const SizedBox(height: 12),
        Stack(
          children: [
            Container(height: 10, width: double.infinity, decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(5))),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: factor),
              duration: const Duration(milliseconds: 1500),
              curve: Curves.elasticOut,
              builder: (context, val, child) {
                return FractionallySizedBox(
                  widthFactor: val,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [BoxShadow(color: color.withAlpha(100), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfessionalInsight(int completed, int total, bool isDark, Color color) {
    String msg = "";
    if (total == 0) msg = "Your productivity journey starts now. Add your first task and witness your growth!";
    else if (completed == total) msg = "Elite Status! You've achieved a perfect score. You are operating at peak human performance.";
    else if (completed > total / 2) msg = "Momentum is on your side! You've cleared the majority of your load. Finish strong!";
    else msg = "Consistency builds greatness. Focus on one task at a time to improve your daily efficiency.";

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withAlpha(30), color.withAlpha(5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Column(
        children: [
          Icon(Icons.auto_awesome_rounded, color: color, size: 30),
          const SizedBox(height: 15),
          Text(
            msg,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.black87,
              fontStyle: FontStyle.italic,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}