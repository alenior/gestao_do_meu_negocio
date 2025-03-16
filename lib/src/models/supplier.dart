class Supplier {
  final int? id;
  final String name;
  final String taxId;
  final String address;
  final String phone;
  final String email;
  final String? imagePath;

  Supplier({
    this.id,
    required this.name,
    required this.taxId,
    required this.address,
    required this.phone,
    required this.email,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'taxId': taxId,
      'address': address,
      'phone': phone,
      'email': email,
      'imagePath': imagePath,
    };
  }

  factory Supplier.fromMap(Map<String, dynamic> map) {
    return Supplier(
      id: map['id'],
      name: map['name'],
      taxId: map['taxId'],
      address: map['address'],
      phone: map['phone'],
      email: map['email'],
      imagePath: map['imagePath'],
    );
  }
}