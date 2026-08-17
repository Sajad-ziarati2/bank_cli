import 'customer.dart';

class Bank {
  List<Customer> customers;
  Bank({List<Customer>? customers}) : customers = customers ?? [];
}
