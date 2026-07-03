// lib/firebase_options.dart
// TODO: Replace this file by running: flutterfire configure
// See: https://firebase.google.com/docs/flutter/setup
//
// Steps:
//   1. Install FlutterFire CLI: dart pub global activate flutterfire_cli
//   2. Create a Firebase project at https://console.firebase.google.com
//   3. Run: flutterfire configure
//   4. Delete this file — it will be auto-generated.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web. '
        'Reconfigure your app using the FlutterFire CLI.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // TODO: Replace with your actual Android Firebase config

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBO8ZcHBCOS92GOgTG21QcHi11jJQaUldo',
    appId: '1:71816434288:android:29ab4060ec3e1a86ad9ab5',
    messagingSenderId: '71816434288',
    projectId: 'noted-84dd0',
    storageBucket: 'noted-84dd0.firebasestorage.app',
  );
  // TODO: Replace with your actual iOS Firebase config

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD-q6v_W9tRlHsRvulcbMgxXAAm38Yfvhc',
    appId: '1:71816434288:ios:644524f45aa7de70ad9ab5',
    messagingSenderId: '71816434288',
    projectId: 'noted-84dd0',
    storageBucket: 'noted-84dd0.firebasestorage.app',
    iosBundleId: 'com.noted.noted',
  );
}
