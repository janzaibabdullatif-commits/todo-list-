import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'home_screen.dart';
import '../main.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with SingleTickerProviderStateMixin {
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  bool loading = false;
  bool googleLoading = false;
  bool hidePassword = true;

  late AnimationController controller;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? "27367740322-mb6u31n7lnetg9iekbch9block9c74b5.apps.googleusercontent.com"
        : null,
    scopes: ['email', 'profile'],
  );

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  Future<void> signup() async {
    if (name.text.isEmpty || email.text.isEmpty || password.text.isEmpty) {
      _showError("Please fill all fields");
      return;
    }

    setState(() => loading = true);
    try {
      var res = await http.post(
        Uri.parse("https://trendosky.com/runit/signup.php"),
        body: {
          "name": name.text.trim(),
          "email": email.text.trim(),
          "password": password.text.trim(),
        },
      );

      var data = jsonDecode(res.body);
      if (!mounted) return;
      setState(() => loading = false);

      if (data["status"] == "success") {
        _showSuccess("Signup Successful! Please Login.");
        Navigator.pop(context);
      } else {
        _showError(data["message"] ?? "Signup Failed");
      }
    } catch (e) {
      if (mounted) setState(() => loading = false);
      _showError("Connection error: $e");
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => googleLoading = true);
    try {
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        if (mounted) setState(() => googleLoading = false);
        return;
      }

      final response = await http.post(
        Uri.parse("https://trendosky.com/runit/login.php"),
        body: {
          "google_id": googleUser.id,
          "email": googleUser.email,
          "name": googleUser.displayName ?? "",
        },
      );

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
        _showError("Google Sign-In Failed: ${data["message"]}");
      }
    } catch (e) {
      _showError("Google Sign-In Failed: $e");
    } finally {
      if (mounted) setState(() => googleLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Colors.red, content: Text(msg)),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Colors.green, content: Text(msg)),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = MyApp.of(context)?.isDarkMode ?? true;
    final Color primaryColor = isDark ? Colors.yellow.shade700 : Colors.blue.shade700;
    final Color secondaryColor = isDark ? Colors.black : Colors.white;
    final Color fieldColor = isDark ? Colors.grey[900]! : Colors.grey[100]!;
    final Color textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: secondaryColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "CREATE ACCOUNT",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: primaryColor,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Join us to start organizing",
                style: TextStyle(color: textColor.withAlpha(150)),
              ),
              const SizedBox(height: 40),

              textField(name, "Full Name", Icons.person, primaryColor, fieldColor, textColor),
              const SizedBox(height: 20),

              textField(email, "Email", Icons.email, primaryColor, fieldColor, textColor),
              const SizedBox(height: 20),

              TextField(
                controller: password,
                obscureText: hidePassword,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: "Password",
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.lock, color: primaryColor),
                  suffixIcon: IconButton(
                    icon: Icon(
                      hidePassword ? Icons.visibility_off : Icons.visibility,
                      color: primaryColor,
                    ),
                    onPressed: () => setState(() => hidePassword = !hidePassword),
                  ),
                  filled: true,
                  fillColor: fieldColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 35),

              loading
                  ? CircularProgressIndicator(color: primaryColor)
                  : SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: signup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: secondaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    "SIGN UP",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(child: Divider(color: textColor.withAlpha(50))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      "OR",
                      style: TextStyle(
                        color: textColor.withAlpha(100),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: textColor.withAlpha(50))),
                ],
              ),
              const SizedBox(height: 25),

              googleLoading
                  ? CircularProgressIndicator(color: primaryColor)
                  : SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  onPressed: _handleGoogleSignIn,
                  icon: const Icon(Icons.g_mobiledata_rounded, size: 30),
                  label: const Text(
                    "CONTINUE WITH GOOGLE",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: BorderSide(color: primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: RichText(
                  text: TextSpan(
                    text: "Already have an account? ",
                    style: TextStyle(color: textColor.withAlpha(150)),
                    children: [
                      TextSpan(
                        text: "Log In",
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget textField(
      TextEditingController c,
      String hint,
      IconData icon,
      Color primary,
      Color fill,
      Color text,
      ) {
    return TextField(
      controller: c,
      style: TextStyle(color: text),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: primary),
        filled: true,
        fillColor: fill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: primary, width: 2),
        ),
      ),
    );
  }
}