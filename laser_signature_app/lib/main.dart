import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'signature_page.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase connection
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Start the app
  runApp(const LaserSignatureApp());
}

class LaserSignatureApp extends StatelessWidget {
  const LaserSignatureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laser Signature Machine',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00B4D8),
          surface: Color(0xFF0A1628),
        ),
        scaffoldBackgroundColor: const Color(0xFF060F1E),
        useMaterial3: true,
      ),
      home: const SignaturePage(),
    );
  }
}