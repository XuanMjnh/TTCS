import 'package:flutter/material.dart';
import 'app.dart';
import 'bootstrap/firebase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firebaseReady = await FirebaseBootstrap.initialize();
  runApp(PlantDiseaseApp(firebaseReady: firebaseReady));
}
