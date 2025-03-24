class Customer {
  final int? id;
  final String name;
  final String? taxId;  // CPF/CNPJ (opcional)
  final String address;
  final String phone;
  final String? email;  // opcional
  final String? imagePath;
  final DateTime? birthday;  // novo campo

  Customer({
    this.id,
    required this.name,
    this.taxId,
    required this.address,
    required this.phone,
    this.email,
    this.imagePath,
    this.birthday,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'tax_id': taxId,
      'address': address,
      'phone': phone,
      'email': email,
      'image_path': imagePath,
      'birthday': birthday?.millisecondsSinceEpoch,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      name: map['name'],
      taxId: map['tax_id'],
      address: map['address'],
      phone: map['phone'],
      email: map['email'],
      imagePath: map['image_path'],
      birthday: map['birthday'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['birthday'])
          : null,
    );
  }
}