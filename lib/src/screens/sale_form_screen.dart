import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/sale.dart';
import '../models/product.dart';
import '../services/database_helper.dart';

class SaleFormScreen extends StatefulWidget {
  final Sale? sale;

  const SaleFormScreen({super.key, this.sale});

  @override
  State<SaleFormScreen> createState() => _SaleFormScreenState();
}

class _SaleFormScreenState extends State<SaleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  int? _selectedCustomerId;
  List<SaleItem> _items = [];
  List<PaymentMethod> _paymentMethods = [];
  double _total = 0;

  @override
  void initState() {
    super.initState();
    if (widget.sale != null) {
      _selectedCustomerId = widget.sale!.customerId;
      _notesController.text = widget.sale!.notes;
      _items = List.from(widget.sale!.items);
      _paymentMethods = List.from(widget.sale!.paymentMethods);
      _calculateTotal();
    }
  }

  void _calculateTotal() {
    setState(() {
      _total = _items.fold(0, (sum, item) => sum + item.total);
    });
  }

  void _addPaymentMethod() {
    showDialog(
      context: context,
      builder: (context) {
        String selectedType = 'Espécie';
        final amountController = TextEditingController();
        int? installments;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Adicionar Forma de Pagamento'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Forma de Pagamento',
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Espécie', child: Text('Espécie')),
                      DropdownMenuItem(value: 'Pix', child: Text('Pix')),
                      DropdownMenuItem(
                        value: 'Cartão de Crédito',
                        child: Text('Cartão de Crédito'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedType = value!;
                        if (value != 'Cartão de Crédito') {
                          installments = null;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: amountController,
                    decoration: const InputDecoration(
                      labelText: 'Valor',
                      prefixText: 'R\$ ',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  if (selectedType == 'Cartão de Crédito') ...[
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: installments,
                      decoration: const InputDecoration(
                        labelText: 'Número de Parcelas',
                      ),
                      items: List.generate(12, (index) {
                        return DropdownMenuItem(
                          value: index + 1,
                          child: Text('${index + 1}x'),
                        );
                      }),
                      onChanged: (value) {
                        setState(() {
                          installments = value;
                        });
                      },
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    final amount = double.tryParse(
                            amountController.text.replaceAll(',', '.')) ??
                        0;
                    if (amount > 0 &&
                        (selectedType != 'Cartão de Crédito' ||
                            installments != null)) {
                      setState(() {
                        _paymentMethods.add(
                          PaymentMethod(
                            saleId: widget.sale?.id ?? 0,
                            type: selectedType,
                            amount: amount,
                            installments: installments,
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

    void _addItem() async {
    final result = await showDialog<SaleItem>(
      context: context,
      builder: (context) => ProductSelectionDialog(
        existingItems: _items,
        saleId: widget.sale?.id ?? 0,
      ),
    );

    if (result != null) {
      setState(() {
        _items.add(result);
        _calculateTotal();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sale == null ? 'Nova Venda' : 'Editar Venda'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder(
                future: DatabaseHelper().getAllCustomers(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final customers = snapshot.data!;
                    return DropdownButtonFormField(
                      value: _selectedCustomerId,
                      decoration: const InputDecoration(
                        labelText: 'Cliente',
                        border: OutlineInputBorder(),
                      ),
                      items: customers.map((customer) {
                        return DropdownMenuItem(
                          value: customer.id,
                          child: Text(customer.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCustomerId = value as int;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Por favor, selecione um cliente';
                        }
                        return null;
                      },
                    );
                  }
                  return const CircularProgressIndicator();
                },
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                          IconButton(
                            onPressed: _addItem,
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return ListTile(
                            title: Text(item.productName),
                            subtitle: Text(
                              'Quantidade: ${item.quantity} x ${_currencyFormat.format(item.price)}',
                            ),
                            trailing: Text(_currencyFormat.format(item.total)),
                            onTap: () {
                              setState(() {
                                _items.removeAt(index);
                                _calculateTotal();
                              });
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Formas de Pagamento',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: _addPaymentMethod,
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _paymentMethods.length,
                        itemBuilder: (context, index) {
                          final payment = _paymentMethods[index];
                          return ListTile(
                            title: Text(payment.type),
                            subtitle: payment.installments != null
                                ? Text('${payment.installments}x')
                                : null,
                            trailing: Text(_currencyFormat.format(payment.amount)),
                            onTap: () {
                              setState(() {
                                _paymentMethods.removeAt(index);
                              });
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Observações',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Text(
                'Total: ${_currencyFormat.format(_total)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _saveSale,
                  child: const Text('Salvar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveSale() async {
    if (_formKey.currentState!.validate() &&
        _items.isNotEmpty &&
        _paymentMethods.isNotEmpty) {
      final totalPayments =
          _paymentMethods.fold(0.0, (sum, payment) => sum + payment.amount);

      if (totalPayments != _total) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('O valor total dos pagamentos deve ser igual ao total da venda'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final sale = Sale(
        id: widget.sale?.id,
        customerId: _selectedCustomerId!,
        customerName: '',  // Será preenchido pelo banco de dados
        date: DateTime.now(),
        total: _total,
        status: 'Confirmada',
        paymentMethods: _paymentMethods,
        notes: _notesController.text,
        items: _items,
      );

      final db = DatabaseHelper();
      if (widget.sale == null) {
        await db.insertSale(sale);
      } else {
        await db.updateSale(sale);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}

class ProductSelectionDialog extends StatefulWidget {
  final List<SaleItem> existingItems;
  final int saleId;

  const ProductSelectionDialog({
    super.key,
    required this.existingItems,
    required this.saleId,
  });

  @override
  State<ProductSelectionDialog> createState() => _ProductSelectionDialogState();
}

class _ProductSelectionDialogState extends State<ProductSelectionDialog> {
  Product? _selectedProduct;
  final _quantityController = TextEditingController(text: '1');
  final _discountController = TextEditingController(text: '0');
  double _total = 0;

  void _calculateTotal() {
    if (_selectedProduct != null) {
      final quantity = int.tryParse(_quantityController.text) ?? 0;
      final discount = double.tryParse(_discountController.text.replaceAll(',', '.')) ?? 0;
      setState(() {
        _total = (_selectedProduct!.sellingPrice * quantity) * (1 - discount / 100);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar Item'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FutureBuilder(
            future: DatabaseHelper().getAllProducts(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final products = snapshot.data!;
                return DropdownButtonFormField<Product>(
                  value: _selectedProduct,
                  decoration: const InputDecoration(
                    labelText: 'Produto',
                  ),
                  items: products.map((product) {
                    return DropdownMenuItem(
                      value: product,
                      child: Text(product.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedProduct = value;
                      _calculateTotal();
                    });
                  },
                );
              }
              return const CircularProgressIndicator();
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _quantityController,
            decoration: const InputDecoration(
              labelText: 'Quantidade',
            ),
            keyboardType: TextInputType.number,
            onChanged: (_) => _calculateTotal(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _discountController,
            decoration: const InputDecoration(
              labelText: 'Desconto (%)',
              suffixText: '%',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => _calculateTotal(),
          ),
          const SizedBox(height: 16),
          Text(
            'Total: ${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(_total)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
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
            if (_selectedProduct != null) {
              final quantity = int.tryParse(_quantityController.text) ?? 0;
              final discount =
                  double.tryParse(_discountController.text.replaceAll(',', '.')) ?? 0;

              if (quantity > 0) {
                Navigator.pop(
                  context,
                  SaleItem(
                    saleId: widget.saleId,  // Use the parameter here
                    productId: _selectedProduct!.id!,
                    productName: _selectedProduct!.name,
                    quantity: quantity,
                    price: _selectedProduct!.sellingPrice,
                    discount: discount,
                    total: _total,
                  ),
                );
              }
            }
          },
          child: const Text('Adicionar'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _discountController.dispose();
    super.dispose();
  }
}