// ignore_for_file: use_build_context_synchronously

import 'package:academy_lms_app/screens/login.dart';
import 'package:academy_lms_app/screens/subscription_check_screen.dart';
import 'package:academy_lms_app/services/version_check_service.dart';
import 'package:academy_lms_app/widgets/force_update_dialog.dart';
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
    // Check for app updates first
    await _checkForUpdate();

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

  Future<void> _checkForUpdate() async {
    try {
      final updateInfo = await VersionCheckService.checkForUpdate();

      if (updateInfo['needs_update'] == true) {
        bool isForceUpdate = updateInfo['force_update'] == true;
        String updateUrl = updateInfo['update_url'] ?? '';

        // Show update dialog
        showDialog(
          context: context,
          barrierDismissible: !isForceUpdate,
          builder: (BuildContext context) => ForceUpdateDialog(
            currentVersion: updateInfo['current_version'] ?? '1.0.0',
            latestVersion: updateInfo['latest_version'] ?? '1.0.0',
            message: updateInfo['update_message'] ??
                'A new version of the app is available. Please update to continue.',
            updateUrl: updateUrl,
            isForceUpdate: isForceUpdate,
          ),
        );

        // If force update, don't proceed with login check
        if (isForceUpdate) {
          return;
        }
      }
    } catch (e) {
      print('Version check error: $e');
      // Continue with normal flow even if version check fails
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
