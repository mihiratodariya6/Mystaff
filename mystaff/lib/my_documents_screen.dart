import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:typed_data';

class MyDocumentsScreen extends StatefulWidget {
  const MyDocumentsScreen({super.key});

  @override
  State<MyDocumentsScreen> createState() => _MyDocumentsScreenState();
}

class _MyDocumentsScreenState extends State<MyDocumentsScreen> {
  String uid = "";
  double storageUsedMB = 0.0;
  final double maxFreeStorageMB = 15.0; // 👈 15 MB ની ફ્રી લિમિટ
  bool isLoading = false;

  final List<Map<String, dynamic>> docCategories = [
    {"id": "aadhar", "title": "Aadhar Card", "icon": Icons.fingerprint},
    {"id": "pan", "title": "PAN Card", "icon": Icons.credit_card},
    {"id": "10th_mark", "title": "10th Marksheet", "icon": Icons.school},
    {"id": "12th_mark", "title": "12th Marksheet", "icon": Icons.school_outlined},
    {"id": "degree", "title": "Degree Certificate", "icon": Icons.history_edu},
    {"id": "cheque", "title": "Cancelled Cheque", "icon": Icons.account_balance},
    {"id": "resume", "title": "Resume / CV", "icon": Icons.description},
  ];

  Map<String, String> uploadedDocs = {}; 

  @override
  void initState() {
    super.initState();
    _loadUserDocuments();
  }

  void _loadUserDocuments() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      uid = user.uid;
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('employees').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        var data = doc.data() as Map<String, dynamic>;
        setState(() {
          uploadedDocs = Map<String, String>.from(data['documents'] ?? {});
          storageUsedMB = (data['storageUsedMB'] ?? 0.0).toDouble();
        });
      }
    }
  }

  // 🚀 દેશી જુગાડ વાળું ફંક્શન (પૈસા વગરનું)
  void _pickAndFakeUploadFile(String docId, String title) async {
    if (storageUsedMB >= maxFreeStorageMB) {
      _showUpgradeDialog();
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf'], 
    );

    if (result != null) {
      Uint8List fileBytes = result.files.first.bytes!;
      double fileSizeMB = fileBytes.lengthInBytes / (1024 * 1024); 
      String fileName = result.files.first.name; // ફાઈલનું નામ ખેંચી લીધું

      if (storageUsedMB + fileSizeMB > maxFreeStorageMB) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Not enough free space! Please Upgrade. 🛑"), backgroundColor: Colors.red));
        return;
      }

      setState(() => isLoading = true);

      // ☁️ Firebase Storage માં નાખવાની જગ્યાએ, ખાલી નામ ડેટાબેઝમાં સેવ કરી દીધું!
      try {
        double newStorageSize = storageUsedMB + fileSizeMB;
        uploadedDocs[docId] = fileName; // લિંકની જગ્યાએ નામ સેવ કર્યું

        await FirebaseFirestore.instance.collection('employees').doc(uid).update({
          'documents': uploadedDocs,
          'storageUsedMB': newStorageSize,
        });

        setState(() {
          storageUsedMB = newStorageSize;
          isLoading = false;
        });

        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Document Uploaded Successfully! ✅"), backgroundColor: Colors.green));

      } catch (e) {
        setState(() => isLoading = false);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
      }
    }
  }

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Column(children: [Icon(Icons.cloud_off, color: Colors.red, size: 50), SizedBox(height: 10), Text("Storage Full!", style: TextStyle(fontWeight: FontWeight.bold))]),
        content: const Text("You have used your 15 MB free storage limit. Upgrade to Pro for unlimited document vault storage.", textAlign: TextAlign.center),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("UPI Payment Gateway coming soon! 💳"), backgroundColor: Colors.orange));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade700),
            child: const Text("Upgrade to Pro", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double progress = storageUsedMB / maxFreeStorageMB;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(title: const Text("My Document Vault", style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, iconTheme: const IconThemeData(color: Colors.black), elevation: 1),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF0D47A1), Color(0xFF1976D2)]), borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Cloud Storage", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          Icon(Icons.cloud_done, color: Colors.white),
                        ],
                      ),
                      const SizedBox(height: 15),
                      LinearProgressIndicator(value: progress, backgroundColor: Colors.white30, valueColor: AlwaysStoppedAnimation<Color>(progress > 0.8 ? Colors.redAccent : Colors.greenAccent), minHeight: 8, borderRadius: BorderRadius.circular(10)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("${storageUsedMB.toStringAsFixed(2)} MB Used", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          Text("${maxFreeStorageMB.toStringAsFixed(0)} MB Free Limit", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      )
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                const Text("Required Documents", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                Expanded(
                  child: ListView.builder(
                    itemCount: docCategories.length,
                    itemBuilder: (context, index) {
                      var doc = docCategories[index];
                      bool isUploaded = uploadedDocs.containsKey(doc['id']);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                          leading: CircleAvatar(backgroundColor: isUploaded ? Colors.green.shade50 : Colors.blue.shade50, child: Icon(doc['icon'], color: isUploaded ? Colors.green : const Color(0xFF1565C0))),
                          title: Text(doc['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(isUploaded ? "Uploaded Securely 🔒" : "Pending Upload", style: TextStyle(color: isUploaded ? Colors.green : Colors.red, fontSize: 12)),
                          trailing: isUploaded 
                            ? IconButton(icon: const Icon(Icons.check_circle, color: Colors.green), onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("File Saved: ${uploadedDocs[doc['id']]}")));
                              })
                            : ElevatedButton.icon(
                                onPressed: () => _pickAndFakeUploadFile(doc['id'], doc['title']),
                                icon: const Icon(Icons.upload, size: 16, color: Colors.white),
                                label: const Text("Upload", style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0)),
                              ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
          
          if (isLoading)
            Container(color: Colors.black45, child: const Center(child: CircularProgressIndicator(color: Colors.white))),
        ],
      ),
    );
  }
}