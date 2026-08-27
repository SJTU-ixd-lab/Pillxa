import 'package:flutter_test/flutter_test.dart';
import 'package:pillxa_app/app_state.dart';
import 'package:pillxa_app/models.dart';

void main() {
  group('AppState', () {
    test('demo plan uses three time rows and covers seven days', () {
      final state = AppState.demo();

      expect(state.maxDailyTimes, 3);
      expect(state.coverageDays, 7);
      expect(state.usedSlots, 21);
      expect(state.activeMedications.length, 5);
    });

    test('selecting empty board changes it to filling', () {
      final state = AppState.demo();

      state.selectBoard(2);

      expect(state.selectedBoard.status, BoardStatus.filling);
    });

    test('two daily time slots cover fourteen days across four rows', () {
      final state = AppState.demo();
      for (final medication in state.medications) {
        state.toggleMedication(
          medication.id,
          medication.id == 'metformin',
        );
      }

      expect(state.maxDailyTimes, 2);
      expect(state.coverageDays, 14);
      expect(state.usedSlots, 28);
      expect(state.activeLayoutRows, {0, 1, 2, 3});
    });

    test('finishing board marks it ready', () {
      final state = AppState.demo();
      state.selectBoard(2);

      state.finishBoard();

      expect(state.selectedBoard.status, BoardStatus.ready);
      expect(state.selectedBoard.remainingDays, 7);
    });
  });
}
