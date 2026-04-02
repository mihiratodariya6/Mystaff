import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // ૧. પરમિશન માંગો
    await _messaging.requestPermission();

    // ૨. એપ ચાલુ હોય ત્યારે મેસેજ આવે તો ખાલી પ્રિન્ટ કરશે (એરર નહિ આપે)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("🔔 New Message Received: ${message.notification?.title}");
    });
  }

  // 🚀 આ સૌથી જરૂરી ફંક્શન છે, જે બોસનો ટોકન સેવ કરશે
  static Future<void> updateTokenInFirestore() async {
    try {
      String? token = await _messaging.getToken();
      User? user = FirebaseAuth.instance.currentUser;
      
      if (token != null && user != null) {
        await FirebaseFirestore.instance.collection('users_tokens').doc(user.uid).set({
          'fcmToken': token,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        print("✅ Token Saved Successfully!");
      }
    } catch (e) {
      print("Token Error: $e");
    }
  }
}