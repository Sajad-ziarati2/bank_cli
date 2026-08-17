
class Customer {
  int accountNumber;
  String name;
  String lastname;
  double balance;

  Customer({
    required this.accountNumber,
    required this.name,
    required this.lastname,
    this.balance = 0,
  });
}
