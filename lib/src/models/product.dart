class Product {
  final int? id;
  final String code;
  final String name;
  final String description;
  final double purchasePrice;
  final List<ProductCost> additionalCosts;
  final double totalCost;
  final double profitMargin;
  final double sellingPrice;
  final int quantity;
  final int supplierId;
  final String? supplierName;
  final String? imagePath;

  Product({
    this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.purchasePrice,
    this.additionalCosts = const [],
    required this.profitMargin,
    required this.quantity,
    required this.supplierId,
    this.supplierName,
    this.imagePath,
  }) : totalCost = purchasePrice + additionalCosts.fold(0, (sum, cost) => sum + cost.value),
       sellingPrice = (purchasePrice + additionalCosts.fold(0, (sum, cost) => sum + cost.value)) * (1 + profitMargin / 100);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'purchasePrice': purchasePrice,
      'profitMargin': profitMargin,
      'sellingPrice': sellingPrice,
      'quantity': quantity,
      'supplierId': supplierId,
      'imagePath': imagePath,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      code: map['code'],
      name: map['name'],
      description: map['description'],
      purchasePrice: map['purchasePrice'],
      additionalCosts: (map['additionalCosts'] as List<dynamic>?)
          ?.map((cost) => ProductCost.fromMap(cost))
          .toList() ?? [],
      profitMargin: map['profitMargin'],
      quantity: map['quantity'],
      supplierId: map['supplierId'],
      supplierName: map['supplierName'],
      imagePath: map['imagePath'],
    );
  }
}

class ProductCost {
  final int? id;
  final int productId;
  final String name;
  final double value;

  ProductCost({
    this.id,
    required this.productId,
    required this.name,
    required this.value,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'value': value,
    };
  }

  factory ProductCost.fromMap(Map<String, dynamic> map) {
    return ProductCost(
      id: map['id'],
      productId: map['productId'],
      name: map['name'],
      value: map['value'],
    );
  }
}