import 'package:flutter/material.dart';
import 'dart:io';
import '../models/company.dart';
import '../services/database_helper.dart';
import 'package:image_picker/image_picker.dart';

class CompanyFormScreen extends StatefulWidget {
  final Company? company;

  const CompanyFormScreen({super.key, this.company});

  @override
  State<CompanyFormScreen> createState() => _CompanyFormScreenState();
}

class _CompanyFormScreenState extends State<CompanyFormScreen> {
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
    if (widget.company != null) {
      _nameController.text = widget.company!.name;
      _taxIdController.text = widget.company!.taxId;
      _addressController.text = widget.company!.address;
      _phoneController.text = widget.company!.phone;
      _emailController.text = widget.company!.email;
      _imagePath = widget.company!.imagePath;
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

  Future<void> _saveCompany() async {
    if (_formKey.currentState!.validate()) {
      final company = Company(
        id: widget.company?.id,
        name: _nameController.text,
        taxId: _taxIdController.text,
        address: _addressController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        imagePath: _imagePath,
      );

      final db = DatabaseHelper();
      if (widget.company == null) {
        await db.insertCompany(company);
      } else {
        await db.updateCompany(company);
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
        title: Text(widget.company == null
            ? 'Cadastrar Empresa'
            : 'Editar Empresa'),
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
                onPressed: _saveCompany,
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