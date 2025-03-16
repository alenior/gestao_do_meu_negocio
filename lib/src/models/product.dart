class Product {
  final int? id;
  final String name;
  final String description;
  final double costPrice;
  final double sellingPrice;
  final int quantity;
  final int supplierId;
  final String? supplierName;
  final String? imagePath;

  Product({
    this.id,
    required this.name,
    required this.description,
    required this.costPrice,
    required this.sellingPrice,
    required this.quantity,
    required this.supplierId,
    this.supplierName,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'costPrice': costPrice,
      'sellingPrice': sellingPrice,
      'quantity': quantity,
      'supplierId': supplierId,
      'imagePath': imagePath,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      costPrice: map['costPrice'],
      sellingPrice: map['sellingPrice'],
      quantity: map['quantity'],
      supplierId: map['supplierId'],
      supplierName: map['supplierName'],
      imagePath: map['imagePath'],
    );
  }
}
