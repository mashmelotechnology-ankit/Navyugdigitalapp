// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../models/subscription_models.dart';
import '../providers/subscription_plans.dart';
import '../widgets/common_functions.dart';

class SubscriptionHistoryScreen extends StatefulWidget {
  static const routeName = '/subscription-history';

  const SubscriptionHistoryScreen({super.key});

  @override
  State<SubscriptionHistoryScreen> createState() =>
      _SubscriptionHistoryScreenState();
}

class _SubscriptionHistoryScreenState extends State<SubscriptionHistoryScreen> {
  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });

      Provider.of<SubscriptionPlans>(context, listen: false)
          .fetchSubscriptionHistory()
          .then((_) {
        setState(() {
          _isLoading = false;
        });
      }).catchError((error) {
        setState(() {
          _isLoading = false;
        });
        CommonFunctions.showErrorDialog(
            'Could not load subscription history!', context);
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> _refreshHistory() async {
    try {
      setState(() {
        _isLoading = true;
      });
      await Provider.of<SubscriptionPlans>(context, listen: false)
          .fetchSubscriptionHistory();
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      // ignore: use_build_context_synchronously
      CommonFunctions.showErrorDialog('Could not refresh history!', context);
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return kGreenColor;
      case 'expired':
        return kRedColor;
      case 'upgraded':
        return kBlueColor;
      case 'cancelled':
        return kOrangeColor;
      default:
        return kSecondaryColor;
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
          'Registration History',
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
              onRefresh: _refreshHistory,
              child: Consumer<SubscriptionPlans>(
                builder: (ctx, subscriptionData, child) {
                  final history = subscriptionData.subscriptionHistory;

                  if (history.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 80,
                            color: kSecondaryColor,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No subscription history found',
                            style: TextStyle(
                              fontSize: 18,
                              color: kSecondaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Your subscription history will appear here',
                            style: TextStyle(
                              fontSize: 14,
                              color: kSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: history.length,
                    itemBuilder: (ctx, index) {
                      final subscription = history[index];
                      return _buildHistoryCard(subscription);
                    },
                  );
                },
              ),
            ),
    );
  }

  Widget _buildHistoryCard(SubscriptionHistory subscription) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with plan name and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    subscription.plan?.planName ?? 'Unknown Plan',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kTextColor,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        _getStatusColor(subscription.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getStatusColor(subscription.status),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    subscription.status?.toUpperCase() ?? 'UNKNOWN',
                    style: TextStyle(
                      color: _getStatusColor(subscription.status),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Plan details
            if (subscription.plan != null) ...[
              Text(
                subscription.plan!.description ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  color: kSecondaryColor,
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Date range
            Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 16, color: kSecondaryColor),
                const SizedBox(width: 8),
                Text(
                  '${_formatDate(subscription.startDate)} - ${_formatDate(subscription.endDate)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: kSecondaryColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Amount paid
            Row(
              children: [
                const Icon(Icons.payment, size: 16, color: kSecondaryColor),
                const SizedBox(width: 8),
                Text(
                  'Amount Paid: ₹${subscription.amountPaid?.toStringAsFixed(2) ?? 'N/A'}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: kDefaultColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Payment method
            if (subscription.paymentMethod != null) ...[
              Row(
                children: [
                  const Icon(Icons.credit_card,
                      size: 16, color: kSecondaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Payment Method: ${subscription.paymentMethod!.toUpperCase()}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: kSecondaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Upgrade status
            if (subscription.isUpgraded == true)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: kBlueColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.upgrade, size: 14, color: kBlueColor),
                    SizedBox(width: 4),
                    Text(
                      'Upgraded Plan',
                      style: TextStyle(
                        fontSize: 12,
                        color: kBlueColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            // Created date
            const SizedBox(height: 8),
            Text(
              'Subscribed on: ${_formatDate(subscription.createdAt)}',
              style: const TextStyle(
                fontSize: 12,
                color: kSecondaryColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
