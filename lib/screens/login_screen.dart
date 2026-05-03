import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import '../main.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  bool loading = false;
  late AnimationController controller;
  late final GoogleSignIn _googleSignIn;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
    
    _googleSignIn = GoogleSignIn(
      clientId: kIsWeb ? "27367740322-mb6u31n7lnetg9iekbch9block9c74b5.apps.googleusercontent.com" : null,
      scopes: <String>['email', 'profile'],
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => loading = true);
    try {
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        if (mounted) setState(() => loading = false);
        return;
      }

      final response = await http.post(
        Uri.parse("https://trendosky.com/runit/login.php"),
        body: {
          "google_id": googleUser.id,
          "email": googleUser.email,
          "name": googleUser.displayName ?? "",
        },
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["status"] == "success") {
          final String userId = data["user_id"].toString();
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool("isLogin", true);
          await prefs.setString("userId", userId);
          await prefs.setString("name", googleUser.displayName ?? "User");
          await prefs.setString("email", googleUser.email);

          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen(userId: userId)),
          );
        } else {
          _showError("Server Error: ${data["message"]}");
        }
      } else {
        _showError("Connection failed (Status: ${response.statusCode})");
      }
    } catch (e) {
      _showError("Sign-In Error. Please check your internet or Google settings.");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(msg),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
        )
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = MyApp.of(context)?.isDarkMode ?? true;
    final Color primaryColor = isDark ? Colors.yellow.shade700 : Colors.blue.shade700;
    final Color bgColor = isDark ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RotationTransition(
                turns: controller,
                child: Icon(Icons.check_circle_outline, size: 100, color: primaryColor),
              ),
              const SizedBox(height: 40),
              Text(
                  "DONE IT",
                  style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: primaryColor,
                      letterSpacing: 6
                  )
              ),
              const SizedBox(height: 10),
              Text(
                  "Organize your life properly",
                  style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 16)
              ),
              const SizedBox(height: 80),

              if (loading)
                CircularProgressIndicator(color: primaryColor)
              else
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: isDark ? Colors.black : Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 8,
                        ),
                        onPressed: _handleGoogleSignIn,
                        icon: const Icon(Icons.g_mobiledata_rounded, size: 30),
                        label: const Text(
                            "CONTINUE WITH GOOGLE",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Text(
                      "Secure sync to trendosky.com",
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
