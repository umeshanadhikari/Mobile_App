class Salary {
  final int slipId;
  final String regNumber;
  final double netSalary;
  final String month;
  final String name;
  final String address;
  final String year;

  Salary({
    required this.slipId,
    required this.regNumber,
    required this.netSalary,
    required this.month,
    required this.name,
    required this.address,
    required this.year,
  });

  factory Salary.fromJson(Map<String, dynamic> json) {
    return Salary(
      slipId: json['slip_id'],
      regNumber: json['regNumber'],
      netSalary: double.parse(json['net_salary'].toString()),
      month: json['month'],
      name: json['name'],
      address: json['address'],
      year: json['year'] ?? DateTime.now().year.toString(),
    );
  }
}