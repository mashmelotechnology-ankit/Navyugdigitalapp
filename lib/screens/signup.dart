// ignore_for_file: prefer_const_constructors, non_constant_identifier_names, avoid_print, prefer_final_fields

import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:academy_lms_app/constants.dart';
import 'package:academy_lms_app/screens/subscription_check_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpScreen extends StatefulWidget {
  // static const routeName = '/signup';
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<SignUpScreen> {
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool hidePassword = true;
  bool hideConPassword = true;
  bool _isLoading = false;
  bool _isOtpSent = false;
  bool _isResendEnabled = false;
  int _resendTimer = 60;
  Timer? _timer;
  String? token;

  SharedPreferences? sharedPreferences;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _salonNameController = TextEditingController();
  final _referCodeController = TextEditingController();
  final _otpController = TextEditingController();

  // Profile image variables
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _timer?.cancel();
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _salonNameController.dispose();
    _referCodeController.dispose();
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

  // Method to pick profile image
  Future<void> _pickProfileImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error selecting image: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  // Method to show image picker options
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickProfileImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
              if (_profileImage != null)
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Remove Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _profileImage = null;
                    });
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  // Method to send OTP for registration
  sendRegisterOtp() async {
    // Validate form first
    if (!globalFormKey.currentState!.validate()) {
      return;
    }

    if (_profileImage == null) {
      Fluttertoast.showToast(
        msg: "Profile Photo is required.",
        backgroundColor: Colors.red,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String link = "$baseUrl/api/send_register_otp";

    try {
      var response = await http.post(
        Uri.parse(link),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'phone': _mobileController.text.toString(),
        },
      );

      setState(() {
        _isLoading = false;
      });

      final data = jsonDecode(response.body);
      print('Send Register OTP Response: ${response.body}');

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

  // Method to take photo from camera
  Future<void> _takePhoto() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error taking photo: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  // Future<void> signup(
  //   String name,
  //   String email,
  //   String password,
  //   String password_confirmation,
  // ) async {
  //   sharedPreferences = await SharedPreferences.getInstance();
  //   // dynamic tokens = sharedPreferences!.getString("access_token");

  //   var urls = "$baseUrl/api/signup?type=registration";
  //   try {
  //     final responses = await http.post(
  //       Uri.parse(urls),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Accept': 'application/json',
  //       },
  //       body: json.encode({
  //         'name': name,
  //         'email': email,
  //         'password': password,
  //         'password_confirmation': password_confirmation,
  //       }),
  //     );

  //     if (responses.statusCode == 200) {
  //       final responseData = jsonDecode(responses.body);

  //       if (responseData['success']) {
  //         Fluttertoast.showToast(
  //           msg: "User created successfully",
  //           toastLength: Toast.LENGTH_SHORT,
  //           gravity: ToastGravity.BOTTOM,
  //           timeInSecForIosWeb: 2,
  //           backgroundColor: Colors.grey,
  //           textColor: Colors.white,
  //           fontSize: 16.0,
  //         );
  //       } else {
  //         // Handle other responses if needed
  //       }
  //     } else if (responses.statusCode == 422) {
  //       final responseData = jsonDecode(responses.body);

  //       if (responseData['validationError'] != null) {
  //         responseData['validationError'].forEach((key, value) {
  //           Fluttertoast.showToast(
  //             msg: value[0], // Display the first error message
  //             toastLength: Toast.LENGTH_SHORT,
  //             gravity: ToastGravity.BOTTOM,
  //             timeInSecForIosWeb: 2,
  //             backgroundColor: Colors.red,
  //             textColor: Colors.white,
  //             fontSize: 16.0,
  //           );
  //         });
  //       }
  //     } else {
  //       Fluttertoast.showToast(
  //         msg: "An error occurred",
  //         toastLength: Toast.LENGTH_SHORT,
  //         gravity: ToastGravity.BOTTOM,
  //         timeInSecForIosWeb: 2,
  //         backgroundColor: Colors.red,
  //         textColor: Colors.white,
  //         fontSize: 16.0,
  //       );
  //     }
  //   } catch (error) {
  //     // rethrow;
  //     print('Error: $error');
  //   }
  // }

  Future<void> signup(
    String name,
    String mobile,
    String email,
    String referCode,
    String salonName,
    String otp,
    BuildContext context,
  ) async {
    sharedPreferences = await SharedPreferences.getInstance();

    var urls = "$baseUrl/api/signup?type=registration";
    setState(() {
      _isLoading = true;
    });

    try {
      var request = http.MultipartRequest('POST', Uri.parse(urls));

      // Add form fields
      request.fields['name'] = name;
      request.fields['phone'] = mobile;
      request.fields['password'] = '12345678';
      request.fields['password_confirmation'] = '12345678';
      request.fields['referral_by'] = referCode;
      request.fields['salon_name'] = salonName;
      request.fields['otp'] = otp; // Add OTP parameter

      // Add email only if provided (optional)
      if (email.isNotEmpty) {
        request.fields['email'] = email;
      }

      // Add profile image
      if (_profileImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'photo',
            _profileImage!.path,
          ),
        );
      }

      // Add headers
      request.headers['Accept'] = 'application/json';

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var responseData = jsonDecode(responseBody);

      print('Signup Response: $responseBody');

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        if (responseData['success'] == true) {
          // Registration successful - handle like login response
          final user = responseData["user"];
          final userToken = responseData["token"];

          // Save user data and token for auto-login
          await sharedPreferences!.setString("access_token", userToken);
          await sharedPreferences!.setString("user", jsonEncode(user));
          await sharedPreferences!.setString("phone", mobile);

          // Navigate to subscription check screen (auto-login)
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const SubscriptionCheckScreen(),
            ),
          );

          Fluttertoast.showToast(
            msg: "Registration successful! Welcome!",
            backgroundColor: kGreenColor,
          );
        } else {
          Fluttertoast.showToast(
            msg: responseData['message'] ?? "Registration failed",
            backgroundColor: Colors.red,
          );
        }
      } else if (response.statusCode == 422) {
        if (responseData['validationError'] != null) {
          responseData['validationError'].forEach((key, value) {
            Fluttertoast.showToast(
              msg: value[0],
              backgroundColor: Colors.red,
            );
          });
        } else {
          Fluttertoast.showToast(
            msg: responseData['message'] ?? "Invalid OTP or registration data",
            backgroundColor: Colors.red,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: "An error occurred during registration",
          backgroundColor: Colors.red,
        );
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print('Error: $error');
      Fluttertoast.showToast(
        msg: "Network error: Please check your connection",
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  void initState() {
    // isLogin();
    super.initState();
  }

  InputDecoration getInputDecoration(String hintext) {
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
                Row(
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Image.asset("assets/images/Back Button.png")),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                const Center(
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                // Profile Photo Section
                GestureDetector(
                  onTap: _showImagePickerOptions,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: kDefaultColor.withOpacity(0.3),
                        width: 2,
                      ),
                      color: kInputBoxBackGroundColor,
                    ),
                    child: _profileImage != null
                        ? ClipOval(
                            child: Image.file(
                              _profileImage!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt,
                                size: 40,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Add Photo',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 5.0),
                  child: TextFormField(
                    style: const TextStyle(fontSize: 14),
                    decoration: getInputDecoration(
                      'Name',
                    ),
                    controller: _nameController,
                    // keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      setState(() {
                        _nameController.text = value as String;
                      });
                    },
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                // Mobile Number Field
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 5.0),
                  child: TextFormField(
                    style: const TextStyle(fontSize: 14),
                    decoration: getInputDecoration(
                      'Mobile Number',
                    ),
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your mobile number';
                      }
                      if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                        return 'Please enter a valid 10-digit mobile number';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      setState(() {
                        _mobileController.text = value as String;
                      });
                    },
                  ),
                ),
                // const SizedBox(
                //   height: 10,
                // ),
                // Padding(
                //   padding: const EdgeInsets.symmetric(
                //       horizontal: 20.0, vertical: 5.0),
                //   child: TextFormField(
                //     style: const TextStyle(fontSize: 14),
                //     decoration: getInputDecoration(
                //       'E-mail (Optional)',
                //     ),
                //     controller: _emailController,
                //     keyboardType: TextInputType.emailAddress,
                //     validator: (input) {
                //       // Email is optional, but if provided, it should be valid
                //       if (input != null && input.isNotEmpty) {
                //         if (!RegExp(
                //                 r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                //             .hasMatch(input)) {
                //           return "Email Id should be valid";
                //         }
                //       }
                //       return null;
                //     },
                //     onSaved: (value) {
                //       setState(() {
                //         _emailController.text = value as String;
                //       });
                //     },
                //   ),
                // ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 5.0),
                  child: TextFormField(
                    style: const TextStyle(fontSize: 14),
                    decoration: getInputDecoration(
                      'Academy/Salon Name',
                    ),
                    controller: _salonNameController,
                    // keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your full salon name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      setState(() {
                        _salonNameController.text = value as String;
                      });
                    },
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 5.0),
                  child: TextFormField(
                    style: const TextStyle(fontSize: 14),
                    decoration: getInputDecoration(
                      'Refer Code',
                    ),
                    controller: _referCodeController,
                    // keyboardType: TextInputType.emailAddress,

                    onSaved: (value) {
                      setState(() {
                        _referCodeController.text = value as String;
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
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(16.0)),
                          borderSide: BorderSide(
                              color: kDefaultColor.withOpacity(0.1), width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(16.0)),
                          borderSide: BorderSide(
                              color: kDefaultColor.withOpacity(0.1), width: 1),
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(16.0)),
                          borderSide: BorderSide(
                              color: kDefaultColor.withOpacity(0.1), width: 1),
                        ),
                        filled: true,
                        hintStyle: const TextStyle(
                            color: Colors.black54, fontSize: 16),
                        hintText: 'Enter 4-digit OTP',
                        fillColor: kInputBoxBackGroundColor,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 15),
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
                              });
                              sendRegisterOtp();
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

                // Change Form Button (only show when OTP is sent)
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
                        "Change Registration Details",
                        style: TextStyle(
                          color: kDefaultColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],

                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
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
                                  onPressed: () async {
                                    if (_isOtpSent) {
                                      // Verify OTP and Register
                                      if (_otpController.text.isEmpty) {
                                        Fluttertoast.showToast(
                                            msg: "Please enter OTP");
                                        return;
                                      }
                                      if (_otpController.text.length != 4) {
                                        Fluttertoast.showToast(
                                            msg:
                                                "Please enter valid 4-digit OTP");
                                        return;
                                      }

                                      signup(
                                        _nameController.text,
                                        _mobileController.text,
                                        _emailController.text,
                                        _referCodeController.text,
                                        _salonNameController.text,
                                        _otpController.text,
                                        context,
                                      );
                                    } else {
                                      // Send OTP
                                      if (globalFormKey.currentState!
                                          .validate()) {
                                        sendRegisterOtp();
                                      }
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
                                            ? 'Verify OTP & Register'
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
                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
