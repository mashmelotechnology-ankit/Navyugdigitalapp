import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/wallet_provider.dart';

class WalletWithdrawalHistoryScreen extends StatefulWidget {
  static const routeName = '/wallet-withdrawal-history';
  const WalletWithdrawalHistoryScreen({super.key});

  @override
  State<WalletWithdrawalHistoryScreen> createState() =>
      _WalletWithdrawalHistoryScreenState();
}

class _WalletWithdrawalHistoryScreenState
    extends State<WalletWithdrawalHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<WalletProvider>(context, listen: false)
        .fetchWithdrawalHistory();
  }

  @override
  Widget build(BuildContext context) {
    final wallet = Provider.of<WalletProvider>(context);
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: kWhiteColor),
        title: const Text(
          'Withdrawal History',
          style: TextStyle(color: kWhiteColor),
        ),
        backgroundColor: kDefaultColor,
      ),
      body: RefreshIndicator(
        color: kDefaultColor,
        onRefresh: () async {
          await Provider.of<WalletProvider>(context, listen: false)
              .fetchWithdrawalHistory();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ...wallet.withdrawals.map((wd) => Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.account_balance_wallet,
                                    color: kDefaultColor, size: 22),
                                const SizedBox(width: 8),
                                Text('₹${wd.amount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(
                                  wd.status == 'approved'
                                      ? Icons.check_circle
                                      : wd.status == 'rejected'
                                          ? Icons.cancel
                                          : Icons.hourglass_top,
                                  color: wd.status == 'approved'
                                      ? kGreenColor
                                      : wd.status == 'rejected'
                                          ? kRedColor
                                          : kYellowColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  wd.status[0].toUpperCase() +
                                      wd.status.substring(1),
                                  style: TextStyle(
                                    color: wd.status == 'approved'
                                        ? kGreenColor
                                        : wd.status == 'rejected'
                                            ? kRedColor
                                            : kYellowColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Divider(height: 24, thickness: 1),
                        const Text('Bank Details',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 4),
                        Text(
                            'Bank Name: ${wd.bankName.isNotEmpty ? wd.bankName : "-"}'),
                        Text(
                            'Account Number: ${wd.accountNumber.isNotEmpty ? wd.accountNumber : "-"}'),
                        Text(
                            'Account Holder: ${wd.accountHolderName.isNotEmpty ? wd.accountHolderName : "-"}'),
                        Text(
                            'IFSC Code: ${wd.ifscCode.isNotEmpty ? wd.ifscCode : "-"}'),
                        Text(
                            'SWIFT Code: ${wd.swiftCode.isNotEmpty ? wd.swiftCode : "-"}'),
                        const SizedBox(height: 10),
                        if (wd.remarks.isNotEmpty)
                          Text('Remarks: ${wd.remarks}',
                              style: const TextStyle(color: kGreyColor)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.calendar_today,
                                size: 16, color: kDefaultColor),
                            const SizedBox(width: 6),
                            Text(
                                'Requested: ${wd.createdAt.day}/${wd.createdAt.month}/${wd.createdAt.year} ${wd.createdAt.hour}:${wd.createdAt.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.update, size: 16, color: kDefaultColor),
                            const SizedBox(width: 6),
                            Text(
                                'Updated: ${wd.updatedAt.day}/${wd.updatedAt.month}/${wd.updatedAt.year} ${wd.updatedAt.hour}:${wd.updatedAt.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                  ),
                )),
            if (wallet.withdrawals.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No withdrawal requests found.',
                    style: TextStyle(color: kGreyColor)),
              ),
          ],
        ),
      ),
    );
  }
}
