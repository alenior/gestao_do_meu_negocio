class Company {
  final int? id;
  final String name;
  final String taxId;
  final String address;
  final String phone;
  final String email;
  final String? imagePath;
  final List<CompanyGoal> goals;

  Company({
    this.id,
    required this.name,
    required this.taxId,
    required this.address,
    required this.phone,
    required this.email,
    this.imagePath,
    this.goals = const [],
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

  factory Company.fromMap(Map<String, dynamic> map) {
    return Company(
      id: map['id'],
      name: map['name'],
      taxId: map['taxId'],
      address: map['address'],
      phone: map['phone'],
      email: map['email'],
      imagePath: map['imagePath'],
      goals: (map['goals'] as List<dynamic>?)
          ?.map((goal) => CompanyGoal.fromMap(goal))
          .toList() ?? [],
    );
  }
}

class CompanyGoal {
  final int? id;
  final int companyId;
  final int month;
  final int year;
  final int targetQuantity;
  final double targetValue;

  CompanyGoal({
    this.id,
    required this.companyId,
    required this.month,
    required this.year,
    required this.targetQuantity,
    required this.targetValue,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'companyId': companyId,
      'month': month,
      'year': year,
      'targetQuantity': targetQuantity,
      'targetValue': targetValue,
    };
  }

  factory CompanyGoal.fromMap(Map<String, dynamic> map) {
    return CompanyGoal(
      id: map['id'],
      companyId: map['companyId'],
      month: map['month'],
      year: map['year'],
      targetQuantity: map['targetQuantity'],
      targetValue: map['targetValue'],
    );
  }
}