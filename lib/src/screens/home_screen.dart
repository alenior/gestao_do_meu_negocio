import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/company.dart';
import 'company_screen.dart';
import 'customer_screen.dart';
import 'supplier_screen.dart';
import 'product_screen.dart';
import 'quote_screen.dart';
import 'sale_screen.dart';
import 'reports_screen.dart';
import 'goal_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Company? _company;
  double _salesProgress = 0;
  int _itemsProgress = 0;

  @override
  void initState() {
    super.initState();
    _loadCompany();
  }

  Future<void> _loadCompany() async {
    final db = DatabaseHelper();
    final company = await db.getCompany();
    setState(() {
      _company = company;
    });
    if (company != null) {
      await _updateProgress();
    }
  }

  Future<void> _updateProgress() async {
    final db = DatabaseHelper();
    final now = DateTime.now();
    final sales = await db.getSalesByDateRange(
      DateTime(now.year, now.month, 1),
      DateTime(now.year, now.month + 1, 0),
    );

    final currentGoal = _company!.goals.firstWhere(
      (goal) => goal.month == now.month && goal.year == now.year,
      orElse: () => CompanyGoal(
        companyId: _company!.id!,
        month: now.month,
        year: now.year,
        targetQuantity: 0,
        targetValue: 0,
      ),
    );

    if (currentGoal.targetValue > 0) {
      final totalValue = sales.fold(0.0, (sum, sale) => sum + sale.total);
      setState(() {
        _salesProgress = (totalValue / currentGoal.targetValue).clamp(0.0, 1.0);
      });
    }

    if (currentGoal.targetQuantity > 0) {
      final totalItems = sales.fold(0, (sum, sale) =>
          sum + sale.items.fold(0, (itemSum, item) => itemSum + item.quantity));
      setState(() {
        _itemsProgress =
            ((totalItems / currentGoal.targetQuantity) * 100).round().clamp(0, 100);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão do Meu Negócio'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildMenuItem(
                  context,
                  'Minha Empresa',
                  Icons.business,
                  Colors.indigo,
                  const CompanyScreen(),
                ),
                _buildMenuItem(
                  context,
                  'Clientes',
                  Icons.people,
                  Colors.blue,
                  const CustomerScreen(),
                ),
                _buildMenuItem(
                  context,
                  'Fornecedores',
                  Icons.business,
                  Colors.green,
                  const SupplierScreen(),
                ),
                _buildMenuItem(
                  context,
                  'Produtos',
                  Icons.inventory,
                  Colors.orange,
                  const ProductScreen(),
                ),
                _buildMenuItem(
                  context,
                  'Orçamentos',
                  Icons.description,
                  Colors.purple,
                  const QuoteScreen(),
                ),
                _buildMenuItem(
                  context,
                  'Vendas',
                  Icons.shopping_cart,
                  Colors.red,
                  const SaleScreen(),
                ),
                _buildMenuItem(
                  context,
                  'Relatórios',
                  Icons.bar_chart,
                  Colors.teal,
                  const ReportsScreen(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_company != null) ...[
              Card(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GoalDetailsScreen(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Metas do Mês',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: _salesProgress,
                          backgroundColor: Colors.grey[200],
                          color: Colors.green,
                          minHeight: 10,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Vendas: ${(_salesProgress * 100).round()}%',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: _itemsProgress / 100,
                          backgroundColor: Colors.grey[200],
                          color: Colors.blue,
                          minHeight: 10,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Itens: $_itemsProgress%',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData icon,
      Color color, Widget screen) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}