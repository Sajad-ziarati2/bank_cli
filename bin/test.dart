import 'dart:io';

class Customer {
  String id;
  String name;
  String email;

  Customer(this.id, this.name, this.email);

  List<String> toCsvRow() => [id, name, email];
}

Future<void> main() async {
  final customers = <Customer>[];
  while (true) {
    print('\n==== BANK CLI APP =====');
    print('1. Add customer');
    print('2. Remove customer');
    print('3. List customers');
    print('4. Export report as CSV');
    print('5. Exit');

    stdout.write('\nChoose an option: ');
    final choice = stdin.readLineSync()?.trim();

    if (choice == null || choice.isEmpty) {
      print('No input provided. Please enter a number 1-5.');
      continue;
    }

    switch (choice) {
      case '1':
        addCustomer(customers);
        break;
      case '2':
        removeCustomer(customers);
        break;
      case '3':
        listCustomers(customers);
        break;
      case '4':
        await exportCsv(customers);
        break;
      case '5':
        print('\nGoodbye.');
        return;
      default:
        print('Invalid option: $choice. Please enter 1-5.');
    }
  }
}

void addCustomer(List<Customer> customers) {
  stdout.write('Enter customer id: ');
  final id = stdin.readLineSync()?.trim();
  stdout.write('Enter customer name: ');
  final name = stdin.readLineSync()?.trim();
  stdout.write('Enter customer email: ');
  final email = stdin.readLineSync()?.trim();

  if (id == null || id.isEmpty || name == null || name.isEmpty) {
    print('ID and name are required. Customer not added.');
    return;
  }

  if (customers.any((c) => c.id == id)) {
    print('A customer with id $id already exists. Customer not added.');
    return;
  }

  customers.add(Customer(id, name, email ?? ''));
  print('Customer added: $name (ID: $id)');
}

void removeCustomer(List<Customer> customers) {
  if (customers.isEmpty) {
    print('No customers to remove.');
    return;
  }
  stdout.write('Enter customer id to remove: ');
  final id = stdin.readLineSync()?.trim();
  if (id == null || id.isEmpty) {
    print('No id entered.');
    return;
  }

  final before = customers.length;
  customers.removeWhere((c) => c.id == id);
  final after = customers.length;

  if (after < before) {
    print('Customer with id $id removed.');
  } else {
    print('Customer with id $id not found.');
  }
}

void listCustomers(List<Customer> customers) {
  if (customers.isEmpty) {
    print('No customers.');
    return;
  }
  print('\nCustomers:');
  for (var c in customers) {
    print('- ${c.id}: ${c.name} ${c.email.isNotEmpty ? '<${c.email}>' : ''}');
  }
}

Future<void> exportCsv(List<Customer> customers) async {
  if (customers.isEmpty) {
    print('No customers to export.');
    return;
  }
  const filename = 'customers_report.csv';
  final file = File(filename);
  final sink = file.openWrite();
  sink.writeln('id,name,email');

  String escape(String s) {
    if (s.contains('"')) s = s.replaceAll('"', '""');
    if (s.contains(',') || s.contains('"') || s.contains('\n')) {
      return '"$s"';
    }
    return s;
  }

  for (var c in customers) {
    sink.writeln('${escape(c.id)},${escape(c.name)},${escape(c.email)}');
  }

  await sink.close();
  print('Exported ${customers.length} customers to $filename');
}