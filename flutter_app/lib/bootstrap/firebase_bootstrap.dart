import 'package:firebase_core/firebase_core.dart';
import '../firebase/firebase_options.dart';

class FirebaseBootstrap {
  static Future<bool> initialize() async {
    if (DefaultFirebaseOptions.isPlaceholder) return false;
    try {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
      return true;
    } catch (_) {
      return false;
    }
  }
}
