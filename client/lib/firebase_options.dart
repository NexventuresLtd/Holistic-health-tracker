// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCrsqKv9fX0wZrmJjslwfLwkPm8pX0GZ2w',
    appId: '1:665235690598:web:8fe6e93468722da04d09a7',
    messagingSenderId: '665235690598',
    projectId: 'holistic-health-tracker-e9121',
    authDomain: 'holistic-health-tracker-e9121.firebaseapp.com',
    storageBucket: 'holistic-health-tracker-e9121.firebasestorage.app',
    measurementId: 'G-0V37JJRP82',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDNvkPipWNI0aOPFFfOyxmB132NsqYRqCY',
    appId: '1:665235690598:android:5fec9ee0e304519f4d09a7',
    messagingSenderId: '665235690598',
    projectId: 'holistic-health-tracker-e9121',
    storageBucket: 'holistic-health-tracker-e9121.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyALNKhoPDpP-JKt2Q-BDktoIKhVu8jxOLQ',
    appId: '1:665235690598:ios:6ee83dd45838772d4d09a7',
    messagingSenderId: '665235690598',
    projectId: 'holistic-health-tracker-e9121',
    storageBucket: 'holistic-health-tracker-e9121.firebasestorage.app',
    iosBundleId: 'com.example.client',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyALNKhoPDpP-JKt2Q-BDktoIKhVu8jxOLQ',
    appId: '1:665235690598:ios:6ee83dd45838772d4d09a7',
    messagingSenderId: '665235690598',
    projectId: 'holistic-health-tracker-e9121',
    storageBucket: 'holistic-health-tracker-e9121.firebasestorage.app',
    iosBundleId: 'com.example.client',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCrsqKv9fX0wZrmJjslwfLwkPm8pX0GZ2w',
    appId: '1:665235690598:web:2a790802d981783a4d09a7',
    messagingSenderId: '665235690598',
    projectId: 'holistic-health-tracker-e9121',
    authDomain: 'holistic-health-tracker-e9121.firebaseapp.com',
    storageBucket: 'holistic-health-tracker-e9121.firebasestorage.app',
    measurementId: 'G-8TTRMHEWTV',
  );

}