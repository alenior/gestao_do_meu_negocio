import 'package:flutter/material.dart';
import '../models/quote.dart';
import '../models/customer.dart';
import '../models/product.dart';
import '../services/database_helper.dart';
import 'package:intl/intl.dart';

class QuoteFormScreen extends StatefulWidget {
  final Quote? quote;

  const QuoteFormScreen({super.key, this.quote});

  @override
  State<QuoteFormScreen> createState() => _QuoteFormScreenState();
}

class _QuoteFormScreenState extends State<QuoteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  List<Customer> _customers = [];
  List<Product> _products = [];
  Customer? _selectedCustomer;
  final List<QuoteItem> _items = [];
  String _status = 'Pendente';
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    _loadProducts();
    if (widget.quote != null) {
      _selectedCustomer = _customers.firstWhere(
        (customer) => customer.id == widget.quote!.customerId,
        orElse: () => _customers.first,
      );
      _date = widget.quote!.date;
      _status = widget.quote!.status;
      _items.addAll(widget.quote!.items);
    }
  }

  Future<void> _loadCustomers() async {
    final customers = await DatabaseHelper().getAllCustomers();
    setState(() {
      _customers = customers;
    });
  }

  Future<void> _loadProducts() async {
    final products = await DatabaseHelper().getAllProducts();
    setState(() {
      _products = products;
    });
  }

  void _addItem() {
    showDialog(
      context: context,
      builder: (context) {
        Product? selectedProduct;
        int quantity = 1;
        double price = 0;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Adicionar Item'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<Product>(
                    value: selectedProduct,
                    decoration: const InputDecoration(
                      labelText: 'Produto',
                      border: OutlineInputBorder(),
                    ),
                    items: _products.map((product) {
                      return DropdownMenuItem(
                        value: product,
                        child: Text(product.name),
                      );
                    }).toList(),
                    onChanged: (Product? value) {
                      setState(() {
                        selectedProduct = value;
                        if (value != null) {
                          price = value.sellingPrice;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: '1',
                    decoration: const InputDecoration(
                      labelText: 'Quantidade',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        quantity = int.tryParse(value) ?? 1;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: price.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Preço',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        price = double.tryParse(value) ?? 0;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    if (selectedProduct != null) {
                      setState(() {
                        _items.add(
                          QuoteItem(
                            quoteId: widget.quote?.id ?? 0,
                            productId: selectedProduct!.id!,
                            productName: selectedProduct!.name,
                            quantity: quantity,
                            price: price,
                            total: price * quantity,
                          ),
                        );
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Adicionar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
      });
    }
  }

  double _calculateTotal() {
    return _items.fold(0, (sum, item) => sum + item.total);
  }

  Future<void> _saveQuote() async {
    if (_formKey.currentState!.validate() && _selectedCustomer != null) {
      final quote = Quote(
        id: widget.quote?.id,
        customerId: _selectedCustomer!.id!,
        customerName: _selectedCustomer!.name,
        date: _date,
        total: _calculateTotal(),
        status: _status,
        items: _items,
      );

      final db = DatabaseHelper();
      if (widget.quote == null) {
        await db.insertQuote(quote);
      } else {
        await db.updateQuote(quote);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quote == null
            ? 'Novo Orçamento'
            : 'Editar Orçamento'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<Customer>(
                value: _selectedCustomer,
                decoration: const InputDecoration(
                  labelText: 'Cliente',
                  border: OutlineInputBorder(),
                ),
                items: _customers.map((customer) {
                  return DropdownMenuItem(
                    value: customer,
                    child: Text(customer.name),
                  );
                }).toList(),
                onChanged: (Customer? value) {
                  setState(() => _selectedCustomer = value);
                },
                validator: (value) {
                  if (value == null) return 'Selecione um cliente';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Data',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    DateFormat('dd/MM/yyyy').format(_date),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Pendente',
                    child: Text('Pendente'),
                  ),
                  DropdownMenuItem(
                    value: 'Aprovado',
                    child: Text('Aprovado'),
                  ),
                  DropdownMenuItem(
                    value: 'Rejeitado',
                    child: Text('Rejeitado'),
                  ),
                ],
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() => _status = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Itens',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addItem,
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar Item'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Card(
                    child: ListTile(
                      title: Text(item.productName),
                      subtitle: Text(
                          'Quantidade: ${item.quantity} - Preço: R\$ ${item.price.toStringAsFixed(2)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'R\$ ${item.total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _items.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'R\$ ${_calculateTotal().toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveQuote,
                  child: const Text('Salvar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}