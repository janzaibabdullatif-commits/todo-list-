import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../main.dart';

class UpcomingScreen extends StatefulWidget {
  final List<Task> tasks;

  const UpcomingScreen({super.key, required this.tasks});

  @override
  State<UpcomingScreen> createState() => _UpcomingScreenState();
}

class _UpcomingScreenState extends State<UpcomingScreen> {
  final int currentYear = DateTime.now().year;
  DateTime selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final bool isDark = MyApp.of(context)?.isDarkMode ?? true;
    final Color primaryColor = isDark ? Colors.yellow.shade700 : Colors.blue.shade700;
    final Color bgColor = isDark ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildProfessionalHeader(primaryColor, isDark),
            _buildWeekdayHeader(isDark, primaryColor),
            
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 100),
                itemCount: 120, // 10 Years scrollable
                itemBuilder: (context, index) {
                  int monthOffset = (DateTime.now().month - 1) + index;
                  int year = DateTime.now().year + (monthOffset ~/ 12);
                  int month = (monthOffset % 12) + 1;
                  return _buildMonthCard(year, month, primaryColor, isDark);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalHeader(Color primaryColor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Calendar View • ${DateTime.now().year}",
                style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1),
              ),
              Text(
                "Upcoming",
                style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w900, fontSize: 32),
              ),
            ],
          ),
          
          GestureDetector(
            onTap: _showMiniCalendarPicker,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.yellow.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: primaryColor.withOpacity(0.3)),
              ),
              child: Icon(Icons.calendar_month_rounded, color: primaryColor, size: 26),
            ),
          ),
        ],
      ),
    );
  }

  void _showMiniCalendarPicker() async {
    final isDark = MyApp.of(context)!.isDarkMode;
    final primary = isDark ? Colors.yellow.shade700 : Colors.blue.shade700;

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDay,
      firstDate: DateTime(currentYear - 2),
      lastDate: DateTime(currentYear + 10),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: isDark 
            ? ColorScheme.dark(primary: primary, onPrimary: Colors.black, surface: Colors.black, onSurface: Colors.white)
            : ColorScheme.light(primary: primary, onPrimary: Colors.white, surface: Colors.white, onSurface: Colors.black),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        selectedDay = picked;
      });
      _showTasksDialog(picked);
    }
  }

  Widget _buildWeekdayHeader(bool isDark, Color primary) {
    const days = ["M", "T", "W", "T", "F", "S", "S"];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
      child: Row(
        children: days.map((d) => Expanded(
          child: Center(child: Text(d, style: TextStyle(color: isDark ? primary.withOpacity(0.5) : Colors.black38, fontWeight: FontWeight.w900, fontSize: 12))),
        )).toList(),
      ),
    );
  }

  Widget _buildMonthCard(int year, int month, Color primaryColor, bool isDark) {
    final monthName = DateFormat('MMMM yyyy').format(DateTime(year, month)).toUpperCase();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDark ? Colors.black : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.yellow.withOpacity(0.3) : Colors.black12, width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            monthName,
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 3),
          ),
          const SizedBox(height: 15),
          _buildGrid(year, month, primaryColor, isDark),
        ],
      ),
    );
  }

  Widget _buildGrid(int year, int month, Color primaryColor, bool isDark) {
    int daysInMonth = DateTime(year, month + 1, 0).day;
    int firstWeekday = DateTime(year, month, 1).weekday;

    List<Widget> widgets = [];
    for (int i = 1; i < firstWeekday; i++) widgets.add(const SizedBox());

    for (int d = 1; d <= daysInMonth; d++) {
      final date = DateTime(year, month, d);
      bool isToday = (d == DateTime.now().day && month == DateTime.now().month && year == DateTime.now().year);
      
      // Check if this date has any tasks
      bool hasTasks = _dateHasTasks(date);

      widgets.add(
        GestureDetector(
          onTap: () {
            if (hasTasks) {
              _showTasksDialog(date);
            }
          },
          child: Center(
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: isToday ? primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: hasTasks ? Border.all(color: primaryColor.withOpacity(0.5), width: 1) : null,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text("$d", style: TextStyle(
                    fontWeight: isToday ? FontWeight.w900 : FontWeight.w600,
                    color: isToday ? Colors.black : (isDark ? Colors.white : Colors.black),
                    fontSize: 14
                  )),
                  if (hasTasks && !isToday)
                    Positioned(
                      bottom: 4,
                      child: Container(
                        width: 4, height: 4,
                        decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      mainAxisSpacing: 5,
      crossAxisSpacing: 5,
      children: widgets,
    );
  }

  bool _dateHasTasks(DateTime day) {
    final isoDate = DateFormat('yyyy-MM-dd').format(day);
    final slashDate = DateFormat('d/M/yyyy').format(day);
    final slashDateLong = DateFormat('dd/MM/yyyy').format(day);

    return widget.tasks.any((t) {
      if (t.isDone) return false;
      if (t.date == null) return false;
      final dStr = t.date!.trim();
      return dStr == isoDate || dStr == slashDate || dStr == slashDateLong || dStr.startsWith(isoDate);
    });
  }

  void _showTasksDialog(DateTime date) {
    final isDark = MyApp.of(context)!.isDarkMode;
    final primaryColor = isDark ? Colors.yellow.shade700 : Colors.blue.shade700;
    final textColor = isDark ? Colors.white : Colors.black;
    
    final isoDate = DateFormat('yyyy-MM-dd').format(date);
    final slashDate = DateFormat('d/M/yyyy').format(date);
    final slashDateLong = DateFormat('dd/MM/yyyy').format(date);

    final list = widget.tasks.where((t) {
      if (t.isDone) return false;
      if (t.date == null) return false;
      final dStr = t.date!.trim();
      return dStr == isoDate || dStr == slashDate || dStr == slashDateLong || dStr.startsWith(isoDate);
    }).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: isDark ? Colors.black : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(color: isDark ? Colors.yellow.withOpacity(0.5) : Colors.black12, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('EEEE, d MMMM').format(date), style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 20),
            ...list.map((t) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: isDark ? Colors.grey[900] : Colors.grey[100], borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  Container(width: 6, height: 6, decoration: BoxDecoration(color: _getPriorityColor(t.priority), shape: BoxShape.circle)),
                  const SizedBox(width: 12),
                  Text(t.title, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                ],
              ),
            )).toList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String p) {
    if (p.toLowerCase() == 'high') return Colors.redAccent;
    if (p.toLowerCase() == 'medium') return Colors.orangeAccent;
    return Colors.greenAccent;
  }
}
