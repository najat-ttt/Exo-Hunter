import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/welcome_page.dart';

import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Firebase initialization error: $e');
  }

  runApp(const ExoHunterApp());
}

class ExoHunterApp extends StatelessWidget {
  const ExoHunterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exo-Hunter',
      theme: AppTheme.darkTheme,
      home: const InitializationWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class InitializationWrapper extends StatefulWidget {
  const InitializationWrapper({super.key});

  @override
  State<InitializationWrapper> createState() => _InitializationWrapperState();
}

class _InitializationWrapperState extends State<InitializationWrapper> {
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkInitialization();
  }

  Future<void> _checkInitialization() async {
    // Wait a moment to ensure Firebase is fully initialized
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return Scaffold(
        backgroundColor: AppTheme.midnightBlue,
        body: const Center(
          child: CircularProgressIndicator(
            color: AppTheme.nebulaCyan,
          ),
        ),
      );
    }

    return const WelcomePage();
  }
}