import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 👈 ડેટાબેઝ માટે
import 'package:firebase_auth/firebase_auth.dart';    // 👈 યુઝર ID માટે
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  
  File? _image;
  final picker = ImagePicker();
  bool isLoading = true; // ડેટા લોડ થતી વખતે Spinner બતાવવા
  bool isSaving = false; // સેવ કરતી વખતે લોડીંગ બતાવવા

  @override
  void initState() {
    super.initState();
    _loadUserData(); // એપ ખુલતા જ ડેટા લાવશે
  }

  // 📥 ફાયરબેઝમાંથી જૂનો ડેટા લાવવાનું ફંક્શન
  void _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('employees').doc(user.uid).get();
      if (doc.exists && mounted) {
        setState(() {
          nameController.text = doc['name'] ?? "";
          titleController.text = doc['role'] ?? "";
          bioController.text = doc['email'] ?? ""; // અથવા જે પણ ફિલ્ડ રાખવું હોય
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _image = File(pickedFile.path));
  }

  // 🚀 પ્રોફાઇલ સેવ કરવાનું અસલી લોજીક
  void _saveProfile() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Name cannot be empty!"), backgroundColor: Colors.red));
      return;
    }

    setState(() => isSaving = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('employees').doc(user.uid).update({
          'name': nameController.text.trim(),
          'role': titleController.text.trim(),
          // અહીં તમે બીજા ફિલ્ડ પણ અપડેટ કરી શકો
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile updated successfully! ✅"), backgroundColor: Colors.green));
          Navigator.pop(context); 
        }
      }
    } catch (e) {
      setState(() => isSaving = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Edit Profile", style: TextStyle(color: Colors.black)), 
        backgroundColor: Colors.white, 
        elevation: 1, 
        iconTheme: const IconThemeData(color: Colors.black), 
        actions: [
          isSaving 
            ? const Padding(padding: EdgeInsets.all(15), child: CircularProgressIndicator(strokeWidth: 2))
            : IconButton(onPressed: _saveProfile, icon: const Icon(Icons.check, color: Color(0xFF1565C0)))
        ]
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator()) // ડેટા લોડ થાય ત્યાં સુધી
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300, width: 2)),
                      child: CircleAvatar(
                        radius: 50, 
                        backgroundColor: Colors.grey.shade100, 
                        backgroundImage: _image != null ? FileImage(_image!) : null, 
                        child: _image == null ? const Icon(Icons.person, size: 60, color: Colors.grey) : null
                      ),
                    ),
                  ),
                ),
                TextButton(onPressed: _pickImage, child: const Text("Change Profile Photo")),
                const SizedBox(height: 20),
                _buildEditField("Full Name", nameController, Icons.person),
                _buildEditField("Job Role", titleController, Icons.work),
                _buildEditField("Bio / Other Info", bioController, Icons.info_outline),
              ],
            ),
          ),
    );
  }

  Widget _buildEditField(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller, 
        decoration: InputDecoration(
          labelText: label, 
          prefixIcon: Icon(icon, color: const Color(0xFF1565C0)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2)),
        )
      ),
    );
  }
}