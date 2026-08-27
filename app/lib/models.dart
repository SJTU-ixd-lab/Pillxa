import 'package:flutter/material.dart';

enum BoardStatus { inUse, empty, filling, ready }

extension BoardStatusText on BoardStatus {
  String get label => switch (this) {
        BoardStatus.inUse => '使用中',
        BoardStatus.empty => '空置',
        BoardStatus.filling => '排药中',
        BoardStatus.ready => '待启用',
      };
}

class PillBoard {
  const PillBoard({
    required this.id,
    required this.name,
    required this.status,
    this.remainingDays = 0,
    this.lastUpdated,
  });

  final int id;
  final String name;
  final BoardStatus status;
  final int remainingDays;
  final DateTime? lastUpdated;

  PillBoard copyWith({
    BoardStatus? status,
    int? remainingDays,
    DateTime? lastUpdated,
  }) {
    return PillBoard(
      id: id,
      name: name,
      status: status ?? this.status,
      remainingDays: remainingDays ?? this.remainingDays,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class MedicationPlan {
  const MedicationPlan({
    required this.id,
    required this.name,
    required this.dose,
    required this.unit,
    required this.times,
    required this.color,
    this.note = '',
    this.enabled = true,
    this.source = '已有计划',
  });

  final String id;
  final String name;
  final int dose;
  final String unit;
  final List<String> times;
  final Color color;
  final String note;
  final bool enabled;
  final String source;

  String get doseText => '每次 $dose$unit';
  String get timeText => times.join('、');

  MedicationPlan copyWith({
    String? name,
    int? dose,
    String? unit,
    List<String>? times,
    String? note,
    bool? enabled,
    String? source,
  }) {
    return MedicationPlan(
      id: id,
      name: name ?? this.name,
      dose: dose ?? this.dose,
      unit: unit ?? this.unit,
      times: times ?? this.times,
      color: color,
      note: note ?? this.note,
      enabled: enabled ?? this.enabled,
      source: source ?? this.source,
    );
  }
}
