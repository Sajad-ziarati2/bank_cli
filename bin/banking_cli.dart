import 'dart:io';
import 'package:todo_app/bank.dart';
import 'package:todo_app/customer.dart';

void main() {
  Bank bank = Bank();
  while (true) {
    print('\n====BANK CLI APP=====');
    print("1 . ADD CUSTOMER");
    print("2 . REMOVE CUSTOMER");
    print("3 . LIST CUSTOMER");
    print('4 . EXPORT REPORT AS CSV');
    print('5 .EXIT');

    stdout.write("\n choose an option :");
    String? choice = stdin.readLineSync();
    if (choice == '1') {
      stdout.write('account number :');
      int accountNumber = int.parse(stdin.readLineSync()!);
      stdout.write('name :');
      String name = stdin.readLineSync()!;
      stdout.write('Last name :');
      String lastname = stdin.readLineSync()!;
      stdout.write('number :');
      String phone = stdin.readLineSync()!;

      Customer customer = Customer(
        accountNumber: accountNumber,
        name: name,
        lastname: lastname,
        phone: phone,
      );
      bank.customers.add(customer);
      print('\n  CUSTOMER ADDED SUCCESSFULLY');
    }

    if (choice == '5') {
      print('\nGOOD BYE');
      break;
    }
    //print('\n I will add it later');
  }
}
