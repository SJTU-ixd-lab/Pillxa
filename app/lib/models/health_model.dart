class HealthStatus {
  final String status;
  final int? responseTimeMs;

  HealthStatus({
    required this.status,
    this.responseTimeMs,
  });

  factory HealthStatus.fromJson(Map<String, dynamic> json, {int? responseTimeMs}) {
    return HealthStatus(
      status: json['status'] as String? ?? 'unknown',
      responseTimeMs: responseTimeMs,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    if (responseTimeMs != null) 'responseTimeMs': responseTimeMs,
  };

  bool get isHealthy => status.toLowerCase() == 'ok';
}
