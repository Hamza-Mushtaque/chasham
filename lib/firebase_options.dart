// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDeh9BqJIp076MdwriYoiyXu5S5K91ASnY',
    appId: '1:11290112003:web:c878e5fb8bfefb4fc01e36',
    messagingSenderId: '11290112003',
    projectId: 'chasham-fyp',
    authDomain: 'chasham-fyp.firebaseapp.com',
    storageBucket: 'chasham-fyp.appspot.com',
    measurementId: 'G-R56HTNCSQT',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCK2QDWSCOGjT00LINsFTgFL34XOdlJd1s',
    appId: '1:11290112003:android:6a1455c78750e3c5c01e36',
    messagingSenderId: '11290112003',
    projectId: 'chasham-fyp',
    storageBucket: 'chasham-fyp.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCuxKEDf91tN9N9xFFpARtGbRWIrRfTWko',
    appId: '1:11290112003:ios:6faf47473bf4f5bfc01e36',
    messagingSenderId: '11290112003',
    projectId: 'chasham-fyp',
    storageBucket: 'chasham-fyp.appspot.com',
    iosClientId: '11290112003-h057efh0366a5n3aruhmcjq9lu4u7ve4.apps.googleusercontent.com',
    iosBundleId: 'com.example.chashamFyp',
  );
}
