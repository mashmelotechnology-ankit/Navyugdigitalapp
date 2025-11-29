class WalletTransaction {
  final int id;
  final double amount;
  final String type; // 'credit' or 'debit'
  final String description;
  final DateTime dateTime;

  WalletTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.description,
    required this.dateTime,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'],
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      type: json['type'],
      description: json['description'] ?? '',
      dateTime: DateTime.parse(json['date_time']),
    );
  }
}
