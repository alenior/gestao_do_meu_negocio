import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_helper.dart';
import '../models/company.dart';
import '../models/sale.dart';

class GoalDetailsScreen extends StatefulWidget {
  const GoalDetailsScreen({super.key});

  @override
  State<GoalDetailsScreen> createState() => _GoalDetailsScreenState();
}

class _GoalDetailsScreenState extends State<GoalDetailsScreen> {
  final _currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  Company? _company;
  List<Sale> _sales = [];
  CompanyGoal? _currentGoal;
  double _totalValue = 0;
  int _totalItems = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = DatabaseHelper();
    final company = await db.getCompany();
    final now = DateTime.now();
    final sales = await db.getSalesByDateRange(
      DateTime(now.year, now.month, 1),
      DateTime(now.year, now.month + 1, 0),
    );

    if (company != null) {
      final currentGoal = company.goals.firstWhere(
        (goal) => goal.month == now.month && goal.year == now.year,
        orElse: () => CompanyGoal(
          companyId: company.id!,
          month: now.month,
          year: now.year,
          targetQuantity: 0,
          targetValue: 0,
        ),
      );

      _totalValue = sales.fold(0.0, (sum, sale) => sum + sale.total);
      _totalItems = sales.fold(
        0,
        (sum, sale) =>
            sum + sale.items.fold(0, (itemSum, item) => itemSum + item.quantity),
      );

      setState(() {
        _company = company;
        _currentGoal = currentGoal;
        _sales = sales;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhamento das Metas'),
      ),
      body: _company == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Meta de Vendas: ${_currencyFormat.format(_currentGoal?.targetValue ?? 0)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Realizado: ${_currencyFormat.format(_totalValue)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Percentual: ${((_totalValue / (_currentGoal?.targetValue ?? 1)) * 100).round()}%',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Meta de Itens: ${_currentGoal?.targetQuantity ?? 0}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Realizado: $_totalItems',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Percentual: ${((_totalItems / (_currentGoal?.targetQuantity ?? 1)) * 100).round()}%',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Vendas do Mês',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _sales.length,
                    itemBuilder: (context, index) {
                      final sale = _sales[index];
                      final itemCount = sale.items.fold(
                        0,
                        (sum, item) => sum + item.quantity,
                      );
                      
                      return Card(
                        child: ListTile(
                          title: Text(
                            'Venda #${sale.id} - ${sale.customerName}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Data: ${DateFormat('dd/MM/yyyy').format(sale.date)}',
                              ),
                              Text('Quantidade de itens: $itemCount'),
                              Text(
                                'Valor: ${_currencyFormat.format(sale.total)}',
                              ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${((sale.total / (_currentGoal?.targetValue ?? 1)) * 100).toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              Text(
                                '${((itemCount / (_currentGoal?.targetQuantity ?? 1)) * 100).toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}