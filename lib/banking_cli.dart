import 'dart:convert';
import 'dart:io';
import 'package:todo_app/bank.dart';
import 'package:todo_app/customer.dart';
import 'package:todo_app/transaction.dart';

const String transactionsFilePath = 'data/transactions.json';
const String customersFilePath = 'data/customers.json';

Future<void> bankingcli() async {
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
    print('5. transections');
    print('6. Exit');

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
        await transiction(bank);
        break;

      case '6':
        print('\nGoodbye.');
        return;

      default:
        print('Invalid option. Please enter a number from 1 to 6.');
    }
  }
}

Future<void> addCustomer(Bank bank) async {
  final accountNumber = generateAccountNumber(bank);

  print('Generated account number: $accountNumber');

  final name = readValidName('Name: ');
  final lastname = readValidName('Lastname: ');
  final balance = readValidMoney('Starting balance: ');

  final now = DateTime.now();
  final createdAt = DateTime(
    now.year,
    now.month,
    now.day,
    now.hour,
    now.minute,
  );

  final customer = Customer(
    accountNumber: accountNumber,
    name: name,
    lastname: lastname,
    createdAt: createdAt,
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
    print('---------------------');
    print('NAME: ${customer.name}');
    print('LASTNAME: ${customer.lastname}');
    print('ACCOUNT NUMBER: ${customer.accountNumber}');
    final date = customer.createdAt;
    print(
      'CREATED AT: '
      '${date.year}/${date.month}/${date.day}    ${date.hour}:${date.minute}',
    );
    print('BALANCE: ${customer.balance} AF');
  }

  print('---------------------');
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

  sink.writeln('accountNumber,name,lastname,createdAt,balance');

  for (final customer in bank.customers) {
    sink.writeln(
      '${escapeCsv(customer.accountNumber.toString())},'
      '${escapeCsv(customer.name)},'
      '${escapeCsv(customer.lastname)},'
      '${customer.createdAt.toIso8601String()},'
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
      escapedValue.contains('\r') ||
      escapedValue.contains('\n')) {
    return '"$escapedValue"';
  }

  return escapedValue;
}

Future<void> transiction(Bank bank) async {
  if (bank.customers.isEmpty) {
    print('No customers found.');
    return;
  }

  stdout.write('Enter account number: ');
  final accountNumber = int.tryParse(stdin.readLineSync()?.trim() ?? '');

  if (accountNumber == null) {
    print('Invalid account number.');
    return;
  }

  Customer? selectedCustomer;

  for (final customer in bank.customers) {
    if (customer.accountNumber == accountNumber) {
      selectedCustomer = customer;
      break;
    }
  }

  if (selectedCustomer == null) {
    print('Customer not found.');
    return;
  }

  while (true) {
    print('\n===== TRANSACTION =====');
    print('1. show balance');
    print('2. Deposit');
    print('3. Withdraw');
    print('4. Show all transactions');
    print('5. Exit');

    stdout.write('Choose an option: ');
    final choice = stdin.readLineSync()?.trim();

    switch (choice) {
      case '1':
        print('Your balance is: ${selectedCustomer.balance}AF');
        break;

      case '2':
        final amount = readValidMoney('Deposit amount: ');

        if (amount <= 0) {
          print('Amount must be greater than zero.');
          break;
        }

        selectedCustomer.balance += amount;
        await saveCustomers(bank.customers);

        print('Deposit successful.');
        print('New balance: ${selectedCustomer.balance} AF');
        break;

      case '3':
        final amount = readValidMoney('Withdraw amount: ');

        if (amount <= 0) {
          print('Amount must be greater than zero.');
          break;
        }

        if (amount > selectedCustomer.balance) {
          print('Your balance is insufficient for this withdrawal.');
          break;
        }

        selectedCustomer.balance -= amount;
        await saveCustomers(bank.customers);
        

        print('Withdrawal successful.');
        print('New balance: ${selectedCustomer.balance} AF');
        break;

      case '4':
        await loadCustomers();
        break;

        
      case '5':
        print('Leaving transaction menu.');
        return;

      default:
        print('Invalid option. Enter 1, 2, 3,4, or 5.');
    }
  }
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
        lastname: json['lastname'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
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
      'lastname': customer.lastname,
      'createdAt': customer.createdAt.toIso8601String(),
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

bool isValidName(String value) {
  final namePattern = RegExp(
    r'^[a-zA-Z\u0621-\u064A\u067E\u0686\u0698\u06A9\u06AF\u06CC\u200C ]+$',
  );

  return value.trim().isNotEmpty && namePattern.hasMatch(value);
}

double? parseMoney(String input) {
  String value = input.trim();

  const persianDigits = '۰۱۲۳۴۵۶۷۸۹';
  const arabicDigits = '٠١٢٣٤٥٦٧٨٩';
  const englishDigits = '0123456789';

  for (int i = 0; i < 10; i++) {
    value = value.replaceAll(persianDigits[i], i.toString());
    value = value.replaceAll(arabicDigits[i], i.toString());
    value = value.replaceAll(englishDigits[i], i.toString());
  }

  value = value.replaceAll(',', '');
  value = value.replaceAll('٬', '');
  value = value.replaceAll('٫', '.');

  final moneyPattern = RegExp(r'^\d+(\.\d{1,2})?$');

  if (!moneyPattern.hasMatch(value)) {
    return null;
  }

  return double.parse(value);
}

String readValidName(String label) {
  while (true) {
    stdout.write(label);
    final value = stdin.readLineSync()?.trim() ?? '';

    if (isValidName(value)) {
      return value;
    }

    print('Only Persian or English letters are allowed. Try again.');
  }
}

double readValidMoney(String label) {
  while (true) {
    stdout.write(label);
    final value = parseMoney(stdin.readLineSync() ?? '');

    if (value != null) {
      return value;
    }

    print('Enter a valid non-negative amount. Try again.');
  }
}
