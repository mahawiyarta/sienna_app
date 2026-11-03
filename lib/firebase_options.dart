import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
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
    apiKey: 'AIzaSyCnkVc-xE-_3pd59KKzgQZ5rZ9frpWH5CE',
    appId: '1:407717150642:web:4a8d67c9e3a6bfe67a6eab',
    messagingSenderId: '407717150642',
    projectId: 'sienna-app-f4bbd',
    authDomain: 'sienna-app-f4bbd.firebaseapp.com',
    storageBucket: 'sienna-app-f4bbd.firebasestorage.app',
    measurementId: 'G-LT7FETVR9H',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDbTm0e_dmmYMKuFpmH_dDMmcDYgWYRNhI',
    appId: '1:407717150642:android:890715be66e378087a6eab',
    messagingSenderId: '407717150642',
    projectId: 'sienna-app-f4bbd',
    storageBucket: 'sienna-app-f4bbd.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCCI0WYSiGEXjMQRGMJ0B-kGxDU2_cRtYw',
    appId: '1:407717150642:ios:792824b8e1e9a3977a6eab',
    messagingSenderId: '407717150642',
    projectId: 'sienna-app-f4bbd',
    storageBucket: 'sienna-app-f4bbd.firebasestorage.app',
    iosBundleId: 'com.sienna.siennaApp',
  );
}
