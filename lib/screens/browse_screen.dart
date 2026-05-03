import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'completed_screen.dart';
import 'about_screen.dart';
import 'help_screen.dart';
import 'login_screen.dart';
import 'activity_screen.dart';
import '../models/task.dart';
import '../main.dart';

class BrowseScreen extends StatefulWidget {
  final String userId;
  final bool isDark;
  final List<Task> tasks;
  final Function(String) onDelete;

  const BrowseScreen({
    super.key,
    required this.userId,
    required this.isDark,
    required this.tasks,
    required this.onDelete,
    required Function toggleTheme, 
  });

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  String name = "";
  List<String> dummyProfiles = [];

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString("name") ?? "";
      dummyProfiles = prefs.getStringList("dummy_profiles") ?? [];
    });
  }

  Future<void> updateName(String newName) async {
    if (newName.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("name", newName.trim());
    setState(() {
      name = newName.trim();
    });
  }

  Future<void> switchProfile(String profileName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("name", profileName);
    setState(() {
      name = profileName;
    });
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLogin", false);
    await prefs.remove("userId");

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _showEditNameDialog() {
    TextEditingController nameController = TextEditingController(text: name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : Colors.white,
        title: const Text("Edit Profile Name", style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: nameController,
          autofocus: true,
          style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
          decoration: const InputDecoration(hintText: "Enter your name"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          TextButton(
            onPressed: () {
              updateName(nameController.text);
              Navigator.pop(context);
            },
            child: const Text("SAVE", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = isDarkTheme ? Colors.yellow.shade800 : Colors.blue.shade700;
    
    return Scaffold(
      backgroundColor: isDarkTheme ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkTheme ? Colors.black : Colors.blue.shade700,
        elevation: 0,
        leading: name.isNotEmpty 
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: isDarkTheme ? Colors.yellow.shade700 : Colors.white,
                child: Text(
                  name[0].toUpperCase(),
                  style: TextStyle(
                    color: isDarkTheme ? Colors.black : Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          : null,
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 120), // Added large bottom padding
              children: [
                _buildBrowseItem(
                  Icons.bar_chart_rounded, 
                  "Activity & Progress", 
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => ActivityScreen(tasks: widget.tasks))), 
                  isDarkTheme
                ),
                _buildBrowseItem(Icons.task_alt, "Completed Tasks", () => Navigator.push(context, MaterialPageRoute(builder: (_) => CompletedScreen(tasks: widget.tasks, onDelete: widget.onDelete))), isDarkTheme),
                _buildBrowseItem(Icons.info_outline, "About App", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen())), isDarkTheme),
                _buildBrowseItem(Icons.help_outline, "Help & Support", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpScreen())), isDarkTheme),
                
                const SizedBox(height: 20),
                if (dummyProfiles.isNotEmpty) ...[
                  const Text("Profiles", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 10),
                  ...dummyProfiles.map((pName) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      dense: true,
                      tileColor: isDarkTheme ? Colors.grey[900] : Colors.grey[100],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      leading: CircleAvatar(radius: 12, backgroundColor: primaryColor.withAlpha(100), child: Text(pName[0].toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.white))),
                      title: Text(pName, style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black, fontSize: 14)),
                      onTap: () => switchProfile(pName),
                    ),
                  )),
                ],

                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: isDarkTheme ? Colors.grey[900] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: primaryColor.withAlpha(30)),
                  ),
                  child: SwitchListTile(
                    title: Text("Dark Mode", style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                    secondary: Icon(Icons.dark_mode, color: primaryColor),
                    activeColor: primaryColor,
                    value: MyApp.of(context)!.isDarkMode,
                    onChanged: (_) => MyApp.of(context)!.toggleTheme(),
                  ),
                ),
                
                const SizedBox(height: 20),
                _buildBrowseItem(Icons.edit_note, "Rename Profile", _showEditNameDialog, isDarkTheme),
                
                // Reduced and Centered Logout Button
                const SizedBox(height: 40),
                Center(
                  child: SizedBox(
                    width: 160,
                    height: 40,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent.withOpacity(0.1),
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent, width: 1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      onPressed: logout,
                      icon: const Icon(Icons.logout_rounded, size: 18),
                      label: const Text("LOGOUT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrowseItem(IconData icon, String title, VoidCallback onTap, bool isDarkTheme) {
    final Color primaryColor = isDarkTheme ? Colors.yellow.shade800 : Colors.blue.shade700;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDarkTheme ? Colors.grey[900] : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withAlpha(30)),
      ),
      child: ListTile(
        leading: Icon(icon, color: primaryColor),
        title: Text(title, style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}