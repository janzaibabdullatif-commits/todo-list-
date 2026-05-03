import 'package:flutter/material.dart';
import 'dart:ui';
import '../services/ai_service.dart';
import '../main.dart';

class AIChatSheet extends StatefulWidget {
  const AIChatSheet({super.key});

  @override
  State<AIChatSheet> createState() => _AIChatSheetState();
}

class _AIChatSheetState extends State<AIChatSheet> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isTyping = false;

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "text": text});
      _isTyping = true;
    });
    _controller.clear();

    final response = await AIService.sendMessage(text);

    setState(() {
      _messages.add({"role": "ai", "text": response});
      _isTyping = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MyApp.of(context)!.isDarkMode;
    final primaryColor = isDark ? Colors.yellow.shade700 : Colors.blue.shade700;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: (isDark ? Colors.black : Colors.white).withOpacity(0.85),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(color: primaryColor.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, color: primaryColor),
                  const SizedBox(width: 10),
                  Text("Gemini AI Assistant", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _messages.length,
                itemBuilder: (context, i) {
                  final m = _messages[i];
                  final isUser = m['role'] == 'user';
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                      decoration: BoxDecoration(
                        color: isUser ? primaryColor : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(m['text']!, style: TextStyle(color: isUser ? (isDark ? Colors.black : Colors.white) : (isDark ? Colors.white : Colors.black))),
                    ),
                  );
                },
              ),
            ),
            if (_isTyping)
               Padding(
                padding: const EdgeInsets.only(left: 20, bottom: 10),
                child: Align(alignment: Alignment.centerLeft, child: Text("Gemini is thinking...", style: TextStyle(color: primaryColor, fontSize: 12, fontStyle: FontStyle.italic))),
              ),
            Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, left: 20, right: 20, top: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        hintText: "Ask anything...",
                        hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(onPressed: _sendMessage, icon: Icon(Icons.send_rounded, color: primaryColor)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
