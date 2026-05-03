import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../main.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = MyApp.of(context)!.isDarkMode;
    final Color primaryColor = isDark ? Colors.white : Colors.blue.shade700;
    final Color titleColor = Colors.white; // Force white for light theme visibility
    final String todayDate = DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());
    
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.blue.shade700,
        elevation: 0,
        title: Text(
          "Our Vision", 
          style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.yellow.shade700 : titleColor)
        ),
        iconTheme: IconThemeData(color: isDark ? Colors.yellow.shade700 : titleColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: (isDark ? Colors.yellow.shade700 : Colors.blue.shade700).withAlpha(30),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                Icons.stars_rounded, 
                size: 70, 
                color: isDark ? Colors.yellow.shade700 : Colors.blue.shade700
              ),
            ),
            const SizedBox(height: 35),
            Text(
              "Done It: Elevating Productivity",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.yellow.shade700 : Colors.blue.shade700,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 25),
            _buildAboutParagraph(
              "At Done It, we believe that clear organization is the foundation of a successful and stress-free life. In a world that is increasingly fast-paced and demanding, our mission is to provide you with a powerful yet simple tool that cuts through the noise and helps you focus on your most important goals.",
              isDark
            ),
            _buildAboutParagraph(
              "Our application is built on the pillars of efficiency and personalization. We understand that everyone has a unique way of working, which is why we've implemented features like dynamic priority levels and a century-spanning calendar. Whether you're planning your day or your decade, Done It is designed to grow with you.",
              isDark
            ),
            _buildAboutParagraph(
              "Technology should work for you, not the other way around. That's why we've poured hundreds of hours into perfecting our user interface, ensuring that the experience is not only functional but also visually stunning. From the professional dark theme to the fresh and clean light mode, every pixel is crafted with your focus in mind.",
              isDark
            ),
            _buildAboutParagraph(
              "Security is the silent backbone of our platform. By choosing Done It, you are trusting us with your schedule, and we take that responsibility seriously. Our cloud synchronization is built on industry-standard security protocols, ensuring that your data remains yours and yours alone, accessible whenever you need it, wherever you are.",
              isDark
            ),
            const SizedBox(height: 40),
            Divider(color: (isDark ? Colors.yellow.shade700 : Colors.blue.shade700).withAlpha(50)),
            const SizedBox(height: 20),
            Text(
              "This application was meticulously crafted with passion by Jahanzaib. Today, on $todayDate, we reaffirm our commitment to helping you achieve more every single day.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.yellow.shade700 : Colors.blue.shade700,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              "Version 1.0.0 Stable Release\n© 2024 All Rights Reserved",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500, 
                fontSize: 11,
                height: 1.8
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutParagraph(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(
        text,
        textAlign: TextAlign.justify,
        style: TextStyle(
          fontSize: 15,
          color: isDark ? Colors.white70 : Colors.black87,
          height: 1.7,
        ),
      ),
    );
  }
}