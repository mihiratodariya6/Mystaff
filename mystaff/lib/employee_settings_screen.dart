import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmployeeSettingsScreen extends StatefulWidget {
  const EmployeeSettingsScreen({super.key});

  @override
  State<EmployeeSettingsScreen> createState() => _EmployeeSettingsScreenState();
}

class _EmployeeSettingsScreenState extends State<EmployeeSettingsScreen> {
  bool isDarkMode = false;
  bool isPrivateProfile = false;
  bool isNotificationOn = true;
  bool showActiveStatus = true; 
  String uid = "";

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // 📥 ૧. એપ ખુલે એટલે મેમરીમાંથી જૂના સેટિંગ્સ પાછા લાવો
  void _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) uid = user.uid;

    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
      isPrivateProfile = prefs.getBool('isPrivateProfile') ?? false;
      isNotificationOn = prefs.getBool('isNotificationOn') ?? true;
      showActiveStatus = prefs.getBool('showActiveStatus') ?? true;
    });
  }

  // 💾 ૨. સેટિંગ્સ ને ફોનની મેમરી અને ડેટાબેઝ બંનેમાં સેવ કરવાનું લોજીક
  void _saveSetting(String key, bool value, {bool updateFirebase = false}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);

    // જો એવું સેટિંગ હોય જે બીજાને દેખાડવાનું છે (જેમ કે Active Status), તો ડેટાબેઝમાં પણ સેવ કરો
    if (updateFirebase && uid.isNotEmpty) {
      await FirebaseFirestore.instance.collection('employees').doc(uid).set({
        key: value
      }, SetOptions(merge: true)); // merge: true થી જૂનો ડેટા ઉડશે નહિ
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Settings", style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, elevation: 1, iconTheme: const IconThemeData(color: Colors.black)),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          _sectionTitle("Appearance"),
          SwitchListTile(
            title: const Text("Dark Theme"), 
            value: isDarkMode, 
            onChanged: (val) {
              setState(() => isDarkMode = val);
              _saveSetting('isDarkMode', val);
            }, 
            secondary: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode)
          ),
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
              _saveSetting('showActiveStatus', val, updateFirebase: true); // 👈 સીધું બોસના ફોનમાં પણ અપડેટ થશે!
              
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(val ? "Your active status is now Visible 🟢" : "Your active status is now Hidden 👻"),
                behavior: SnackBarBehavior.floating,
              ));
            },
            secondary: const Icon(Icons.visibility),
          ),
          SwitchListTile(
            title: const Text("Private Profile"), 
            subtitle: const Text("Only followed colleagues can chat"), 
            value: isPrivateProfile, 
            onChanged: (val) {
              setState(() => isPrivateProfile = val);
              _saveSetting('isPrivateProfile', val, updateFirebase: true);
            }, 
            secondary: const Icon(Icons.lock_outline)
          ),
          const Divider(),
          
          _sectionTitle("Notifications"),
          SwitchListTile(
            title: const Text("Enable Notifications"), 
            value: isNotificationOn, 
            onChanged: (val) {
              setState(() => isNotificationOn = val);
              _saveSetting('isNotificationOn', val);
            }, 
            secondary: const Icon(Icons.notifications_none)
          ),
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