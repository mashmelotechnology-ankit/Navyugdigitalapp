import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/wallet_provider.dart';

class WalletWithdrawalScreen extends StatefulWidget {
  static const routeName = '/wallet-withdrawal';
  const WalletWithdrawalScreen({super.key});

  @override
  State<WalletWithdrawalScreen> createState() => _WalletWithdrawalScreenState();
}

class _WalletWithdrawalScreenState extends State<WalletWithdrawalScreen> {
  final _formKey = GlobalKey<FormState>();
  double _amount = 0.0;
  String _bankName = '';
  String _accountNumber = '';
  String _accountHolderName = '';
  String _ifscCode = '';
  String _swiftCode = '';
  String _remarks = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final wallet = Provider.of<WalletProvider>(context);
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: kWhiteColor),
        title: const Text(
          'Request Withdrawal',
          style: TextStyle(
            fontSize: 20,
            color: kWhiteColor,
          ),
        ),
        backgroundColor: kDefaultColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Current Balance: ₹${wallet.balance.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Withdrawal Amount',
                  hintStyle: TextStyle(color: kGreyColor),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kGreyColor),
                      borderRadius: BorderRadius.circular(8)),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: kGreyColor),
                      borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kDefaultColor),
                      borderRadius: BorderRadius.circular(8)),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final val = double.tryParse(value ?? '');
                  if (val == null || val <= 0) return 'Enter a valid amount';
                  if (val > wallet.balance) return 'Amount exceeds balance';
                  return null;
                },
                onSaved: (value) =>
                    _amount = double.tryParse(value ?? '') ?? 0.0,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Bank Name',
                  hintStyle: TextStyle(color: kGreyColor),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kGreyColor),
                      borderRadius: BorderRadius.circular(8)),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: kGreyColor),
                      borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kDefaultColor),
                      borderRadius: BorderRadius.circular(8)),
                ),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Enter bank name' : null,
                onSaved: (value) => _bankName = value ?? '',
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Account Number',
                  hintStyle: TextStyle(color: kGreyColor),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kGreyColor),
                      borderRadius: BorderRadius.circular(8)),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: kGreyColor),
                      borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kDefaultColor),
                      borderRadius: BorderRadius.circular(8)),
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Enter account number'
                    : null,
                onSaved: (value) => _accountNumber = value ?? '',
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Account Holder Name',
                  hintStyle: TextStyle(color: kGreyColor),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kGreyColor),
                      borderRadius: BorderRadius.circular(8)),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: kGreyColor),
                      borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kDefaultColor),
                      borderRadius: BorderRadius.circular(8)),
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Enter account holder name'
                    : null,
                onSaved: (value) => _accountHolderName = value ?? '',
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'IFSC Code',
                  hintStyle: TextStyle(color: kGreyColor),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kGreyColor),
                      borderRadius: BorderRadius.circular(8)),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: kGreyColor),
                      borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kDefaultColor),
                      borderRadius: BorderRadius.circular(8)),
                ),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Enter IFSC code' : null,
                onSaved: (value) => _ifscCode = value ?? '',
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'SWIFT Code',
                  hintStyle: TextStyle(color: kGreyColor),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kGreyColor),
                      borderRadius: BorderRadius.circular(8)),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: kGreyColor),
                      borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kDefaultColor),
                      borderRadius: BorderRadius.circular(8)),
                ),
                onSaved: (value) => _swiftCode = value ?? '',
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Remarks (optional)',
                  hintStyle: TextStyle(color: kGreyColor),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kGreyColor),
                      borderRadius: BorderRadius.circular(8)),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: kGreyColor),
                      borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kDefaultColor),
                      borderRadius: BorderRadius.circular(8)),
                ),
                onSaved: (value) => _remarks = value ?? '',
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: kDefaultColor),
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            _formKey.currentState?.save();
                            setState(() => _isLoading = true);
                            final success = await wallet.requestWithdrawal(
                              amount: _amount,
                              bankName: _bankName,
                              accountNumber: _accountNumber,
                              accountHolderName: _accountHolderName,
                              ifscCode: _ifscCode,
                              swiftCode: _swiftCode,
                              remarks: _remarks,
                            );
                            setState(() => _isLoading = false);
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Withdrawal request submitted')));
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Failed to submit request')));
                            }
                          }
                        },
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Submit Request'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
