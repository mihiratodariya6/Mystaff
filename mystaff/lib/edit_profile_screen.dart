import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // 👈 આ ઈમ્પોર્ટ એડ કર્યું
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController nameController = TextEditingController(text: "Mihir Atodariya");
  final TextEditingController titleController = TextEditingController(text: "Flutter Developer 🚀");
  final TextEditingController bioController = TextEditingController(text: "ID: EMP-007 | Surat, India");
  File? _image;
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    // હવે ImageSource.gallery ની એરર નહિ આવે
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _image = File(pickedFile.path));
  }

  void _saveProfile() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile updated successfully! ✅")));
    Navigator.pop(context); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Edit Profile", style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, elevation: 1, iconTheme: const IconThemeData(color: Colors.black), actions: [IconButton(onPressed: _saveProfile, icon: const Icon(Icons.check, color: Color(0xFF1565C0)))]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300, width: 2)),
                  child: CircleAvatar(radius: 50, backgroundColor: Colors.grey.shade100, backgroundImage: _image != null ? FileImage(_image!) : null, child: _image == null ? const Icon(Icons.person, size: 60, color: Colors.grey) : null),
                ),
              ),
            ),
            TextButton(onPressed: _pickImage, child: const Text("Change Profile Photo")),
            const SizedBox(height: 20),
            _buildEditField("Name", nameController),
            _buildEditField("Job Title", titleController),
            _buildEditField("Bio / Location", bioController),
          ],
        ),
      ),
    );
  }

  Widget _buildEditField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(controller: controller, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder())),
    );
  }
}