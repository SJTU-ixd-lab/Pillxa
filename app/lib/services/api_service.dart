import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/health_model.dart';
import '../models/medication_model.dart';

class ApiService {
  // 默认公网部署 Base URL
  static const String defaultBaseUrl = 'https://ixd.sjtu.edu.cn/pillxa-demo';

  String baseUrl;
  final http.Client _client;

  ApiService({
    String? baseUrl,
    http.Client? client,
  })  : baseUrl = baseUrl ?? defaultBaseUrl,
        _client = client ?? http.Client();

  /// 探测后端健康检查接口 /health
  Future<HealthStatus> checkHealth() async {
    final uri = Uri.parse('$baseUrl/health');
    final stopwatch = Stopwatch()..start();

    try {
      final response = await _client.get(uri).timeout(
        const Duration(seconds: 5),
      );
      stopwatch.stop();

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return HealthStatus.fromJson(
          data,
          responseTimeMs: stopwatch.elapsedMilliseconds,
        );
      } else {
        throw Exception('服务器响应异常 (HTTP ${response.statusCode})');
      }
    } catch (e) {
      stopwatch.stop();
      rethrow;
    }
  }

  /// 获取今日服药计划 /medications/today
  Future<List<MedicationPlanItem>> getTodayMedications() async {
    final uri = Uri.parse('$baseUrl/medications/today');

    try {
      final response = await _client.get(uri).timeout(
        const Duration(seconds: 5),
      );

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(utf8.decode(response.bodyBytes));
        return list
            .map((item) => MedicationPlanItem.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('获取用药计划失败 (HTTP ${response.statusCode})');
      }
    } catch (e) {
      rethrow;
    }
  }

  void dispose() {
    _client.close();
  }
}
