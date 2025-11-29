import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../models/user_data_model.dart';
import '../providers/subscription_provider.dart';
import 'login.dart';
import 'payment_charge_screen.dart';
import 'subscription_plans.dart';
import 'tab_screen.dart';

class SubscriptionCheckScreen extends StatefulWidget {
  const SubscriptionCheckScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionCheckScreen> createState() =>
      _SubscriptionCheckScreenState();
}

class _SubscriptionCheckScreenState extends State<SubscriptionCheckScreen> {
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure the call happens after the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkSubscriptionAndNavigate();
      }
    });
  }

  Future<void> _checkSubscriptionAndNavigate() async {
    try {
      final subscriptionProvider =
          Provider.of<SubscriptionProvider>(context, listen: false);

      // Check if user is logged in
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        // User not logged in, go to login screen
        _navigateToLogin();
        return;
      }

      // First, check if payment charge is required by calling /api/userData
      final userData = await _fetchUserData(token);

      if (mounted && userData != null) {
        // Check if payment charge is required
        if (userData.data.takeCharge == 1) {
          // Payment charge is required, navigate to payment screen
          _navigateToPaymentCharge(userData.data);
          return;
        }
      }

      // User is logged in and no payment charge required, check subscription
      final hasActiveSubscription =
          await subscriptionProvider.checkSubscription();

      if (mounted) {
        if (hasActiveSubscription) {
          // User has active subscription, go to home
          _navigateToHome();
        } else {
          // User doesn't have active subscription, go to subscription plans
          _navigateToSubscriptionPlans();
        }
      }
    } catch (e) {
      // On error, navigate to login to be safe
      if (mounted) {
        _navigateToLogin();
      }
    }
  }

  Future<UserData?> _fetchUserData(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/userData'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return UserData.fromJson(jsonData);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      return null;
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _navigateToPaymentCharge(UserDataInfo userData) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PaymentChargeScreen(userData: userData),
      ),
    );
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const TabsScreen(pageIndex: 0)),
    );
  }

  void _navigateToSubscriptionPlans() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SubscriptionPlansScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: kDefaultColor.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Loading indicator
            const CircularProgressIndicator(
              color: kDefaultColor,
              strokeWidth: 3,
            ),

            const SizedBox(height: 24),

            // Loading text
            const Text(
              'Checking profile status...',
              style: TextStyle(
                fontSize: 16,
                color: kTextColor,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Text(
              'Please wait while we verify your account',
              style: TextStyle(
                fontSize: 14,
                color: kTextColor.withOpacity(0.6),
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
