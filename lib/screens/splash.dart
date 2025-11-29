// ignore_for_file: use_build_context_synchronously

import 'package:academy_lms_app/screens/login.dart';
import 'package:academy_lms_app/screens/subscription_check_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isLoggedIn = false;
  @override
  void initState() {
    _checkAuthStatus();
    super.initState();
  }

  Future<void> _checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = (prefs.getString('access_token') ?? '');

    setState(() {
      isLoggedIn = token.isNotEmpty;
    });
    if (isLoggedIn) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const SubscriptionCheckScreen()));
    } else {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
