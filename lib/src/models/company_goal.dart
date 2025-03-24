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
      'company_id': companyId,
      'month': month,
      'year': year,
      'target_quantity': targetQuantity,
      'target_value': targetValue,
    };
  }

  factory CompanyGoal.fromMap(Map<String, dynamic> map) {
    return CompanyGoal(
      id: map['id'],
      companyId: map['company_id'],
      month: map['month'],
      year: map['year'],
      targetQuantity: map['target_quantity'],
      targetValue: map['target_value'],
    );
  }
}