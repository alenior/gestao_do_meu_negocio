import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../models/product.dart';
import '../services/database_helper.dart';
import 'package:image_picker/image_picker.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _profitMarginController = TextEditingController();
  final _quantityController = TextEditingController();
  final _additionalCosts = <ProductCost>[];
  String? _imagePath;
  int? _selectedSupplierId;
  double _totalCost = 0;
  double _sellingPrice = 0;
  final _currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _codeController.text = widget.product!.code;
      _nameController.text = widget.product!.name;
      _descriptionController.text = widget.product!.description;
      _purchasePriceController.text = widget.product!.purchasePrice.toString();
      _profitMarginController.text = widget.product!.profitMargin.toString();
      _quantityController.text = widget.product!.quantity.toString();
      _selectedSupplierId = widget.product!.supplierId;
      _imagePath = widget.product!.imagePath;
      _additionalCosts.addAll(widget.product!.additionalCosts);
      _calculatePrices();
    }
  }

  void _calculatePrices() {
    final purchasePrice =
        double.tryParse(_purchasePriceController.text.replaceAll(',', '.')) ??
        0;
    final additionalCostsTotal = _additionalCosts.fold(
      0.0,
      (sum, cost) => sum + cost.value,
    );
    final profitMargin =
        double.tryParse(_profitMarginController.text.replaceAll(',', '.')) ?? 0;

    setState(() {
      _totalCost = purchasePrice + additionalCostsTotal;
      _sellingPrice = _totalCost * (1 + profitMargin / 100);
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  void _addCost() {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        final valueController = TextEditingController();

        return AlertDialog(
          title: const Text('Adicionar Custo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nome do Custo'),
              ),
              TextField(
                controller: valueController,
                decoration: const InputDecoration(labelText: 'Valor'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
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
                final name = nameController.text;
                final value =
                    double.tryParse(
                      valueController.text.replaceAll(',', '.'),
                    ) ??
                    0;

                if (name.isNotEmpty && value > 0) {
                  setState(() {
                    _additionalCosts.add(
                      ProductCost(
                        productId: widget.product?.id ?? 0,
                        name: name,
                        value: value,
                      ),
                    );
                    _calculatePrices();
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Novo Produto' : 'Editar Produto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      _imagePath != null ? FileImage(File(_imagePath!)) : null,
                  child:
                      _imagePath == null
                          ? const Icon(Icons.camera_alt, size: 40)
                          : null,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Código do Produto',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o código do produto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a descrição';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _purchasePriceController,
                decoration: const InputDecoration(
                  labelText: 'Preço de Compra',
                  border: OutlineInputBorder(),
                  prefixText: 'R\$ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) => _calculatePrices(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o preço de compra';
                  }
                  return null;
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
                            'Custos Adicionais',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: _addCost,
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _additionalCosts.length,
                        itemBuilder: (context, index) {
                          final cost = _additionalCosts[index];
                          return ListTile(
                            title: Text(cost.name),
                            trailing: Text(_currencyFormat.format(cost.value)),
                            onTap: () {
                              setState(() {
                                _additionalCosts.removeAt(index);
                                _calculatePrices();
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
                    children: [
                      Text(
                        'Custo Total: ${_currencyFormat.format(_totalCost)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _profitMarginController,
                        decoration: const InputDecoration(
                          labelText: 'Margem de Lucro (%)',
                          border: OutlineInputBorder(),
                          suffixText: '%',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (_) => _calculatePrices(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira a margem de lucro';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Preço de Venda: ${_currencyFormat.format(_sellingPrice)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Lucro: ${_currencyFormat.format(_sellingPrice - _totalCost)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantidade',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a quantidade';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              FutureBuilder(
                future: DatabaseHelper().getAllSuppliers(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final suppliers = snapshot.data!;
                    return DropdownButtonFormField(
                      value: _selectedSupplierId,
                      decoration: const InputDecoration(
                        labelText: 'Fornecedor',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          suppliers.map((supplier) {
                            return DropdownMenuItem(
                              value: supplier.id,
                              child: Text(supplier.name),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSupplierId = value as int;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Por favor, selecione um fornecedor';
                        }
                        return null;
                      },
                    );
                  }
                  return const CircularProgressIndicator();
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveProduct,
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

    Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      try {
        final product = Product(
          id: widget.product?.id,
          code: _codeController.text,
          name: _nameController.text,
          description: _descriptionController.text,
          purchasePrice: double.parse(_purchasePriceController.text.replaceAll(',', '.')),
          additionalCosts: _additionalCosts,
          profitMargin: double.parse(_profitMarginController.text.replaceAll(',', '.')),
          quantity: int.parse(_quantityController.text),
          supplierId: _selectedSupplierId!,
          imagePath: _imagePath,
        );

        final db = DatabaseHelper();
        if (widget.product == null) {
          await db.insertProduct(product);
        } else {
          await db.updateProduct(product);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Produto salvo com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar o produto: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
