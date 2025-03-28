import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import 'package:intl/intl.dart';
import '../models/sale.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final List<Sale> _sales = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  Future<void> _loadSales() async {
    setState(() => _isLoading = true);
    try {
      final db = DatabaseHelper();
      final sales = await db.getAllSales();
      setState(() {
        _sales.clear();
        _sales.addAll(sales);
      });
    } catch (e) {
      debugPrint('Erro ao carregar vendas: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Relatórios')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: _sales.length,
                itemBuilder: (context, index) {
                  final sale = _sales[index];
                  return ListTile(
                    title: Text('Venda #${sale.id}'),
                    subtitle: Text(
                      'Total: R\$ ${sale.total.toStringAsFixed(2)}',
                    ),
                    trailing: Text(DateFormat('dd/MM/yyyy').format(sale.date)),
                  );
                },
              ),
    );
  }
}
