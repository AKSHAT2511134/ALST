import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for iOS.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macOS.',
        );
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  /// Web Firebase config
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDHazL6gRJPZXgv-iIlcNFG9RZ8SXXeDPY',
    appId: '1:437481099478:web:000000000000000000000000',
    messagingSenderId: '437481099478',
    projectId: 'laser-signature-machine',
    storageBucket: 'laser-signature-machine.firebasestorage.app',
    authDomain: 'laser-signature-machine.firebaseapp.com',
    databaseURL: 'https://laser-signature-machine-default-rtdb.firebaseio.com',
  );

  /// Android Firebase config
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDHazL6gRJPZXgv-iIlcNFG9RZ8SXXeDPY',
    appId: '1:437481099478:android:078cbdabeee2cc27b9f977',
    messagingSenderId: '437481099478',
    projectId: 'laser-signature-machine',
    storageBucket: 'laser-signature-machine.firebasestorage.app',
    databaseURL: 'https://laser-signature-machine-default-rtdb.firebaseio.com',
  );

  /// Windows Firebase config (uses web SDK under the hood)
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDHazL6gRJPZXgv-iIlcNFG9RZ8SXXeDPY',
    appId: '1:437481099478:web:000000000000000000000000',
    messagingSenderId: '437481099478',
    projectId: 'laser-signature-machine',
    storageBucket: 'laser-signature-machine.firebasestorage.app',
    authDomain: 'laser-signature-machine.firebaseapp.com',
    databaseURL: 'https://laser-signature-machine-default-rtdb.firebaseio.com',
  );
}
