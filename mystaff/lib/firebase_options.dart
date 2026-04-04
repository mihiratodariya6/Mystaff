// File generated manually to fix Firebase connection
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Not configured for web.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError('Not configured for ios.');
      case TargetPlatform.macOS:
        throw UnsupportedError('Not configured for macos.');
      case TargetPlatform.windows:
        throw UnsupportedError('Not configured for windows.');
      case TargetPlatform.linux:
        throw UnsupportedError('Not configured for linux.');
      default:
        throw UnsupportedError('Not supported for this platform.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDe_JE6wkeg-Vhv_waAmD18LniEKN2OcRg',
    appId: '1:114587188132:android:09aadb5d281f42a88e1f31',
    messagingSenderId: '114587188132',
    projectId: 'mystaff-f7b12',
    storageBucket: 'mystaff-f7b12.firebasestorage.app',
  );
}