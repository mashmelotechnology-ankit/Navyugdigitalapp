import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../models/wallet_transaction.dart';
import '../models/wallet_withdrawal.dart';

class WalletProvider with ChangeNotifier {
  double _balance = 0.0;
  List<WalletTransaction> _transactions = [];
  List<WalletWithdrawal> _withdrawals = [];

  double get balance => _balance;
  List<WalletTransaction> get transactions => [..._transactions];
  List<WalletWithdrawal> get withdrawals => [..._withdrawals];

  Future<void> fetchWalletData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';
    final url = '$baseUrl/api/user_wallet';

    final res = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      _balance = double.tryParse(data['wallet_balance'].toString()) ?? 0.0;
      final txList = (data['data']['data'] as List? ?? []);
      _transactions = txList
          .map((tx) => WalletTransaction(
                id: tx['id'],
                amount: double.tryParse(tx['amount'].toString()) ?? 0.0,
                type: tx['transaction_type'] == 'credited' ? 'credit' : 'debit',
                description: tx['particular'] ?? '',
                dateTime: DateTime.parse(tx['created_at']),
              ))
          .toList();
    }
    notifyListeners();
  }

  Future<bool> requestWithdrawal({
    required double amount,
    required String bankName,
    required String accountNumber,
    required String accountHolderName,
    required String ifscCode,
    required String swiftCode,
    required String remarks,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';
    final url = 'https://nabyug.online/api/withdrawal/request';
    final res = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'amount': amount,
        'bank_name': bankName,
        'account_number': accountNumber,
        'account_holder_name': accountHolderName,
        'ifsc_code': ifscCode,
        'swift_code': swiftCode,
        'remarks': remarks,
      }),
    );
    if (res.statusCode == 200) {
      await fetchWithdrawalHistory();
      await fetchWalletData();
      return true;
    }
    return false;
  }

  Future<void> fetchWithdrawalHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';
    final url = '$baseUrl/api/withdrawal/history';

    final res = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final wdList = (data['withdrawals']['data'] as List? ?? []);
      _withdrawals = wdList
          .map((wd) => WalletWithdrawal(
                id: wd['id'],
                amount: double.tryParse(wd['amount'].toString()) ?? 0.0,
                bankName: wd['bank_name'] ?? '',
                accountNumber: wd['account_number'] ?? '',
                accountHolderName: wd['account_holder_name'] ?? '',
                ifscCode: wd['ifsc_code'] ?? '',
                swiftCode: wd['swift_code'] ?? '',
                status: wd['status'] ?? '',
                remarks: wd['remarks'] ?? '',
                createdAt: DateTime.parse(wd['created_at']),
                updatedAt: DateTime.parse(wd['updated_at']),
              ))
          .toList();
    }
    notifyListeners();
  }
}
