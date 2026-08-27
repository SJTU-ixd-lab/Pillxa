import 'package:flutter/material.dart';

import 'models.dart';

class AppState extends ChangeNotifier {
  AppState(
      {required List<PillBoard> boards,
      required List<MedicationPlan> medications})
      : _boards = List<PillBoard>.of(boards),
        _medications = List<MedicationPlan>.of(medications);

  factory AppState.demo() {
    return AppState(
      boards: [
        PillBoard(
          id: 1,
          name: '格子板 01',
          status: BoardStatus.inUse,
          remainingDays: 3,
          lastUpdated: DateTime(2026, 8, 22),
        ),
        const PillBoard(id: 2, name: '格子板 02', status: BoardStatus.empty),
      ],
      medications: const [
        MedicationPlan(
          id: 'amlodipine',
          name: '苯磺酸氨氯地平片',
          dose: 2,
          unit: '片',
          times: ['午餐后'],
          color: Color(0xFF4C8BF5),
          source: '长期计划',
        ),
        MedicationPlan(
          id: 'metformin',
          name: '二甲双胍缓释片',
          dose: 1,
          unit: '片',
          times: ['早餐后', '晚餐后'],
          color: Color(0xFF37A87A),
          note: '随餐或餐后服用',
          source: '长期计划',
        ),
        MedicationPlan(
          id: 'atorvastatin',
          name: '阿托伐他汀钙片',
          dose: 2,
          unit: '片',
          times: ['晚餐后'],
          color: Color(0xFF8C6FF0),
          source: '长期计划',
        ),
        MedicationPlan(
          id: 'calcium',
          name: '碳酸钙D3片',
          dose: 3,
          unit: '片',
          times: ['午餐后'],
          color: Color(0xFFF09A36),
          source: '处方识别',
        ),
        MedicationPlan(
          id: 'calcitriol',
          name: '骨化三醇胶丸',
          dose: 3,
          unit: '粒',
          times: ['早餐后', '午餐后', '晚餐后'],
          color: Color(0xFFE35D75),
          source: '处方识别',
        ),
      ],
    );
  }

  final List<PillBoard> _boards;
  final List<MedicationPlan> _medications;
  int selectedBoardId = 2;
  int fillingMedicationIndex = 0;

  List<PillBoard> get boards => List.unmodifiable(_boards);
  List<MedicationPlan> get medications => List.unmodifiable(_medications);
  List<MedicationPlan> get activeMedications =>
      _medications.where((medication) => medication.enabled).toList();

  PillBoard get selectedBoard =>
      _boards.firstWhere((board) => board.id == selectedBoardId);

  List<String> get activeTimeSlots {
    const order = ['早餐后', '午餐后', '晚餐后', '睡前'];
    final used = activeMedications.expand((item) => item.times).toSet();
    return order.where(used.contains).toList();
  }

  int get maxDailyTimes {
    return activeTimeSlots.length.clamp(1, 4).toInt();
  }

  int get coverageDays {
    if (maxDailyTimes == 1) return 28;
    if (maxDailyTimes == 2) return 14;
    return 7;
  }

  int get usedSlots => coverageDays * maxDailyTimes;

  Set<int> get activeLayoutRows {
    if (maxDailyTimes <= 2) return const {0, 1, 2, 3};
    return Set<int>.from(List<int>.generate(maxDailyTimes, (index) => index));
  }

  List<String> get layoutRowLabels {
    if (maxDailyTimes == 1) return const ['第1周', '第2周', '第3周', '第4周'];
    if (maxDailyTimes == 2) {
      final first = activeTimeSlots.first;
      final second = activeTimeSlots.last;
      return ['1周$first', '1周$second', '2周$first', '2周$second'];
    }
    return [
      ...activeTimeSlots,
      ...List<String>.filled(4 - activeTimeSlots.length, '备用'),
    ];
  }

  void selectBoard(int id) {
    selectedBoardId = id;
    final index = _boards.indexWhere((board) => board.id == id);
    if (index >= 0 && _boards[index].status == BoardStatus.empty) {
      _boards[index] = _boards[index].copyWith(status: BoardStatus.filling);
    }
    notifyListeners();
  }

  void toggleMedication(String id, bool value) {
    final index = _medications.indexWhere((item) => item.id == id);
    if (index < 0) return;
    _medications[index] = _medications[index].copyWith(enabled: value);
    notifyListeners();
  }

  void addMedication(MedicationPlan medication) {
    _medications.add(medication);
    notifyListeners();
  }

  void replaceMedication(MedicationPlan medication) {
    final index = _medications.indexWhere((item) => item.id == medication.id);
    if (index < 0) return;
    _medications[index] = medication;
    notifyListeners();
  }

  void resetFillingProgress() {
    fillingMedicationIndex = 0;
    notifyListeners();
  }

  void nextMedication() {
    if (fillingMedicationIndex < activeMedications.length - 1) {
      fillingMedicationIndex += 1;
      notifyListeners();
    }
  }

  void previousMedication() {
    if (fillingMedicationIndex > 0) {
      fillingMedicationIndex -= 1;
      notifyListeners();
    }
  }

  void finishBoard() {
    final index = _boards.indexWhere((board) => board.id == selectedBoardId);
    if (index < 0) return;
    _boards[index] = _boards[index].copyWith(
      status: BoardStatus.ready,
      remainingDays: coverageDays,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
  }
}
