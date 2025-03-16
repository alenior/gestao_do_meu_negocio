import 'package:flutter/material.dart';
import 'dart:io';
import '../models/supplier.dart';
import '../services/database_helper.dart';
import 'package:image_picker/image_picker.dart';

class SupplierFormScreen extends StatefulWidget {
  final Supplier? supplier;

  const SupplierFormScreen({super.key, this.supplier});

  @override
  State<SupplierFormScreen> createState() => _SupplierFormScreenState();
}

class _SupplierFormScreenState extends State<SupplierFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _taxIdController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    if (widget.supplier != null) {
      _nameController.text = widget.supplier!.name;
      _taxIdController.text = widget.supplier!.taxId;
      _addressController.text = widget.supplier!.address;
      _phoneController.text = widget.supplier!.phone;
      _emailController.text = widget.supplier!.email;
      _imagePath = widget.supplier!.imagePath;
    }
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

  Future<void> _saveSupplier() async {
    if (_formKey.currentState!.validate()) {
      final supplier = Supplier(
        id: widget.supplier?.id,
        name: _nameController.text,
        taxId: _taxIdController.text,
        address: _addressController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        imagePath: _imagePath,
      );

      final db = DatabaseHelper();
      if (widget.supplier == null) {
        await db.insertSupplier(supplier);
      } else {
        await db.updateSupplier(supplier);
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
        title: Text(widget.supplier == null
            ? 'Novo Fornecedor'
            : 'Editar Fornecedor'),
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
                controller: _taxIdController,
                decoration: const InputDecoration(
                  labelText: 'CNPJ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o CNPJ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Endereço',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o endereço';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o telefone';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveSupplier,
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
    _taxIdController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}