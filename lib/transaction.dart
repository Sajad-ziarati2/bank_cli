class BankTransaction {
  final int accountNumber;
  final String type; 
  final double amount;
  final DateTime date;

  BankTransaction({
    required this.accountNumber,
    required this.type,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'accountNumber': accountNumber,
      'type': type,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }

  factory BankTransaction.fromJson(Map<String, dynamic> json) {
    return BankTransaction(
      accountNumber: (json['accountNumber'] as num).toInt(),
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
    );
  }
}