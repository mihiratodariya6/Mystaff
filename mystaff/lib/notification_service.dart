import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // ૧. પરમિશન માંગો
    await _messaging.requestPermission();

    // ૨. એન્ડ્રોઇડ સેટિંગ્સ
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: androidSettings);
    
    // ૩. ઇનિશિયલાઈઝ કરો
    await _localNotifications.initialize(initSettings);

    // ૪. ફોરગ્રાઉન્ડ મેસેજ સાંભળો
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
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'mystaff_channel', 
      'MyStaff Notifications',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    
    const NotificationDetails details = NotificationDetails(android: androidDetails);

    // 🚀 અહીં જાદુ છે - બધું એકદમ ચોકસાઈથી લખ્યું છે
    _localNotifications.show(
      DateTime.now().millisecond, // ID
      message.notification?.title ?? "New Notification", // Title
      message.notification?.body ?? "", // Body
      details, // NotificationDetails
    );
  }
}