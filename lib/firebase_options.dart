// Generated from your google-services.json — BreatheQuest
// Run `dart run flutterfire configure` to regenerate when Firebase CLI is installed.
// For web: add a Web app in Firebase Console and set the web appId below.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    return android;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCOFuHNyZYDzbMbxCwMBaMN9am7kvHdk1k',
    appId: '1:331617273791:android:12dafa37ea97ad75efc30a',
    messagingSenderId: '331617273791',
    projectId: 'breathequest-62385',
    storageBucket: 'breathequest-62385.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCOCfQme-CFJ4J47PZ81OUynjkQlwIbDfY',
    appId: '1:331617273791:web:d8c04c57a9b92d12efc30a',
    messagingSenderId: '331617273791',
    projectId: 'breathequest-62385',
    authDomain: 'breathequest-62385.firebaseapp.com',
    storageBucket: 'breathequest-62385.firebasestorage.app',
    measurementId: 'G-9H8210WK6T',
  );
}
