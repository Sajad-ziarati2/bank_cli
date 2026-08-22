class Customer {
  final int accountNumber;
  final String name;
  final String lastname;
  final DateTime createdAt;
  final double balance;

  Customer({
    required this.accountNumber,
    required this.name,
    required this.lastname,
    required this.createdAt,
    required this.balance,
  });

  Map<String, dynamic> toJson() {
    return {'accountNumber': accountNumber, 'name': name,'lastname': lastname, 'balance': balance};
  }

  factory Customer.fromJson(Map<String, dynamic> Json) {
    return Customer(
      accountNumber: Json['accountNumber'] as int,
      name: Json['name'] as String,
      lastname: Json['lastname'] as String,
      createdAt: DateTime.parse(Json['createdAt'] as String),

      balance: (Json['balance'] as num).toDouble(),
    );
  }
}
