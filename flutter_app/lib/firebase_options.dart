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
    apiKey: 'AIzaSyBeELZ7Eg7hw484RAJr4qFqlfJZuFxLvGU',
    appId: '1:48527931947:web:c2344e4f62dfd89b05486e',
    messagingSenderId: '48527931947',
    projectId: 'web-vulnerablity-db',
    authDomain: 'web-vulnerablity-db.firebaseapp.com',
    databaseURL: 'https://web-vulnerablity-db-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'web-vulnerablity-db.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBXROKzOi9V9d8-OIIpHKZAOdCbV3s9LjM',
    appId: '1:48527931947:android:692be33c60d3445805486e',
    messagingSenderId: '48527931947',
    projectId: 'web-vulnerablity-db',
    databaseURL: 'https://web-vulnerablity-db-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'web-vulnerablity-db.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCqPFw9ep8jSUNzB7pYDoLkwsrUywSawo4',
    appId: '1:48527931947:ios:9cf961bcad30b08205486e',
    messagingSenderId: '48527931947',
    projectId: 'web-vulnerablity-db',
    databaseURL: 'https://web-vulnerablity-db-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'web-vulnerablity-db.firebasestorage.app',
    iosClientId: '48527931947-fi1d12mvdi1pjfueepv4eielm1i8n6n6.apps.googleusercontent.com',
    iosBundleId: 'com.example.flutterApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCqPFw9ep8jSUNzB7pYDoLkwsrUywSawo4',
    appId: '1:48527931947:ios:9cf961bcad30b08205486e',
    messagingSenderId: '48527931947',
    projectId: 'web-vulnerablity-db',
    databaseURL: 'https://web-vulnerablity-db-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'web-vulnerablity-db.firebasestorage.app',
    iosClientId: '48527931947-fi1d12mvdi1pjfueepv4eielm1i8n6n6.apps.googleusercontent.com',
    iosBundleId: 'com.example.flutterApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBeELZ7Eg7hw484RAJr4qFqlfJZuFxLvGU',
    appId: '1:48527931947:web:31e8918ac73e700405486e',
    messagingSenderId: '48527931947',
    projectId: 'web-vulnerablity-db',
    authDomain: 'web-vulnerablity-db.firebaseapp.com',
    databaseURL: 'https://web-vulnerablity-db-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'web-vulnerablity-db.firebasestorage.app',
  );
}
