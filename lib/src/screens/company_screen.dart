import 'package:flutter/material.dart';
import 'dart:io';
import '../models/company.dart';
import '../services/database_helper.dart';
import 'company_form_screen.dart';

class CompanyScreen extends StatefulWidget {
  const CompanyScreen({super.key});

  @override
  State<CompanyScreen> createState() => _CompanyScreenState();
}

class _CompanyScreenState extends State<CompanyScreen> {
  Company? _company;

  @override
  void initState() {
    super.initState();
    _loadCompany();
  }

  Future<void> _loadCompany() async {
    final company = await DatabaseHelper().getCompany();
    setState(() {
      _company = company;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Empresa'),
      ),
      body: _company == null
          ? Center(
              child: ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CompanyFormScreen(),
                    ),
                  );
                  if (result == true) {
                    _loadCompany();
                  }
                },
                child: const Text('Cadastrar Empresa'),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_company!.imagePath != null)
                    Center(
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: FileImage(File(_company!.imagePath!)),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text('Nome: ${_company!.name}'),
                  Text('CNPJ: ${_company!.taxId}'),
                  Text('Endereço: ${_company!.address}'),
                  Text('Telefone: ${_company!.phone}'),
                  Text('Email: ${_company!.email}'),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CompanyFormScreen(company: _company),
                          ),
                        );
                        if (result == true) {
                          _loadCompany();
                        }
                      },
                      child: const Text('Editar'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}