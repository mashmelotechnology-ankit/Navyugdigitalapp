import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/user_data_model.dart';
import 'tab_screen.dart';

class PaymentChargeScreen extends StatefulWidget {
  final UserDataInfo userData;

  const PaymentChargeScreen({
    Key? key,
    required this.userData,
  }) : super(key: key);

  @override
  State<PaymentChargeScreen> createState() => _PaymentChargeScreenState();
}

class _PaymentChargeScreenState extends State<PaymentChargeScreen> {
  late Razorpay _razorpay;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
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

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    setState(() {
      _isProcessing = true;
    });

    // Store payment data to backend
    await _storePaymentData(
      transactionId: response.paymentId ?? '',
      paymentStatus: 'completed',
      gatewayResponse: response.toString(),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
      msg: "Payment failed: ${response.message}",
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
      msg: "External Wallet: ${response.walletName}",
      backgroundColor: Colors.blue,
      textColor: Colors.white,
    );
  }

  Future<void> _storePaymentData({
    required String transactionId,
    required String paymentStatus,
    required String gatewayResponse,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      final response = await http.post(
        Uri.parse('$baseUrl/api/payment_gateway_data/store'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'take_charge': widget.userData.amount,
          'amount': widget.userData.amount,
          'payment_gateway': 'razorpay',
          'transaction_id': transactionId,
          'payment_status': paymentStatus,
          'gateway_response': '{}',
        }),
      );

      setState(() {
        _isProcessing = false;
      });
      print('Store Payment Data Response: ${response.body}');
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          Fluttertoast.showToast(
            msg: "Payment successful! Welcome to the app",
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );

          // Navigate to home screen
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const TabsScreen(pageIndex: 0),
              ),
              (route) => false,
            );
          }
        } else {
          Fluttertoast.showToast(
            msg: data['message'] ?? 'Failed to store payment data',
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to verify payment',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      Fluttertoast.showToast(
        msg: 'Error: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  void _initiatePayment() {
    try {
      double amount = double.parse(widget.userData.amount);
      int amountInPaise = (amount * 100).toInt();

      var options = {
        'key': 'rzp_test_RSdtuJrYr1Hq8D', // Replace with your Razorpay key
        'amount': amountInPaise,
        'name': 'Academy LMS',
        'description': 'Registration Charge',
        'prefill': {
          'contact': widget.userData.phone,
          'email': widget.userData.email,
        },
        'theme': {
          'color': '#${kDefaultColor.value.toRadixString(16).substring(2, 8)}'
        }
      };

      _razorpay.open(options);
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error initiating payment: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back button
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        body: SafeArea(
          child: _isProcessing
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: kDefaultColor),
                      const SizedBox(height: 20),
                      Text(
                        'Processing payment...',
                        style: TextStyle(
                          fontSize: 16,
                          color: kTextColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),

                        // App Logo
                        Container(
                          width: 100,
                          height: 100,
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

                        // Title
                        const Text(
                          'Registration Charge',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: kTextColor,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 12),

                        // Subtitle
                        Text(
                          'Complete your payment to access the app',
                          style: TextStyle(
                            fontSize: 14,
                            color: kGreyLightColor,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 40),

                        // Payment Details Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // User Info
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor:
                                        kDefaultColor.withOpacity(0.1),
                                    backgroundImage: widget.userData.photo !=
                                                null &&
                                            widget.userData.photo!.isNotEmpty
                                        ? NetworkImage(
                                            '${widget.userData.photo}')
                                        : null,
                                    child: widget.userData.photo == null ||
                                            widget.userData.photo!.isEmpty
                                        ? Text(
                                            widget.userData.name
                                                .substring(0, 1)
                                                .toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w600,
                                              color: kDefaultColor,
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.userData.name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: kTextColor,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          widget.userData.phone,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: kGreyLightColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),

                              // Divider
                              Divider(
                                color: kGreyLightColor.withOpacity(0.2),
                                thickness: 1,
                              ),

                              const SizedBox(height: 24),

                              // Amount Display
                              const Text(
                                'Amount to Pay',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: kGreyLightColor,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '₹${widget.userData.amount}',
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w700,
                                  color: kDefaultColor,
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Features List
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: kDefaultColor.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    _buildFeatureItem(
                                      icon: Icons.school_outlined,
                                      text: 'Access to all courses',
                                    ),
                                    const SizedBox(height: 12),
                                    _buildFeatureItem(
                                      icon: Icons.video_library_outlined,
                                      text: 'Live classes & webinars',
                                    ),
                                    const SizedBox(height: 12),
                                    _buildFeatureItem(
                                      icon: Icons.card_membership_outlined,
                                      text: 'Certificates & diplomas',
                                    ),
                                    const SizedBox(height: 12),
                                    _buildFeatureItem(
                                      icon: Icons.support_agent_outlined,
                                      text: '24/7 support',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Pay Now Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _initiatePayment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kDefaultColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.payment,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Pay Now',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Secure Payment Text
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lock_outline,
                              size: 16,
                              color: kGreyLightColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Secure payment powered by Razorpay',
                              style: TextStyle(
                                fontSize: 12,
                                color: kGreyLightColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: kDefaultColor,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: kTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Icon(
          Icons.check_circle,
          size: 20,
          color: kGreenColor,
        ),
      ],
    );
  }
}
