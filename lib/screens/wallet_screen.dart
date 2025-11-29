import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/wallet_provider.dart';
import 'wallet_withdrawal_screen.dart';
import 'wallet_withdrawal_history_screen.dart';

class WalletScreen extends StatefulWidget {
  static const routeName = '/wallet';
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<WalletProvider>(context, listen: false).fetchWalletData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: kWhiteColor),
        title: const Text(
          'Wallet',
          style: TextStyle(
            fontSize: 20,
            color: kWhiteColor,
          ),
        ),
        backgroundColor: kDefaultColor,
      ),
      body: Consumer<WalletProvider>(
        builder: (ctx, wallet, _) => RefreshIndicator(
          color: kDefaultColor,
          onRefresh: () => wallet.fetchWalletData(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 24),
                  child: Column(
                    children: [
                      const Text('Wallet Balance',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('₹${wallet.balance.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 32,
                              color: kDefaultColor,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () => Navigator.pushNamed(
                                context, WalletWithdrawalScreen.routeName),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: kDefaultColor),
                            child: const Text('Withdraw'),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton(
                            onPressed: () => Navigator.pushNamed(context,
                                WalletWithdrawalHistoryScreen.routeName),
                            child: const Text(
                              'Withdraw History',
                              style: TextStyle(
                                fontSize: 14,
                                color: kDefaultColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Transaction History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...wallet.transactions.map((tx) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: Icon(
                          tx.type == 'credit'
                              ? Icons.arrow_downward
                              : Icons.arrow_upward,
                          color: tx.type == 'credit' ? kGreenColor : kRedColor),
                      title: Text('₹${tx.amount.toStringAsFixed(2)}'),
                      subtitle: Text(tx.description),
                      trailing: Text(
                          '${tx.dateTime.day}/${tx.dateTime.month}/${tx.dateTime.year} ${tx.dateTime.hour}:${tx.dateTime.minute.toString().padLeft(2, '0')}'),
                    ),
                  )),
              if (wallet.transactions.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No transactions found.',
                      style: TextStyle(color: kGreyColor)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
