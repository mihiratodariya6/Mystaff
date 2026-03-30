import 'package:flutter/material.dart';

class EmployeeSettingsScreen extends StatefulWidget {
  const EmployeeSettingsScreen({super.key});

  @override
  State<EmployeeSettingsScreen> createState() => _EmployeeSettingsScreenState();
}

class _EmployeeSettingsScreenState extends State<EmployeeSettingsScreen> {
  bool isDarkMode = false;
  bool isPrivateProfile = false;
  bool isNotificationOn = true;
  bool showActiveStatus = true; // 👈 નવું લોજીક 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Settings", style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, elevation: 1, iconTheme: const IconThemeData(color: Colors.black)),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          _sectionTitle("Appearance"),
          SwitchListTile(title: const Text("Dark Theme"), value: isDarkMode, onChanged: (val) => setState(() => isDarkMode = val), secondary: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode)),
          const Divider(),
          
          _sectionTitle("Activity & Privacy"),
          // 🚀 INSTAGRAM STYLE ACTIVE STATUS
          SwitchListTile(
            title: const Text("Show Active Status"), 
            subtitle: const Text("Let others see when you are online"), 
            value: showActiveStatus, 
            activeColor: const Color(0xFF1565C0),
            onChanged: (val) {
              setState(() => showActiveStatus = val);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(val ? "Your active status is now Visible 🟢" : "Your active status is now Hidden 👻"),
                behavior: SnackBarBehavior.floating,
              ));
            },
            secondary: const Icon(Icons.visibility),
          ),
          SwitchListTile(title: const Text("Private Profile"), subtitle: const Text("Only followed colleagues can chat"), value: isPrivateProfile, onChanged: (val) => setState(() => isPrivateProfile = val), secondary: const Icon(Icons.lock_outline)),
          const Divider(),
          
          _sectionTitle("Notifications"),
          SwitchListTile(title: const Text("Enable Notifications"), value: isNotificationOn, onChanged: (val) => setState(() => isNotificationOn = val), secondary: const Icon(Icons.notifications_none)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(title.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12, letterSpacing: 1.2)),
    );
  }
}