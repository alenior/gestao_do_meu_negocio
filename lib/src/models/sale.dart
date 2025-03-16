class Sale {
  final int? id;
  final int customerId;
  final String customerName;
  final DateTime date;
  final double total;
  final String status;
  final String paymentMethod;
  final String notes;
  final List<SaleItem> items;

  Sale({
    this.id,
    required this.customerId,
    required this.customerName,
    required this.date,
    required this.total,
    required this.status,
    required this.paymentMethod,
    required this.notes,
    required this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'date': date.toIso8601String(),
      'total': total,
      'status': status,
      'paymentMethod': paymentMethod,
      'notes': notes,
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'],
      customerId: map['customerId'],
      customerName: map['customerName'],
      date: DateTime.parse(map['date']),
      total: map['total'],
      status: map['status'],
      paymentMethod: map['paymentMethod'],
      notes: map['notes'],
      items: (map['items'] as List<dynamic>)
          .map((item) => SaleItem.fromMap(item))
          .toList(),
    );
  }
}

class SaleItem {
  final int? id;
  int saleId;
  final int productId;
  final String productName;
  final int quantity;
  final double price;
  final double discount;
  final double total;

  SaleItem({
    this.id,
    required this.saleId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.discount,
    required this.total,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'saleId': saleId,
      'productId': productId,
      'quantity': quantity,
      'price': price,
      'discount': discount,
      'total': total,
    };
  }

  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      id: map['id'],
      saleId: map['saleId'],
      productId: map['productId'],
      productName: map['productName'],
      quantity: map['quantity'],
      price: map['price'],
      discount: map['discount'],
      total: map['total'],
    );
  }
}
