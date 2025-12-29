// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:academy_lms_app/screens/tab_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/subscription_plan.dart';
import '../models/subscription_models.dart';

class SubscriptionPlans with ChangeNotifier {
  List<SubscriptionPlan> _plans = [];
  CurrentSubscription? _currentSubscription;
  List<SubscriptionHistory> _subscriptionHistory = [];
  bool _isLoading = false;
  int? planIdSelected;
  List<SubscriptionPlan> get plans => [..._plans];
  CurrentSubscription? get currentSubscription => _currentSubscription;
  List<SubscriptionHistory> get subscriptionHistory =>
      [..._subscriptionHistory];
  bool get isLoading => _isLoading;
  late Razorpay _razorpay;
  BuildContext? ctx;
  Function(PaymentSuccessResponse)? _onSuccess;
  Function(PaymentFailureResponse)? _onError;
  Function(ExternalWalletResponse)? _onExternalWallet;

  SubscriptionPlans() {
    _initializeRazorpay();
  }

  void _initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  openCheckout({
    required BuildContext context,
    required double amount,
    required String name,
    required String description,
    required String contactNumber,
    required String email,
    required int planId,
    Function(PaymentSuccessResponse)? onSuccess,
    Function(PaymentFailureResponse)? onError,
    Function(ExternalWalletResponse)? onExternalWallet,
  }) async {
    // Store callbacks
    _onSuccess = onSuccess;
    _onError = onError;
    _onExternalWallet = onExternalWallet;
    planIdSelected = planId;
    ctx = context;
    var options = {
      'key': 'rzp_live_RlseC8GhaYiOYf', // Replace with your Razorpay key
      'amount': (amount * 100).toInt(), // Amount in paise
      'name': 'Navyug Digital',
      'description': description,
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {
        'contact': contactNumber,
        'email': email,
        'name': name,
      },
      'external': {
        'wallets': ['paytm']
      },
      'theme': {
        'color': '#054D8A' // Use your app's primary color
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      if (kDebugMode) {
        print('Error opening Razorpay: $e');
      }
      Fluttertoast.showToast(
        msg: 'Error opening payment gateway',
        backgroundColor: kRedColor,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  Future<bool> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (kDebugMode) {
      print('Payment Success: ${response.paymentId}');
    }
    await subscribeToPlan(planIdSelected ?? 0, 'razorpay',
        transactionId: response.paymentId);
    return true;
    // _onSuccess?.call(response);
  }

  Future<bool> _handlePaymentError(PaymentFailureResponse response) async {
    if (kDebugMode) {
      print('Payment Error: ${response.code} - ${response.message}');
    }

    String errorMessage = 'Payment failed';

    // Handle specific error codes
    switch (response.code) {
      case Razorpay.PAYMENT_CANCELLED:
        errorMessage = 'Payment cancelled by user';
        break;
      case Razorpay.NETWORK_ERROR:
        errorMessage = 'Network error occurred';
        break;

      case Razorpay.UNKNOWN_ERROR:
        errorMessage = 'An unknown error occurred';
        break;
      default:
        errorMessage = response.message ?? 'Payment failed';
    }

    Fluttertoast.showToast(
      msg: errorMessage,
      backgroundColor: kRedColor,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_LONG,
    );

    return false;
  }

  Future<bool> _handleExternalWallet(ExternalWalletResponse response) async {
    if (kDebugMode) {
      print('External Wallet: ${response.walletName}');
    }

    Fluttertoast.showToast(
      msg: 'External wallet selected: ${response.walletName}',
      backgroundColor: kBlueColor,
      textColor: Colors.white,
    );
    return true;
  }

  // Mock data for testing when API is not available
  List<SubscriptionPlan> get mockPlans => [
        SubscriptionPlan(
          id: 1,
          planName: 'Basic Plan',
          description: 'Perfect for individuals getting started',
          planPeriodDays: 30,
          noOfCourses: 5,
          noOfLiveClasses: 2,
          noOfWebinars: 1,
          noOfDiplomaCertificates: 1,
          mrp: 999.00,
          discountedPrice: 799.00,
          savings: 200.00,
          discountPercentage: 20.02,
          features: [
            '5 Courses Access',
            '2 Live Classes',
            '1 Webinar',
            'Basic Support',
          ],
        ),
        SubscriptionPlan(
          id: 2,
          planName: 'Premium Plan',
          description: 'Ideal for professionals seeking advanced features',
          planPeriodDays: 30,
          noOfCourses: 15,
          noOfLiveClasses: 5,
          noOfWebinars: 3,
          noOfDiplomaCertificates: 3,
          mrp: 1999.00,
          discountedPrice: 1499.00,
          savings: 500.00,
          discountPercentage: 25.01,
          features: [
            '15 Courses Access',
            '5 Live Classes',
            '3 Webinars',
            'Priority Support',
            '3 Certificates',
          ],
        ),
        SubscriptionPlan(
          id: 3,
          planName: 'Enterprise Plan',
          description: 'Complete solution for teams and organizations',
          planPeriodDays: 30,
          noOfCourses: 50,
          noOfLiveClasses: 15,
          noOfWebinars: 10,
          noOfDiplomaCertificates: 10,
          mrp: 3499.00,
          discountedPrice: 2499.00,
          savings: 1000.00,
          discountPercentage: 28.58,
          features: [
            'Unlimited Courses',
            '15 Live Classes',
            '10 Webinars',
            '24/7 Support',
            '10 Certificates',
            'Team Management',
          ],
        ),
      ];

  Future<void> fetchSubscriptionPlans() async {
    _isLoading = true;
    // Don't notify immediately, only notify when operation is complete

    try {
      const url = '$baseUrl/api/plans';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> plansData = responseData['data'];
          _plans = plansData
              .map((planJson) => SubscriptionPlan.fromJson(planJson))
              .toList();
        } else {
          // If API doesn't return expected format, use mock data
          _plans = mockPlans;
        }
      } else {
        // If API call fails, use mock data
        print('API call failed with status: ${response.statusCode}');
        _plans = mockPlans;
      }
    } catch (error) {
      // If any error occurs, use mock data
      print('Error fetching registration plans: $error');
      _plans = mockPlans;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<CurrentSubscription?> fetchCurrentSubscription() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('access_token') ?? '';
      print(authToken);
      const url = '$baseUrl/api/my_subscription';
      print(authToken);
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          _currentSubscription =
              CurrentSubscription.fromJson(responseData['data']);
          notifyListeners();
          return _currentSubscription;
        } else {
          _currentSubscription = null;
          notifyListeners();
          return null;
        }
      }
      return null;
    } catch (error) {
      print('Error fetching current subscription: $error');
      return null;
    }
  }

  Future<UpgradeCost?> calculateUpgradeCost(int planId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('access_token') ?? '';

      final url = '$baseUrl/api/get_upgrade_cost?plan_id=$planId';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      print(response.body);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          return UpgradeCost.fromJson(responseData['data']);
        }
      }
      return null;
    } catch (error) {
      print('Error calculating upgrade cost: ${error}');
      return null;
    }
  }

  Future<Map<String, dynamic>?> subscribeToPlan(
      int planId, String paymentMethod,
      {String? transactionId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('access_token') ?? '';

      const url = '$baseUrl/api/subscribe_plan';

      final requestBody = {
        'plan_id': planId,
        'payment_method': paymentMethod,
      };

      if (transactionId != null) {
        requestBody['transaction_id'] = transactionId;
      }
      print(requestBody);
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode(requestBody),
      );
      print("check1");
      print(response.body);
      if (response.statusCode == 200) {
        print("check2");
        final responseData = json.decode(response.body);
        print("check3");
        if (responseData['success'] == true) {
          print("check4");
          // Refresh current subscription after successful subscription
          await fetchCurrentSubscription();
          Navigator.of(ctx!).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => const TabsScreen(
                        pageIndex: 0,
                      )),
              (Route<dynamic> route) => false);

          return responseData['data'];
        }
      }
      print("check6");
      return null;
    } catch (error) {
      print('Error subscribing to plan: $error');
      return null;
    }
  }

  Future<void> fetchSubscriptionHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('access_token') ?? '';

      const url = '$baseUrl/api/subscription_history';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> historyData = responseData['data'];
          _subscriptionHistory = historyData
              .map((historyJson) => SubscriptionHistory.fromJson(historyJson))
              .toList();
          notifyListeners();
        }
      }
    } catch (error) {
      print('Error fetching subscription history: $error');
    }
  }

  // Helper method to check if user has active subscription
  bool hasActiveSubscription() {
    return _currentSubscription != null &&
        _currentSubscription!.isActive == true;
  }

  // Helper method to get remaining days
  int getRemainingDays() {
    return _currentSubscription?.remainingDays?.toInt() ?? 0;
  }

  // Helper method to check if subscription is expired
  bool isSubscriptionExpired() {
    if (_currentSubscription == null) return true;
    return _currentSubscription!.status == 'expired' || getRemainingDays() <= 0;
  }
}
