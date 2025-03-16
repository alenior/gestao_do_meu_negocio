import 'package:flutter/material.dart';
import '../models/sale.dart';
import '../services/database_helper.dart';
import 'sale_form_screen.dart';
import 'package:intl/intl.dart';

class SaleScreen extends StatefulWidget {
  const SaleScreen({super.key});

  @override
  State<SaleScreen> createState() => _SaleScreenState();
}

class _SaleScreenState extends State<SaleScreen> {
  final List<Sale> _sales = [];
  final List<Sale> _filteredSales = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  Future<void> _loadSales() async {
    final sales = await DatabaseHelper().getAllSales();
    setState(() {
      _sales.clear();
      _sales.addAll(sales);
      _filterSales(_searchController.text);
    });
  }

  void _filterSales(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSales.clear();
        _filteredSales.addAll(_sales);
      } else {
        _filteredSales.clear();
        _filteredSales.addAll(_sales.where(
            (sale) =>
                sale.customerName.toLowerCase().contains(query.toLowerCase())));
      }
    });
  }

  Future<void> _deleteSale(Sale sale) async {
    await DatabaseHelper().deleteSale(sale.id!);
    _loadSales();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendas'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar vendas',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filterSales,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredSales.length,
              itemBuilder: (context, index) {
                final sale = _filteredSales[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text('Cliente: ${sale.customerName}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Data: ${DateFormat('dd/MM/yyyy').format(sale.date)}'),
                        Text('Total: R\$ ${sale.total.toStringAsFixed(2)}'),
                        Text('Status: ${sale.status}'),
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
                                    SaleFormScreen(sale: sale),
                              ),
                            );
                            if (result == true) {
                              _loadSales();
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
                                  'Deseja realmente excluir esta venda?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _deleteSale(sale);
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
              builder: (context) => const SaleFormScreen(),
            ),
          );
          if (result == true) {
            _loadSales();
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