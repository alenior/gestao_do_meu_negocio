import 'package:flutter/material.dart';
import 'dart:io';
import '../models/product.dart';
import '../models/supplier.dart';
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
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _quantityController = TextEditingController();
  String? _imagePath;
  List<Supplier> _suppliers = [];
  Supplier? _selectedSupplier;

  @override
  void initState() {
    super.initState();
    _loadSuppliers();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _descriptionController.text = widget.product!.description;
      _costPriceController.text = widget.product!.costPrice.toString();
      _sellingPriceController.text = widget.product!.sellingPrice.toString();
      _quantityController.text = widget.product!.quantity.toString();
      _imagePath = widget.product!.imagePath;
    }
  }

  Future<void> _loadSuppliers() async {
    final suppliers = await DatabaseHelper().getAllSuppliers();
    setState(() {
      _suppliers = suppliers;
      if (widget.product != null) {
        _selectedSupplier = _suppliers.firstWhere(
          (supplier) => supplier.id == widget.product!.supplierId,
        );
      }
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

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate() && _selectedSupplier != null) {
      final product = Product(
        id: widget.product?.id,
        name: _nameController.text,
        description: _descriptionController.text,
        costPrice: double.parse(_costPriceController.text),
        sellingPrice: double.parse(_sellingPriceController.text),
        quantity: int.parse(_quantityController.text),
        imagePath: _imagePath,
        supplierId: _selectedSupplier!.id!,
        supplierName: _selectedSupplier!.name,
      );

      final db = DatabaseHelper();
      if (widget.product == null) {
        await db.insertProduct(product);
      } else {
        await db.updateProduct(product);
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
        title: Text(widget.product == null
            ? 'Novo Produto'
            : 'Editar Produto'),
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
                  backgroundImage: _imagePath != null
                      ? FileImage(File(_imagePath!))
                      : null,
                  child: _imagePath == null
                      ? const Icon(Icons.camera_alt, size: 40)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Supplier>(
                value: _selectedSupplier,
                decoration: const InputDecoration(
                  labelText: 'Fornecedor',
                  border: OutlineInputBorder(),
                ),
                items: _suppliers.map((supplier) {
                  return DropdownMenuItem(
                    value: supplier,
                    child: Text(supplier.name),
                  );
                }).toList(),
                onChanged: (Supplier? value) {
                  setState(() => _selectedSupplier = value);
                },
                validator: (value) {
                  if (value == null) return 'Selecione um fornecedor';
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
                controller: _costPriceController,
                decoration: const InputDecoration(
                  labelText: 'Preço de Custo',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o preço de custo';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Por favor, insira um valor válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _sellingPriceController,
                decoration: const InputDecoration(
                  labelText: 'Preço de Venda',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o preço de venda';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Por favor, insira um valor válido';
                  }
                  return null;
                },
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
                  if (int.tryParse(value) == null) {
                    return 'Por favor, insira um valor válido';
                  }
                  return null;
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

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _costPriceController.dispose();
    _sellingPriceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }
}