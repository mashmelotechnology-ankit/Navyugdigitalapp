import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../models/subscription_model.dart';

class SubscriptionProvider with ChangeNotifier {
  CheckSubscriptionResponse? _subscriptionResponse;
  bool _isLoading = false;
  String? _errorMessage;

  CheckSubscriptionResponse? get subscriptionResponse => _subscriptionResponse;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Check if user has active subscription
  bool get hasActiveSubscription =>
      _subscriptionResponse?.data?.isActive ?? false;

  // Get user's current subscription data
  SubscriptionData? get currentSubscription => _subscriptionResponse?.data;

  Future<bool> checkSubscription() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        _errorMessage = 'No authentication token found';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final url = '$baseUrl/api/check_subscription';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      _isLoading = false;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _subscriptionResponse = CheckSubscriptionResponse.fromJson(data);

        // Save subscription status to SharedPreferences for quick access
        if (_subscriptionResponse?.data != null) {
          await prefs.setBool(
              'has_active_subscription', _subscriptionResponse!.data!.isActive);
        } else {
          await prefs.setBool('has_active_subscription', false);
        }

        notifyListeners();
        return _subscriptionResponse?.data?.isActive ?? false;
      } else {
        // Handle different status codes
        if (response.statusCode == 404) {
          // No subscription found
          _subscriptionResponse = CheckSubscriptionResponse(
            success: false,
            data: null,
            message: 'No subscription found',
          );
          await prefs.setBool('has_active_subscription', false);
        } else {
          _errorMessage =
              'Failed to check subscription: ${response.statusCode}';
        }

        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error checking subscription: $e';
      notifyListeners();
      return false;
    }
  }

  // Check cached subscription status without API call
  Future<bool> getCachedSubscriptionStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('has_active_subscription') ?? false;
    } catch (e) {
      return false;
    }
  }

  // Clear subscription data on logout
  void clearSubscriptionData() {
    _subscriptionResponse = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  // Force refresh subscription status
  Future<bool> refreshSubscriptionStatus() async {
    return await checkSubscription();
  }
}
