import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase failed to initialize: $e');
  }
  runApp(const HunarLinkApp());
}

class HunarLinkApp extends StatelessWidget {
  const HunarLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HunarLink',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF006053),
          primary: const Color(0xFF006053),
        ),
        useMaterial3: true,
        fontFamily: 'Plus Jakarta Sans',
      ),
      home: const HomeScreen(),
    );
  }
}
