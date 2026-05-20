import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      home: const SplashScreen(),
    );
  }
}
