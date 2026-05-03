import 'package:flutter/material.dart';

class EmptyState extends StatefulWidget {
  final String message;
  final IconData icon;

  const EmptyState({
    super.key,
    required this.message,
    this.icon = Icons.smart_toy_outlined,
  });

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0, end: -20).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = isDark ? Colors.yellow.shade700 : Colors.blue.shade700;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _bounceAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _bounceAnimation.value),
                child: child,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: primaryColor.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.icon,
                size: 100,
                color: primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            widget.message,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Tap the + button to get started!",
            style: TextStyle(
              color: (isDark ? Colors.white : Colors.black).withAlpha(100),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}