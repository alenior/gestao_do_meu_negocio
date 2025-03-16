class Sale {
  final int? id;
  final int customerId;
  final String customerName;
  final DateTime date;
  final double total;
  final String status;
  final List<PaymentMethod> paymentMethods;
  final String notes;
  final List<SaleItem> items;

  Sale({
    this.id,
    required this.customerId,
    required this.customerName,
    required this.date,
    required this.total,
    required this.status,
    required this.paymentMethods,
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
      paymentMethods: (map['paymentMethods'] as List<dynamic>)
          .map((method) => PaymentMethod.fromMap(method))
          .toList(),
      notes: map['notes'],
      items: (map['items'] as List<dynamic>)
          .map((item) => SaleItem.fromMap(item))
          .toList(),
    );
  }
}

class SaleItem {
  final int? id;
  final int saleId;
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
      'productName': productName,
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

class PaymentMethod {
  final int? id;
  final int saleId;
  final String type;
  final double amount;
  final int? installments;

  PaymentMethod({
    this.id,
    required this.saleId,
    required this.type,
    required this.amount,
    this.installments,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'saleId': saleId,
      'type': type,
      'amount': amount,
      'installments': installments,
    };
  }

  factory PaymentMethod.fromMap(Map<String, dynamic> map) {
    return PaymentMethod(
      id: map['id'],
      saleId: map['saleId'],
      type: map['type'],
      amount: map['amount'],
      installments: map['installments'],
    );
  }
}