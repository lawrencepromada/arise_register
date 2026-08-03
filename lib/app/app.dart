import 'package:flutter/material.dart';
import '../screens/splash/splash_screen.dart';

class AriseRegisterApp extends StatelessWidget {
  const AriseRegisterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arise Register',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}