
class Customer {
  int accountNumber;
  String name;
  String lastname;
  String phone;
  double balance;

  Customer({
    required this.accountNumber,
    required this.name,
    required this.lastname,
    required this.phone,
    this.balance = 0,
  });
}
