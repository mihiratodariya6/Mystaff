import 'package:flutter/material.dart';

class MyDocumentsScreen extends StatelessWidget {
  const MyDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(title: const Text("My Documents", style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, elevation: 1, iconTheme: const IconThemeData(color: Colors.black)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildDocCard("Aadhar Card", "Updated on 12 Jan 2026", Icons.contact_page, Colors.blue),
          _buildDocCard("PAN Card", "Updated on 12 Jan 2026", Icons.credit_card, Colors.orange),
          _buildDocCard("Offer Letter", "Received on 01 Feb 2026", Icons.description, Colors.green),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Opening File Manager to upload... 📂")));
        },
        backgroundColor: const Color(0xFF1565C0),
        icon: const Icon(Icons.upload_file, color: Colors.white),
        label: const Text("Upload New", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildDocCard(String title, String subtitle, IconData icon, Color color) {
    return Card(
      elevation: 0, margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.download_rounded, color: Colors.grey),
        onTap: () {},
      ),
    );
  }
}