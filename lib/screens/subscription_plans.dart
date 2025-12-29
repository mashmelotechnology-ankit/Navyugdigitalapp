// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../constants.dart';
import '../models/subscription_plan.dart';
import '../models/subscription_models.dart';
import '../providers/subscription_plans.dart';
import '../providers/subscription_provider.dart';
import '../widgets/common_functions.dart';
import 'tab_screen.dart';

class SubscriptionPlansScreen extends StatefulWidget {
  static const routeName = '/subscription-plans';

  const SubscriptionPlansScreen({super.key});

  @override
  State<SubscriptionPlansScreen> createState() =>
      _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  var _isInit = true;
  var _isLoading = false;
  CurrentSubscription? currentSubscription;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      // Use addPostFrameCallback to ensure the call happens after the build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadData();
        }
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    final subscriptionProvider =
        Provider.of<SubscriptionPlans>(context, listen: false);

    try {
      await Future.wait([
        subscriptionProvider.fetchSubscriptionPlans(),
        subscriptionProvider.fetchCurrentSubscription(),
      ]);

      if (mounted) {
        setState(() {
          currentSubscription = subscriptionProvider.currentSubscription;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        CommonFunctions.showErrorDialog(
            'Could not load subscription data!', context);
      }
    }
  }

  Future<void> _refreshPlans() async {
    try {
      setState(() {
        _isLoading = true;
      });
      await _loadData();
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      // ignore: use_build_context_synchronously
      CommonFunctions.showErrorDialog('Could not refresh plans!', context);
    }
  }

  Future<void> _subscribeToPlan(SubscriptionPlan plan) async {
    final subscriptionProvider =
        Provider.of<SubscriptionPlans>(context, listen: false);

    // First, calculate upgrade cost
    final upgradeCost =
        await subscriptionProvider.calculateUpgradeCost(plan.id!);

    if (upgradeCost == null) {
      Fluttertoast.showToast(
        msg: 'Could not calculate subscription cost. Please try again.',
        backgroundColor: kRedColor,
        textColor: Colors.white,
      );
      return;
    }

    // Show confirmation dialog with upgrade cost details
    bool? confirmed = await _showSubscriptionDialog(plan, upgradeCost);
    print(confirmed);
    if (confirmed == true) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      try {
        // For now, we'll use a mock payment method
        // In a real app, you would integrate with a payment gateway here
        final result = await subscriptionProvider.openCheckout(
            context: context,
            amount: upgradeCost.upgradeCost!,
            planId: plan.id!,
            description: plan.description ?? '',
            contactNumber: '',
            email: '',
            name: 'Navyug Digital User');

        // ignore: use_build_context_synchronously
        Navigator.of(context).pop(); // Close loading dialog

        if (result == true) {
          setState(() {
            currentSubscription = subscriptionProvider.currentSubscription;
          });

          // Refresh subscription status in the subscription provider
          final subscriptionStatusProvider =
              Provider.of<SubscriptionProvider>(context, listen: false);
          await subscriptionStatusProvider.refreshSubscriptionStatus();

          String message = upgradeCost.isUpgrade == true
              ? 'Successfully upgraded to ${plan.planName}!'
              : 'Successfully subscribed to ${plan.planName}!';

          Fluttertoast.showToast(
            msg: message,
            backgroundColor: kGreenColor,
            textColor: Colors.white,
          );

          // Add a small delay to ensure all data is updated
          await Future.delayed(const Duration(milliseconds: 500));

          // Clear all navigation stack and navigate to home after successful subscription
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const TabsScreen(pageIndex: 0),
              ),
              (route) => false, // This removes all previous routes
            );
          }
        } else {
          Fluttertoast.showToast(
            msg: 'Failed to subscribe. Please try again.',
            backgroundColor: kRedColor,
            textColor: Colors.white,
          );
        }
      } catch (error) {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop(); // Close loading dialog
        Fluttertoast.showToast(
          msg: 'An error occurred. Please try again.',
          backgroundColor: kRedColor,
          textColor: Colors.white,
        );
      }
    }
  }

  Future<bool?> _showSubscriptionDialog(
      SubscriptionPlan plan, UpgradeCost upgradeCost) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(upgradeCost.isUpgrade == true
              ? 'Upgrade Plan'
              : 'Subscribe to Plan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (upgradeCost.isUpgrade == true) ...[
                Text('Current Plan: ${upgradeCost.currentPlan?.planName}'),
                Text('Remaining Days: ${upgradeCost.remainingDays}'),
                if (upgradeCost.refundAmount != null)
                  Text(
                      'Credit for unused days: ₹${upgradeCost.refundAmount!.toStringAsFixed(2)}'),
                const SizedBox(height: 10),
              ],
              Text('New Plan: ${plan.planName}'),
              const SizedBox(height: 10),
              Text(
                'Total Cost: ₹${upgradeCost.upgradeCost!.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: kDefaultColor,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: kDefaultColor,
                foregroundColor: Colors.white,
              ),
              child:
                  Text(upgradeCost.isUpgrade == true ? 'Upgrade' : 'Subscribe'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackGroundColor,
      appBar: AppBar(
        backgroundColor: kDefaultColor,
        elevation: 0,
        title: const Text(
          'Registration Plans',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshPlans,
              child: Consumer<SubscriptionPlans>(
                builder: (ctx, subscriptionData, child) {
                  final plans = subscriptionData.plans;

                  if (plans.isEmpty) {
                    return const Center(
                      child: Text(
                        'No registration plans available',
                        style: TextStyle(fontSize: 16, color: kTextColor),
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Current Subscription Card
                        if (currentSubscription != null) ...[
                          _buildCurrentSubscriptionCard(),
                          const SizedBox(height: 20),
                        ],

                        // Plans List
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: plans.length,
                          itemBuilder: (ctx, index) {
                            final plan = plans[index];
                            return _buildPlanCard(plan);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildCurrentSubscriptionCard() {
    if (currentSubscription == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kDefaultColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kDefaultColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: kDefaultColor),
              const SizedBox(width: 8),
              const Text(
                'Current Registration',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kDefaultColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            currentSubscription!.plan?.planName ?? 'Unknown Plan',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Status: ${currentSubscription!.status?.toUpperCase()}',
            style: TextStyle(
              color: currentSubscription!.isActive == true
                  ? kGreenColor
                  : kRedColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (currentSubscription!.remainingDays != null)
            Text(
              'Days Remaining: ${currentSubscription!.remainingDays}',
              style: const TextStyle(color: kSecondaryColor),
            ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan) {
    final isCurrentPlan = currentSubscription?.plan?.id == plan.id;
    final hasDiscount =
        plan.discountedPrice != null && plan.discountedPrice! < plan.mrp!;

    // Check if this plan is below the current plan (cheaper or equal price)
    final currentPlanPrice = currentSubscription?.plan?.discountedPrice ??
        currentSubscription?.plan?.mrp ??
        0;
    final thisPlanPrice = plan.discountedPrice ?? plan.mrp ?? 0;
    final isBelowCurrentPlan = currentSubscription != null &&
        thisPlanPrice <= currentPlanPrice &&
        !isCurrentPlan;
    final isAboveCurrentPlan =
        currentSubscription != null && thisPlanPrice > currentPlanPrice;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isCurrentPlan
            ? Border.all(color: kGreenColor, width: 2)
            : (plan.planName?.toLowerCase().contains('premium') == true)
                ? Border.all(color: kDefaultColor, width: 2)
                : null,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Popular/Current Badge
          if (isCurrentPlan)
            Positioned(
              top: 0,
              right: 20,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: const BoxDecoration(
                  color: kGreenColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: const Text(
                  'CURRENT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          else if (plan.planName?.toLowerCase().contains('premium') == true)
            Positioned(
              top: 0,
              right: 20,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: const BoxDecoration(
                  color: kDefaultColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: const Text(
                  'POPULAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plan Name and Description
                Text(
                  plan.planName ?? '',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: kTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  plan.description ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    color: kSecondaryColor,
                  ),
                ),
                const SizedBox(height: 16),

                // Price
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (hasDiscount) ...[
                      Text(
                        '₹${plan.mrp!.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: kSecondaryColor,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      '₹${plan.discountedPrice?.toStringAsFixed(0) ?? plan.mrp?.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: hasDiscount ? 28 : 24,
                        fontWeight: FontWeight.bold,
                        color: kDefaultColor,
                      ),
                    ),
                    Text(
                      '/${plan.planPeriodDays} days',
                      style: const TextStyle(
                        fontSize: 16,
                        color: kSecondaryColor,
                      ),
                    ),
                  ],
                ),

                if (hasDiscount)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: kGreenColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Save ₹${plan.savings?.toStringAsFixed(0)} (${plan.discountPercentage?.toStringAsFixed(0)}%)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // Features
                _buildFeaturesList(plan),

                const SizedBox(height: 20),

                // Subscribe Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (isCurrentPlan || isBelowCurrentPlan)
                        ? null
                        : () => _subscribeToPlan(plan),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCurrentPlan
                          ? kSecondaryColor
                          : isBelowCurrentPlan
                              ? kSecondaryColor
                              : isAboveCurrentPlan
                                  ? Colors.blue
                                  : kSecondaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      disabledBackgroundColor: kSecondaryColor.withOpacity(0.5),
                      disabledForegroundColor: Colors.white.withOpacity(0.7),
                    ),
                    child: Text(
                      isCurrentPlan
                          ? 'Current Plan'
                          : isBelowCurrentPlan
                              ? 'Downgrade Unavailable'
                              : (currentSubscription != null
                                  ? 'Upgrade'
                                  : 'Subscribe Now'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesList(SubscriptionPlan plan) {
    final defaultFeatures = [
      'Access to ${plan.noOfCourses} courses',
      '${plan.noOfLiveClasses} live classes',
      '${plan.noOfWebinars} webinars',
      '${plan.noOfDiplomaCertificates} diploma certificates',
      '${plan.planPeriodDays} days validity',
    ];

    // Combine default features with API features
    final allFeatures = <String>[];
    allFeatures.addAll(defaultFeatures);

    // Add API features if available
    if (plan.features != null && plan.features!.isNotEmpty) {
      allFeatures.addAll(plan.features!);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Features:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: kTextColor,
          ),
        ),
        const SizedBox(height: 8),
        ...allFeatures.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: kGreenColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feature,
                      style: const TextStyle(
                        fontSize: 14,
                        color: kTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
