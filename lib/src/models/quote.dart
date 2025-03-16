class Quote {
  final int? id;
  final int customerId;
  final String customerName;
  final DateTime date;
  final double total;
  final String status;
  final List<QuoteItem> items;

  Quote({
    this.id,
    required this.customerId,
    required this.customerName,
    required this.date,
    required this.total,
    required this.status,
    required this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'date': date.toIso8601String(),
      'total': total,
      'status': status,
    };
  }

  factory Quote.fromMap(Map<String, dynamic> map) {
    return Quote(
      id: map['id'],
      customerId: map['customerId'],
      customerName: map['customerName'],
      date: DateTime.parse(map['date']),
      total: map['total'],
      status: map['status'],
      items: (map['items'] as List<dynamic>)
          .map((item) => QuoteItem.fromMap(item))
          .toList(),
    );
  }
}

class QuoteItem {
  final int? id;
  int quoteId;
  final int productId;
  final String productName;
  final int quantity;
  final double price;
  final double total;

  QuoteItem({
    this.id,
    required this.quoteId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.total,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quoteId': quoteId,
      'productId': productId,
      'quantity': quantity,
      'price': price,
      'total': total,
    };
  }

  factory QuoteItem.fromMap(Map<String, dynamic> map) {
    return QuoteItem(
      id: map['id'],
      quoteId: map['quoteId'],
      productId: map['productId'],
      productName: map['productName'],
      quantity: map['quantity'],
      price: map['price'],
      total: map['total'],
    );
  }
}
