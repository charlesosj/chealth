class HealthDataPoint {
  final DateTime dateFrom;
  final DateTime dateTo;
  final String type;
  final String value;

  HealthDataPoint({
    required this.dateFrom,
    required this.dateTo,
    required this.type,
    required this.value,
  });

  factory HealthDataPoint.fromJson(Map<String, dynamic> json) {
    return HealthDataPoint(
      dateFrom: DateTime.parse(json['date_from']),
      dateTo: DateTime.parse(json['date_to']),
      type: json['type'],
      value: json['value'],
    );
  }
}
