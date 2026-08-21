import 'package:flutter_test/flutter_test.dart';
import 'package:pillxa_app/models/health_model.dart';
import 'package:pillxa_app/models/medication_model.dart';

void main() {
  group('HealthStatus Model Test', () {
    test('parses json correctly for healthy status', () {
      final json = {'status': 'ok'};
      final model = HealthStatus.fromJson(json, responseTimeMs: 45);

      expect(model.status, 'ok');
      expect(model.isHealthy, isTrue);
      expect(model.responseTimeMs, 45);
    });

    test('parses json correctly for non-ok status', () {
      final json = {'status': 'degraded'};
      final model = HealthStatus.fromJson(json);

      expect(model.status, 'degraded');
      expect(model.isHealthy, isFalse);
    });
  });

  group('MedicationPlanItem Model Test', () {
    test('parses medication item list correctly', () {
      final json = {
        'id': 1,
        'time': '08:00',
        'meal': '早餐',
        'status': 'pending',
      };
      final item = MedicationPlanItem.fromJson(json);

      expect(item.id, 1);
      expect(item.time, '08:00');
      expect(item.meal, '早餐');
      expect(item.status, 'pending');
      expect(item.isPending, isTrue);
      expect(item.isCompleted, isFalse);
    });
  });
}
