import 'package:flutter/material.dart';
import 'dart:io';
import '../models/customer.dart';
import '../services/database_helper.dart';
import 'customer_form_screen.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  final List<Customer> _customers = [];
  final List<Customer> _filteredCustomers = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    final customers = await DatabaseHelper().getAllCustomers();
    setState(() {
      _customers.clear();
      _customers.addAll(customers);
      _filterCustomers(_searchController.text);
    });
  }

  void _filterCustomers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCustomers.clear();
        _filteredCustomers.addAll(_customers);
      } else {
        _filteredCustomers.clear();
        _filteredCustomers.addAll(_customers.where(
            (customer) =>
                customer.name.toLowerCase().contains(query.toLowerCase())));
      }
    });
  }

  Future<void> _deleteCustomer(Customer customer) async {
    await DatabaseHelper().deleteCustomer(customer.id!);
    _loadCustomers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar clientes',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filterCustomers,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCustomers.length,
              itemBuilder: (context, index) {
                final customer = _filteredCustomers[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: customer.imagePath != null
                        ? CircleAvatar(
                            backgroundImage:
                                FileImage(File(customer.imagePath!)),
                          )
                        : const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                    title: Text(customer.name),
                    subtitle: Text(customer.phone),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CustomerFormScreen(customer: customer),
                              ),
                            );
                            if (result == true) {
                              _loadCustomers();
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirmar exclusão'),
                              content: const Text(
                                  'Deseja realmente excluir este cliente?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _deleteCustomer(customer);
                                  },
                                  child: const Text('Excluir'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CustomerFormScreen(),
            ),
          );
          if (result == true) {
            _loadCustomers();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}