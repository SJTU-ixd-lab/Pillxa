class MedicationPlanItem {
  final int id;
  final String time;
  final String meal;
  final String status;

  MedicationPlanItem({
    required this.id,
    required this.time,
    required this.meal,
    required this.status,
  });

  factory MedicationPlanItem.fromJson(Map<String, dynamic> json) {
    return MedicationPlanItem(
      id: json['id'] as int? ?? 0,
      time: json['time'] as String? ?? '',
      meal: json['meal'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'time': time,
    'meal': meal,
    'status': status,
  };

  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';
}
