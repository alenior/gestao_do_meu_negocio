import 'package:flutter/material.dart';
import 'dart:io';
import '../models/product.dart';
import '../services/database_helper.dart';
import 'product_form_screen.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final List<Product> _products = [];
  final List<Product> _filteredProducts = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final products = await DatabaseHelper().getAllProducts();
    setState(() {
      _products.clear();
      _products.addAll(products);
      _filterProducts(_searchController.text);
    });
  }

  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts.clear();
        _filteredProducts.addAll(_products);
      } else {
        _filteredProducts.clear();
        _filteredProducts.addAll(_products.where(
            (product) =>
                product.name.toLowerCase().contains(query.toLowerCase())));
      }
    });
  }

  Future<void> _deleteProduct(Product product) async {
    await DatabaseHelper().deleteProduct(product.id!);
    _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar produtos',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filterProducts,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: product.imagePath != null
                        ? CircleAvatar(
                            backgroundImage:
                                FileImage(File(product.imagePath!)),
                          )
                        : const CircleAvatar(
                            child: Icon(Icons.inventory),
                          ),
                    title: Text(product.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Fornecedor: ${product.supplierName}'),
                        Text(
                            'Preço: R\$ ${product.sellingPrice.toStringAsFixed(2)}'),
                        Text('Quantidade: ${product.quantity}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductFormScreen(product: product),
                              ),
                            );
                            if (result == true) {
                              _loadProducts();
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirmar exclusão'),
                              content: const Text(
                                  'Deseja realmente excluir este produto?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _deleteProduct(product);
                                  },
                                  child: const Text('Excluir'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProductFormScreen(),
            ),
          );
          if (result == true) {
            _loadProducts();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}