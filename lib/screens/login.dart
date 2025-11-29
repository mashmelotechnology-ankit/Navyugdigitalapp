// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'dart:async';

import 'package:academy_lms_app/constants.dart';
import 'package:academy_lms_app/screens/signup.dart';
import 'package:academy_lms_app/screens/subscription_check_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isLoading = false;
  bool _isOtpSent = false;
  bool _isResendEnabled = false;
  int _resendTimer = 60;
  Timer? _timer;
  String? token;

  SharedPreferences? sharedPreferences;
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _timer?.cancel();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void startResendTimer() {
    setState(() {
      _isResendEnabled = false;
      _resendTimer = 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendTimer > 0) {
          _resendTimer--;
        } else {
          _isResendEnabled = true;
          timer.cancel();
        }
      });
    });
  }

  sendOtp() async {
    if (_phoneController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter mobile number");
      return;
    }

    if (_phoneController.text.length != 10) {
      Fluttertoast.showToast(msg: "Please enter valid 10-digit mobile number");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String link = "$baseUrl/api/send_otp";

    try {
      var response = await http.post(
        Uri.parse(link),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'phone': _phoneController.text.toString(),
        },
      );

      setState(() {
        _isLoading = false;
      });

      final data = jsonDecode(response.body);
      print('Send OTP Response: ${response.body}');

      if (data['success'] == true) {
        setState(() {
          _isOtpSent = true;
        });
        startResendTimer();
        Fluttertoast.showToast(
          msg: data['message'] ?? "OTP sent successfully",
          backgroundColor: kGreenColor,
        );
      } else {
        Fluttertoast.showToast(
          msg: data['message'] ?? "Failed to send OTP",
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Fluttertoast.showToast(
        msg: "Network error: Please check your connection",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  verifyOtp() async {
    if (_otpController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter OTP");
      return;
    }

    if (_otpController.text.length != 4) {
      Fluttertoast.showToast(msg: "Please enter valid 4-digit OTP");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String link = "$baseUrl/api/verify_otp";
    var navigator = Navigator.of(context);
    sharedPreferences = await SharedPreferences.getInstance();

    try {
      var response = await http.post(
        Uri.parse(link),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'phone': _phoneController.text.toString(),
          'otp': _otpController.text.toString(),
        },
      );

      setState(() {
        _isLoading = false;
      });

      final data = jsonDecode(response.body);
      print('Verify OTP Response: ${response.body}');

      if (data['success'] == true) {
        final user = data["user"];
        final userToken = data["token"];

        // Save user data and token
        await sharedPreferences!.setString("access_token", userToken);
        await sharedPreferences!.setString("user", jsonEncode(user));
        await sharedPreferences!
            .setString("phone", _phoneController.text.toString());

        token = sharedPreferences!.getString("access_token");

        navigator.pushReplacement(
          MaterialPageRoute(
            builder: (context) => const SubscriptionCheckScreen(),
          ),
        );

        Fluttertoast.showToast(
          msg: data['message'] ?? "Login Successful",
          backgroundColor: kGreenColor,
        );
      } else {
        Fluttertoast.showToast(
          msg: data['message'] ?? "Invalid OTP",
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Fluttertoast.showToast(
        msg: "Network error: Please check your connection",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  isLogin() async {
    var navigator = Navigator.of(context);
    sharedPreferences = await SharedPreferences.getInstance();
    token = sharedPreferences!.getString("access_token");
    try {
      if (token == null) {
        // print("Token is Null");
      } else {
        Fluttertoast.showToast(msg: "Welcome Back");
        navigator.pushReplacement(MaterialPageRoute(
            builder: (context) => const SubscriptionCheckScreen()));
      }
    } catch (e) {
      // print("Exception is $e");
    }
  }

  @override
  void initState() {
    isLogin();
    super.initState();
  }

  InputDecoration getInputDecoration(String hintext, {Widget? suffixIcon}) {
    return InputDecoration(
      enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(16.0)),
        borderSide: BorderSide(color: kDefaultColor.withOpacity(0.1), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(16.0)),
        borderSide: BorderSide(color: kDefaultColor.withOpacity(0.1), width: 1),
      ),
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(16.0)),
        borderSide: BorderSide(color: kDefaultColor.withOpacity(0.1), width: 1),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
        borderSide: BorderSide(color: Color(0xFFF65054)),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
        borderSide: BorderSide(color: Color(0xFFF65054)),
      ),
      filled: true,
      hintStyle: const TextStyle(color: Colors.black54, fontSize: 16),
      hintText: hintext,
      fillColor: kInputBoxBackGroundColor,
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: globalFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                // Header
                const Center(
                  child: Text(
                    'Log In',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    _isOtpSent
                        ? 'Enter the OTP sent to your mobile number'
                        : 'Enter your mobile number to receive OTP',
                    style: TextStyle(
                      fontSize: 14,
                      color: kGreyLightColor,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 30),

                // Mobile Number Input
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 5.0),
                  child: TextFormField(
                    style: const TextStyle(fontSize: 16),
                    decoration: getInputDecoration(
                      'Mobile Number',
                      suffixIcon: _isOtpSent
                          ? Icon(Icons.check_circle, color: kGreenColor)
                          : Icon(Icons.phone, color: kGreyLightColor),
                    ),
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    enabled: !_isOtpSent,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    validator: (input) => input!.length != 10
                        ? "Please enter valid 10-digit mobile number"
                        : null,
                    onSaved: (value) {
                      setState(() {
                        _phoneController.text = value as String;
                      });
                    },
                  ),
                ),

                // OTP Input (only show when OTP is sent)
                if (_isOtpSent) ...[
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 5.0),
                    child: TextFormField(
                      style: const TextStyle(fontSize: 16, letterSpacing: 2),
                      decoration: getInputDecoration(
                        'Enter 4-digit OTP',
                        suffixIcon:
                            Icon(Icons.security, color: kGreyLightColor),
                      ),
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      validator: (input) => input!.length != 4
                          ? "Please enter valid 4-digit OTP"
                          : null,
                      onSaved: (value) {
                        setState(() {
                          _otpController.text = value as String;
                        });
                      },
                    ),
                  ),

                  // Resend OTP section
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Didn't receive OTP? ",
                          style: TextStyle(
                            color: kGreyLightColor,
                            fontSize: 14,
                          ),
                        ),
                        if (_isResendEnabled)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _otpController.clear();
                                _isOtpSent = false;
                              });
                              sendOtp();
                            },
                            child: Text(
                              "Resend OTP",
                              style: TextStyle(
                                color: kDefaultColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        else
                          Text(
                            "Resend in ${_resendTimer}s",
                            style: TextStyle(
                              color: kGreyLightColor,
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],

                // Login/Verify Button
                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: _isLoading
                      ? const Center(
                          child:
                              CircularProgressIndicator(color: kDefaultColor),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Center(
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        color: kPrimaryColor),
                                  ),
                                ),
                                MaterialButton(
                                  elevation: 0,
                                  onPressed: () {
                                    if (_isOtpSent) {
                                      verifyOtp();
                                    } else {
                                      sendOtp();
                                    }
                                  },
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadiusDirectional.circular(16),
                                    side: BorderSide(
                                      color: kGreyLightColor.withOpacity(0.3),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        _isOtpSent
                                            ? Icons.verified_user
                                            : Icons.send,
                                        color: kWhiteColor,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        _isOtpSent
                                            ? 'Verify OTP & Login'
                                            : 'Send OTP',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: kWhiteColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),

                // Change Number (only show when OTP is sent)
                if (_isOtpSent) ...[
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _isOtpSent = false;
                          _otpController.clear();
                          _timer?.cancel();
                        });
                      },
                      child: Text(
                        "Change Mobile Number",
                        style: TextStyle(
                          color: kDefaultColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],

                // Register Button
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 20),
                    child: MaterialButton(
                      elevation: 0,
                      color: Colors.white,
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const SignUpScreen()));
                      },
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusDirectional.circular(16),
                        side: BorderSide(
                          color: kGreyLightColor.withOpacity(0.3),
                          width: 1.0,
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_add,
                              color: kInputBoxIconColor, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'Create New Account',
                            style: TextStyle(
                              fontSize: 16,
                              color: kInputBoxIconColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Sign Up Link
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account? ',
                        style: TextStyle(
                          color: kGreyLightColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const SignUpScreen()));
                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: kSignUpTextColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
