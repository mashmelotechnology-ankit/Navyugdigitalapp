// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';
import '../models/referral_model.dart';

class ReferAndEarnScreen extends StatefulWidget {
  static const routeName = '/refer-and-earn';

  const ReferAndEarnScreen({super.key});

  @override
  State<ReferAndEarnScreen> createState() => _ReferAndEarnScreenState();
}

class _ReferAndEarnScreenState extends State<ReferAndEarnScreen> {
  String? referralCode;
  bool _isLoading = true;
  bool _isLoadingReferrals = false;
  SharedPreferences? sharedPreferences;
  Map<String, dynamic>? user;
  List<ReferralUser> referralUsers = [];
  double totalCommissionEarned = 0.0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      sharedPreferences = await SharedPreferences.getInstance();
      var userDetails = sharedPreferences!.getString("user");

      if (userDetails != null) {
        user = jsonDecode(userDetails);

        // Generate or get existing referral code
        referralCode = user?['referral_code'];
        if (referralCode == null) {
          referralCode = _generateReferralCode();
          await sharedPreferences!.setString('referral_code', referralCode!);
        }
      } else {
        // Generate a default referral code if no user data
        referralCode = _generateReferralCode();
      }
    } catch (e) {
      print('Error loading user data: $e');
      referralCode = _generateReferralCode();
    }

    setState(() {
      _isLoading = false;
    });

    // Load referral data after user data is loaded
    _loadReferralData();
  }

  String _generateReferralCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
          8, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  Future<void> _loadReferralData() async {
    if (sharedPreferences == null) return;

    setState(() {
      _isLoadingReferrals = true;
    });

    try {
      final authToken = sharedPreferences!.getString('access_token') ?? '';

      if (authToken.isEmpty) {
        print('No auth token found');
        setState(() {
          _isLoadingReferrals = false;
        });
        return;
      }

      const url = '$baseUrl/api/user_referrals';

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
          final referralResponse = ReferralResponse.fromJson(responseData);

          setState(() {
            referralUsers = referralResponse.data;
            totalCommissionEarned = referralUsers.fold(
                0.0, (sum, user) => sum + user.commissionEarned);
          });
        }
      } else {
        print('Failed to load referral data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading referral data: $e');
    } finally {
      setState(() {
        _isLoadingReferrals = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadReferralData();
  }

  void _copyReferralCode() {
    if (referralCode != null) {
      Clipboard.setData(ClipboardData(text: referralCode!));
      Fluttertoast.showToast(
        msg: 'Referral code copied to clipboard!',
        backgroundColor: kGreenColor,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  void _shareReferralCode() {
    if (referralCode != null) {
      final shareText = '''
🎓 Join me on Navyug Beauty Studio and start learning today!

Use my referral code: $referralCode

Get amazing courses and exclusive content. 
Download the app now and use my code to get special benefits!

💰 Earn up to ₹10,00,000 per year through referrals!
20% commission on every plan purchase!

#NavyugBeautyStudio #Learning #BeautyEducation #EarnMoney
      ''';

      Share.share(
        shareText,
        subject: 'Join Navyug Beauty Studio with my referral code',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackGroundColor,
      appBar: AppBar(
        backgroundColor: kDefaultColor,
        elevation: 0,
        title: const Text(
          'Refer & Earn',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadReferralData,
            tooltip: 'Refresh Referrals',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              color: kDefaultColor,
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Rewards Info
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(25),
                      margin: const EdgeInsets.only(bottom: 30),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            kDefaultColor.withOpacity(0.1),
                            kDefaultColor.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: kDefaultColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Clean Header Section
                          Column(
                            children: [
                              // Simple Icon
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: kDefaultColor,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Icon(
                                  Icons.trending_up,
                                  size: 30,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 15),

                              // Clean Title
                              Text(
                                'Refer & Earn',
                                style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width < 350
                                          ? 20
                                          : 24,
                                  fontWeight: FontWeight.bold,
                                  color: kDefaultColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),

                              // Subtitle
                              Text(
                                'Unlock Unlimited Income! 💸',
                                style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width < 350
                                          ? 16
                                          : 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          const SizedBox(height: 25),

                          // Main description
                          Text(
                            'You can earn huge rewards just by referring others!',
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width < 350
                                  ? 14
                                  : 16,
                              fontWeight: FontWeight.w600,
                              color: kTextColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 15),

                          Text(
                            'Whenever someone buys a plan through your referral, you earn 20% of that plan\'s value —',
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width < 350
                                  ? 12
                                  : 14,
                              color: kTextColor,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),

                          // Commission plans
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                _buildCommissionRow('Basic Plan:',
                                    '20% commission', Icons.star_border),
                                const SizedBox(height: 8),
                                _buildCommissionRow('Standard Plan:',
                                    '20% commission', Icons.star_half),
                                const SizedBox(height: 8),
                                _buildCommissionRow(
                                    'VIP Plan:', '20% commission', Icons.star),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Highlight earnings potential
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  kGreenColor.withOpacity(0.1),
                                  kGreenColor.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: kGreenColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'That\'s not all — you can earn over',
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width < 350
                                            ? 12
                                            : 14,
                                    color: kTextColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 5),
                                FittedBox(
                                  child: Text(
                                    '₹10,00,000 per year',
                                    style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width <
                                                  350
                                              ? 20
                                              : 24,
                                      fontWeight: FontWeight.bold,
                                      color: kGreenColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'just by referring!',
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width < 350
                                            ? 12
                                            : 14,
                                    color: kTextColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15),

                          // Call to action
                          Text(
                            'Many of our users are already doing it — now it\'s your turn to earn big!',
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width < 350
                                  ? 12
                                  : 14,
                              color: kTextColor,
                              fontStyle: FontStyle.italic,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),

                          Text(
                            'Start referring today and turn your network into income!',
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width < 350
                                  ? 14
                                  : 16,
                              fontWeight: FontWeight.bold,
                              color: kDefaultColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    // Referral Code Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(25),
                      margin: const EdgeInsets.only(bottom: 30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Your Referral Code',
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width < 350
                                  ? 16
                                  : 18,
                              fontWeight: FontWeight.bold,
                              color: kTextColor,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                            decoration: BoxDecoration(
                              color: kDefaultColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: kDefaultColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      referralCode ?? 'LOADING...',
                                      style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width <
                                                    350
                                                ? 18
                                                : 20,
                                        fontWeight: FontWeight.w600,
                                        color: kDefaultColor,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: _copyReferralCode,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: kDefaultColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.copy,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // How it Works
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(25),
                      margin: const EdgeInsets.only(bottom: 30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'How it Works',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: kTextColor,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildStep(
                            '1',
                            'Share Your Code',
                            'Share your unique referral code with friends and family',
                            Icons.share,
                          ),
                          const SizedBox(height: 15),
                          _buildStep(
                            '2',
                            'Friend Joins',
                            'Your friend signs up using your referral code',
                            Icons.person_add,
                          ),
                          const SizedBox(height: 15),
                          _buildStep(
                            '3',
                            'Earn Rewards',
                            'Both you and your friend get amazing rewards!',
                            Icons.card_giftcard,
                          ),
                        ],
                      ),
                    ),

                    // Referral Summary
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(25),
                      margin: const EdgeInsets.only(bottom: 30),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            kGreenColor.withOpacity(0.1),
                            kGreenColor.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: kGreenColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.people,
                            size: 40,
                            color: kGreenColor,
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'Your Referral Stats',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: kTextColor,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      '${referralUsers.length}',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: kGreenColor,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Friends Referred',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: kTextColor,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: kGreenColor.withOpacity(0.3),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      '₹${totalCommissionEarned.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: kGreenColor,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Commission Earned',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: kTextColor,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Referral List
                    if (referralUsers.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(25),
                        margin: const EdgeInsets.only(bottom: 30),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  color: kDefaultColor,
                                  size: 24,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Your Referrals',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: kTextColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            ..._buildReferralList(),
                          ],
                        ),
                      ),
                    ],

                    // Loading indicator for referrals
                    if (_isLoadingReferrals) ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Column(
                            children: [
                              CircularProgressIndicator(
                                color: kDefaultColor,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Loading your referrals...',
                                style: TextStyle(
                                  color: kTextColor,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    // Share Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _shareReferralCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kDefaultColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.share, size: 20),
                            const SizedBox(width: 10),
                            const Text(
                              'Share Referral Code',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCommissionRow(
      String planName, String commission, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: kDefaultColor,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  planName,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width < 350 ? 12 : 14,
                    fontWeight: FontWeight.w600,
                    color: kTextColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: kGreenColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: kGreenColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: FittedBox(
              child: Text(
                commission,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width < 350 ? 10 : 12,
                  fontWeight: FontWeight.bold,
                  color: kGreenColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep(
      String number, String title, String description, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: kDefaultColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 20, color: kDefaultColor),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kTextColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: kSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildReferralList() {
    return referralUsers.map((user) {
      return Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kInputBoxBackGroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: kDefaultColor.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Profile Image
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: kDefaultColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: kDefaultColor.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: user.profileImageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Image.network(
                        user.profileImageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            color: kDefaultColor,
                            size: 25,
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.person,
                      color: kDefaultColor,
                      size: 25,
                    ),
            ),

            const SizedBox(width: 15),

            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.currentPlanName,
                    style: TextStyle(
                      fontSize: 12,
                      color: kDefaultColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Code: ${user.referralCode}',
                    style: TextStyle(
                      fontSize: 11,
                      color: kSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),

            // Commission Earned
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: kGreenColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: kGreenColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '₹${user.commissionEarned.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: kGreenColor,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Commission',
                  style: TextStyle(
                    fontSize: 10,
                    color: kSecondaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }).toList();
  }
}
