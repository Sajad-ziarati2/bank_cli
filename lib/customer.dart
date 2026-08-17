class Customer {
  int accountNumber;
  String name;

  double balance;

  Customer({
    required this.accountNumber,
    required this.name,
 
    required this.balance,
  });

  Map<String, dynamic> toJson() {
    return {
      'accountNumber': accountNumber,
      'name': name,
  
      'balance': balance,
    };
  }

  factory Customer.fromJson(Map<String, dynamic> Json) {
    return Customer(
      accountNumber: Json['accountNumber'] as int,
      name: Json['name'] as String,
      
      balance: (Json['balance'] as num).toDouble(),
    );
  }
}
