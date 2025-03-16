import 'package:flutter/material.dart';
import 'customer_screen.dart';
import 'supplier_screen.dart';
import 'product_screen.dart';
import 'quote_screen.dart';
import 'sale_screen.dart';
import 'reports_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão do Meu Negócio'),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
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