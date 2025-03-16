import 'package:flutter/material.dart';
import 'dart:io';
import '../models/supplier.dart';
import '../services/database_helper.dart';
import 'supplier_form_screen.dart';

class SupplierScreen extends StatefulWidget {
  const SupplierScreen({super.key});

  @override
  State<SupplierScreen> createState() => _SupplierScreenState();
}

class _SupplierScreenState extends State<SupplierScreen> {
  final List<Supplier> _suppliers = [];
  final List<Supplier> _filteredSuppliers = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSuppliers();
  }

  Future<void> _loadSuppliers() async {
    final suppliers = await DatabaseHelper().getAllSuppliers();
    setState(() {
      _suppliers.clear();
      _suppliers.addAll(suppliers);
      _filterSuppliers(_searchController.text);
    });
  }

  void _filterSuppliers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSuppliers.clear();
        _filteredSuppliers.addAll(_suppliers);
      } else {
        _filteredSuppliers.clear();
        _filteredSuppliers.addAll(_suppliers.where(
            (supplier) =>
                supplier.name.toLowerCase().contains(query.toLowerCase())));
      }
    });
  }

  Future<void> _deleteSupplier(Supplier supplier) async {
    await DatabaseHelper().deleteSupplier(supplier.id!);
    _loadSuppliers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fornecedores'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar fornecedores',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filterSuppliers,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredSuppliers.length,
              itemBuilder: (context, index) {
                final supplier = _filteredSuppliers[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: supplier.imagePath != null
                        ? CircleAvatar(
                            backgroundImage:
                                FileImage(File(supplier.imagePath!)),
                          )
                        : const CircleAvatar(
                            child: Icon(Icons.business),
                          ),
                    title: Text(supplier.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CNPJ: ${supplier.taxId}'),
                        Text('Telefone: ${supplier.phone}'),
                      ],
                    ),
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
                                    SupplierFormScreen(supplier: supplier),
                              ),
                            );
                            if (result == true) {
                              _loadSuppliers();
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
                                  'Deseja realmente excluir este fornecedor?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _deleteSupplier(supplier);
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
              builder: (context) => const SupplierFormScreen(),
            ),
          );
          if (result == true) {
            _loadSuppliers();
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