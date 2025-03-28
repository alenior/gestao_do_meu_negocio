import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../services/database_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CustomerFormScreen extends StatefulWidget {
  final Customer? customer;

  const CustomerFormScreen({super.key, this.customer});

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _taxIdController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  String? _imagePath;
  DateTime? _selectedBirthday; // novo campo

  @override
  void initState() {
    super.initState();
    if (widget.customer != null) {
      _nameController.text = widget.customer!.name;
      _taxIdController.text = widget.customer!.taxId ?? '';
      _addressController.text = widget.customer!.address;
      _phoneController.text = widget.customer!.phone;
      _emailController.text = widget.customer!.email ?? '';
      _imagePath = widget.customer!.imagePath;
      _selectedBirthday = widget.customer!.birthday;
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

  Future<void> _selectBirthday() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthday ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedBirthday) {
      setState(() {
        _selectedBirthday = picked;
      });
    }
  }

  Future<void> _saveCustomer() async {
    if (_formKey.currentState!.validate()) {
      final customer = Customer(
        id: widget.customer?.id,
        name: _nameController.text,
        taxId: _taxIdController.text.isEmpty ? null : _taxIdController.text,
        address: _addressController.text,
        phone: _phoneController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        imagePath: _imagePath,
        birthday: _selectedBirthday,
      );

      final db = DatabaseHelper();
      if (widget.customer == null) {
        await db.insertCustomer(customer);
      } else {
        await db.updateCustomer(customer);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.customer == null ? 'Novo Cliente' : 'Editar Cliente',
        ),
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
                controller: _taxIdController,
                decoration: const InputDecoration(
                  labelText: 'CPF/CNPJ (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // ... outros campos ...
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Data de Aniversário'),
                subtitle: Text(
                  _selectedBirthday != null
                      ? '${_selectedBirthday!.day}/${_selectedBirthday!.month}/${_selectedBirthday!.year}'
                      : 'Não selecionada',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectBirthday,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveCustomer,
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
