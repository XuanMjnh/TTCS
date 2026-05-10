import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_gate.dart';
import 'features/setup/firebase_setup_screen.dart';

class PlantDiseaseApp extends StatelessWidget {
  const PlantDiseaseApp({super.key, required this.firebaseReady});
  final bool firebaseReady;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriScan AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: firebaseReady ? const AuthGate() : const FirebaseSetupScreen(),
    );
  }
}
