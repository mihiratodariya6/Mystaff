import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // 🚀 ૧. નોટિફિકેશન સિસ્ટમ ચાલુ કરવી
  static Future<void> initialize() async {
    // પરમિશન માંગવી (iOS અને Android 13+)
    await _messaging.requestPermission();

    // Android માટે લોકલ નોટિફિકેશન સેટઅપ
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(initSettings);

    // જ્યારે એપ ચાલુ હોય ત્યારે મેસેજ આવે તો શું કરવું?
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });
  }

  // 🔑 ૨. ફોનનો FCM Token મેળવીને Firestore માં સેવ કરવો
  static Future<void> updateTokenInFirestore() async {
    String? token = await _messaging.getToken();
    User? user = FirebaseAuth.instance.currentUser;

    if (token != null && user != null) {
      // બોસ અને એમ્પ્લોઈ બંનેના કલેક્શનમાં ટોકન અપડેટ કરી દઈએ
      await FirebaseFirestore.instance.collection('users_tokens').doc(user.uid).set({
        'fcmToken': token,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      print("FCM Token Updated: $token");
    }
  }

  // 🔔 ૩. સ્ક્રીન પર નોટિફિકેશન બતાવવું
  static void _showLocalNotification(RemoteMessage message) {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'mystaff_channel', 'MyStaff Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails details = NotificationDetails(android: androidDetails);

    _localNotifications.show(
      DateTime.now().millisecond,
      message.notification?.title,
      message.notification?.body,
      details,
    );
  }
}