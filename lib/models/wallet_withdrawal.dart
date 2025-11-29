class WalletWithdrawal {
  final int id;
  final double amount;
  final String bankName;
  final String accountNumber;
  final String accountHolderName;
  final String ifscCode;
  final String swiftCode;
  final String status; // 'pending', 'approved', 'rejected'
  final String remarks;
  final DateTime createdAt;
  final DateTime updatedAt;

  WalletWithdrawal({
    required this.id,
    required this.amount,
    required this.bankName,
    required this.accountNumber,
    required this.accountHolderName,
    required this.ifscCode,
    required this.swiftCode,
    required this.status,
    required this.remarks,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WalletWithdrawal.fromJson(Map<String, dynamic> json) {
    return WalletWithdrawal(
      id: json['id'],
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      bankName: json['bank_name'] ?? '',
      accountNumber: json['account_number'] ?? '',
      accountHolderName: json['account_holder_name'] ?? '',
      ifscCode: json['ifsc_code'] ?? '',
      swiftCode: json['swift_code'] ?? '',
      status: json['status'] ?? '',
      remarks: json['remarks'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
