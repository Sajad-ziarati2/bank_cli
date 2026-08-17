import 'dart:convert';
import 'dart:io';

import 'package:todo_app/bank.dart';
import 'package:todo_app/customer.dart';

const String customersFilePath = 'data/customers.json';

Future<void> main() async {
  final bank = Bank();

  final savedCustomers = await loadCustomers();
  bank.customers.addAll(savedCustomers);

  print('${bank.customers.length} customer(s) loaded.');

  while (true) {
    print('\n==== BANK CLI APP =====');
    print('1. Add customer');
    print('2. Remove customer');
    print('3. List customers');
    print('4. Export report as CSV');
    print('5. Exit');

    stdout.write('\nChoose an option: ');
    final choice = stdin.readLineSync()?.trim();

    switch (choice) {
      case '1':
        await addCustomer(bank);
        break;

      case '2':
        await removeCustomer(bank);
        break;

      case '3':
        listCustomers(bank);
        break;

      case '4':
        await exportCsv(bank);
        break;

      case '5':
        print('\nGoodbye.');
        return;

      default:
        print('Invalid option. Please enter a number from 1 to 5.');
    }
  }
}

Future<void> addCustomer(Bank bank) async {
 final accountNumber = generateAccountNumber(bank);

print('Generated account number: $accountNumber');

  stdout.write('Name: ');
  final name = stdin.readLineSync()?.trim() ?? '';

  stdout.write('Last name: ');
  final lastname = stdin.readLineSync()?.trim() ?? '';

  stdout.write('Phone: ');
  final phone = stdin.readLineSync()?.trim() ?? '';

  stdout.write('Starting balance: ');
  final balance = double.tryParse(stdin.readLineSync() ?? '') ?? 0;

  if (name.isEmpty || lastname.isEmpty || phone.isEmpty) {
    print('Name, last name, and phone are required.');
    return;
  }

  if (balance < 0) {
    print('Balance cannot be negative.');
    return;
  }

  final customer = Customer(
    accountNumber: accountNumber,
    name: name,
    balance: balance,
  );

  bank.customers.add(customer);

  await saveCustomers(bank.customers);

  print('\nCustomer added and saved successfully.');
}

Future<void> removeCustomer(Bank bank) async {
  if (bank.customers.isEmpty) {
    print('No customers found.');
    return;
  }

  stdout.write('Account number to remove: ');
  final accountNumber = int.tryParse(stdin.readLineSync() ?? '');

  if (accountNumber == null) {
    print('Account number is invalid.');
    return;
  }

  final customerExists = bank.customers.any(
    (customer) => customer.accountNumber == accountNumber,
  );

  if (!customerExists) {
    print('Customer not found.');
    return;
  }

  bank.customers.removeWhere(
    (customer) => customer.accountNumber == accountNumber,
  );

  await saveCustomers(bank.customers);

  print('Customer removed successfully.');
}

void listCustomers(Bank bank) {
  if (bank.customers.isEmpty) {
    print('No customers found.');
    return;
  }

  print('\n===== CUSTOMERS =====');

  for (final customer in bank.customers) {
    print('----------------------------');
    print('name: ${customer.name}');
    print('Account number: ${customer.accountNumber}');
    print('Balance: ${customer.balance}');
  }

  print('----------------------------');
}

Future<void> exportCsv(Bank bank) async {
  if (bank.customers.isEmpty) {
    print('No customers to export.');
    return;
  }

  final userProfile = Platform.environment['USERPROFILE'];

if (userProfile == null) {
  print('Could not find Downloads folder.');
  return;
}

final downloadsFolder = Directory('$userProfile\\Downloads');
final file = File('${downloadsFolder.path}\\customers_report.csv');
  final sink = file.openWrite();

  sink.writeln('accountNumber,name,lastname,phone,balance');

  for (final customer in bank.customers) {
    sink.writeln(
      '${escapeCsv(customer.accountNumber.toString())},'
      '${escapeCsv(customer.name)},'
      '${customer.balance}',
    );
  }

  await sink.close();

print('CSV exported successfully: ${file.path}');
}

String escapeCsv(String value) {
  final escapedValue = value.replaceAll('"', '""');

  if (escapedValue.contains(',') ||
      escapedValue.contains('"') ||
      escapedValue.contains('\n')) {
    return '"$escapedValue"';
  }

  return escapedValue;
}

Future<List<Customer>> loadCustomers() async {
  final file = File(customersFilePath);

  if (!await file.exists()) {
    return [];
  }

  try {
    final content = await file.readAsString();

    if (content.trim().isEmpty) {
      return [];
    }

    final List<dynamic> data = jsonDecode(content);

    return data.map((item) {
      final json = Map<String, dynamic>.from(item as Map);

      return Customer(
        accountNumber: (json['accountNumber'] as num).toInt(),
        name: json['name'] as String,
        balance: (json['balance'] as num).toDouble(),
      );
    }).toList();
  } catch (error) {
    print('Could not read customers.json: $error');
    return [];
  }
}

Future<void> saveCustomers(List<Customer> customers) async {
  final file = File(customersFilePath);

  await file.parent.create(recursive: true);

  final data = customers.map((customer) {
    return {
      'accountNumber': customer.accountNumber,
      'name': customer.name,
      'balance': customer.balance,
    };
  }).toList();

  await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
}

int generateAccountNumber(Bank bank) {
  if (bank.customers.isEmpty) {
    return 1;
  }

  final largestAccountNumber = bank.customers
      .map((customer) => customer.accountNumber)
      .reduce((a, b) => a > b ? a : b);

  return largestAccountNumber + 1;
}