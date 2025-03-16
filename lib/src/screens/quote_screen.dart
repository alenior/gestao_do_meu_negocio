import 'package:flutter/material.dart';
import '../models/quote.dart';
import '../services/database_helper.dart';
import 'quote_form_screen.dart';
import 'package:intl/intl.dart';

class QuoteScreen extends StatefulWidget {
  const QuoteScreen({super.key});

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  final List<Quote> _quotes = [];
  final List<Quote> _filteredQuotes = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadQuotes();
  }

  Future<void> _loadQuotes() async {
    final quotes = await DatabaseHelper().getAllQuotes();
    setState(() {
      _quotes.clear();
      _quotes.addAll(quotes);
      _filterQuotes(_searchController.text);
    });
  }

  void _filterQuotes(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredQuotes.clear();
        _filteredQuotes.addAll(_quotes);
      } else {
        _filteredQuotes.clear();
        _filteredQuotes.addAll(_quotes.where(
            (quote) =>
                quote.customerName.toLowerCase().contains(query.toLowerCase())));
      }
    });
  }

  Future<void> _deleteQuote(Quote quote) async {
    await DatabaseHelper().deleteQuote(quote.id!);
    _loadQuotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orçamentos'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar orçamentos',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filterQuotes,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredQuotes.length,
              itemBuilder: (context, index) {
                final quote = _filteredQuotes[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text('Cliente: ${quote.customerName}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Data: ${DateFormat('dd/MM/yyyy').format(quote.date)}'),
                        Text('Total: R\$ ${quote.total.toStringAsFixed(2)}'),
                        Text('Status: ${quote.status}'),
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
                                    QuoteFormScreen(quote: quote),
                              ),
                            );
                            if (result == true) {
                              _loadQuotes();
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
                                  'Deseja realmente excluir este orçamento?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _deleteQuote(quote);
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
              builder: (context) => const QuoteFormScreen(),
            ),
          );
          if (result == true) {
            _loadQuotes();
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