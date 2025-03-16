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
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  List<Sale> _sales = [];
  double _totalRevenue = 0;
  int _totalSales = 0;
  Map<String, double> _productSales = {};
  Map<String, double> _customerSales = {};

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    final db = DatabaseHelper();
    final sales = await db.getSalesByDateRange(_startDate, _endDate);
    
    double totalRevenue = 0;
    Map<String, double> productSales = {};
    Map<String, double> customerSales = {};

    for (var sale in sales) {
      totalRevenue += sale.total;
      
      customerSales.update(
        sale.customerName,
        (value) => value + sale.total,
        ifAbsent: () => sale.total,
      );

      for (var item in sale.items) {
        productSales.update(
          item.productName,
          (value) => value + item.total,
          ifAbsent: () => item.total,
        );
      }
    }

    setState(() {
      _sales = sales;
      _totalRevenue = totalRevenue;
      _totalSales = sales.length;
      _productSales = productSales;
      _customerSales = customerSales;
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(
        start: _startDate,
        end: _endDate,
      ),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadReportData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Relatórios'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Resumo'),
              Tab(text: 'Produtos'),
              Tab(text: 'Clientes'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Período: ${DateFormat('dd/MM/yyyy').format(_startDate)} - ${DateFormat('dd/MM/yyyy').format(_endDate)}',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _selectDateRange(context),
                    child: const Text('Selecionar Período'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Resumo
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          child: ListTile(
                            title: const Text('Total de Vendas'),
                            trailing: Text(
                              _totalSales.toString(),
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Card(
                          child: ListTile(
                            title: const Text('Receita Total'),
                            trailing: Text(
                              'R\$ ${_totalRevenue.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Card(
                          child: ListTile(
                            title: const Text('Média por Venda'),
                            trailing: Text(
                              'R\$ ${(_totalSales > 0 ? _totalRevenue / _totalSales : 0).toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Produtos
                  ListView.builder(
                    itemCount: _productSales.length,
                    itemBuilder: (context, index) {
                      final product = _productSales.keys.elementAt(index);
                      final total = _productSales[product]!;
                      return ListTile(
                        title: Text(product),
                        trailing: Text('R\$ ${total.toStringAsFixed(2)}'),
                      );
                    },
                  ),
                  // Clientes
                  ListView.builder(
                    itemCount: _customerSales.length,
                    itemBuilder: (context, index) {
                      final customer = _customerSales.keys.elementAt(index);
                      final total = _customerSales[customer]!;
                      return ListTile(
                        title: Text(customer),
                        trailing: Text('R\$ ${total.toStringAsFixed(2)}'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}