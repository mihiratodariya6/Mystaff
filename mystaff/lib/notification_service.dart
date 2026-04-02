import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as local; // 👈 Alias વાપર્યો
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  
  // 🚀 આ લાઈન ખાસ ધ્યાનથી જોજો
  static final local.FlutterLocalNotificationsPlugin _localNotifications = local.FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    await _messaging.requestPermission();

    const local.AndroidInitializationSettings androidSettings = local.AndroidInitializationSettings('@mipmap/ic_launcher');
    const local.InitializationSettings initSettings = local.InitializationSettings(android: androidSettings);
    
    // ✅ હવે અહીં એરર નહીં આવે
    await _localNotifications.initialize(initSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });
  }

  static Future<void> updateTokenInFirestore() async {
    String? token = await _messaging.getToken();
    User? user = FirebaseAuth.instance.currentUser;
    if (token != null && user != null) {
      await FirebaseFirestore.instance.collection('users_tokens').doc(user.uid).set({
        'fcmToken': token,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
  }

  static void _showLocalNotification(RemoteMessage message) {
    const local.AndroidNotificationDetails androidDetails = local.AndroidNotificationDetails(
      'mystaff_channel', 
      'MyStaff Notifications',
      importance: local.Importance.max,
      priority: local.Priority.high,
    );
    const local.NotificationDetails details = local.NotificationDetails(android: androidDetails);

    // ✅ અહીં પણ 'local.' નો ઉપયોગ કર્યો છે
    _localNotifications.show(
      DateTime.now().millisecond,
      message.notification?.title ?? "New Message",
      message.notification?.body ?? "",
      details,
    );
  }
}