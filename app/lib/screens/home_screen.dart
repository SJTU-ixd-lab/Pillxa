import 'package:flutter/material.dart';
import '../app_state.dart';
import '../theme/app_theme.dart';
import 'board_overview_screen.dart';
import '../models/health_model.dart';
import '../models/medication_model.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final AppState _dispensingAppState = AppState.demo();

  bool _isCheckingHealth = false;
  HealthStatus? _healthStatus;
  String? _healthError;

  bool _isLoadingMedications = false;
  List<MedicationPlanItem>? _medications;
  String? _medicationsError;

  @override
  void initState() {
    super.initState();
    _triggerHealthCheck();
    _loadMedications();
  }

  @override
  void dispose() {
    _apiService.dispose();
    _dispensingAppState.dispose();
    super.dispose();
  }

  Future<void> _triggerHealthCheck() async {
    setState(() {
      _isCheckingHealth = true;
      _healthError = null;
    });

    try {
      final status = await _apiService.checkHealth();
      setState(() {
        _healthStatus = status;
        _isCheckingHealth = false;
      });
    } catch (e) {
      setState(() {
        _healthError = e.toString().replaceAll('Exception: ', '');
        _isCheckingHealth = false;
      });
    }
  }

  Future<void> _loadMedications() async {
    setState(() {
      _isLoadingMedications = true;
      _medicationsError = null;
    });

    try {
      final list = await _apiService.getTodayMedications();
      setState(() {
        _medications = list;
        _isLoadingMedications = false;
      });
    } catch (e) {
      setState(() {
        _medicationsError = e.toString().replaceAll('Exception: ', '');
        _isLoadingMedications = false;
      });
    }
  }

  void _showEditServerDialog() {
    final controller = TextEditingController(text: _apiService.baseUrl);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('服务器地址设置'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '可切换至本地开发环境或公网反代环境：',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Base URL',
                hintText: 'https://ixd.sjtu.edu.cn/pillxa-demo',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.text = ApiService.defaultBaseUrl;
            },
            child: const Text('重置公网'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                _apiService.baseUrl = controller.text.trim();
              });
              Navigator.pop(ctx);
              _triggerHealthCheck();
              _loadMedications();
            },
            child: const Text('保存并刷新'),
          ),
        ],
      ),
    );
  }

  void _openDispensingFlow() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Theme(
          data: AppTheme.light,
          child: BoardOverviewScreen(appState: _dispensingAppState),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.medication_liquid_outlined, color: Colors.teal),
            SizedBox(width: 8),
            Text('Pillxa 智能药盒', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: '服务器配置',
            onPressed: _showEditServerDialog,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            _triggerHealthCheck(),
            _loadMedications(),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // 当前服务器信息小卡片
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cloud_outlined,
                      size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '服务器: ${_apiService.baseUrl}',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.black87),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE8F5E9),
                  child: Icon(
                    Icons.grid_view_rounded,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                title: const Text(
                  '进入排药流程',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('创建吃药计划、识别处方并完成 4×7 格子板排药'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _openDispensingFlow,
              ),
            ),
            const SizedBox(height: 20),

            // 1. 服务健康状态探测卡片 (/health)
            _buildHealthCheckCard(theme),

            const SizedBox(height: 20),

            // 2. 今日服药计划列表 (/medications/today)
            _buildMedicationsCard(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthCheckCard(ThemeData theme) {
    Color statusColor = Colors.grey;
    String statusTitle = '未检测';
    String statusSubtitle = '点击下方按钮发起 /health 连通性探测';
    IconData statusIcon = Icons.help_outline;

    if (_isCheckingHealth) {
      statusColor = Colors.orange;
      statusTitle = '正在检测...';
      statusSubtitle = '正在请求后端 /health 接口';
      statusIcon = Icons.hourglass_top;
    } else if (_healthError != null) {
      statusColor = Colors.red;
      statusTitle = '连接失败';
      statusSubtitle = _healthError!;
      statusIcon = Icons.cancel_outlined;
    } else if (_healthStatus != null) {
      if (_healthStatus!.isHealthy) {
        statusColor = Colors.green;
        statusTitle = '服务正常 (status: ok)';
        statusSubtitle = '响应耗时: ${_healthStatus!.responseTimeMs ?? 0} ms';
        statusIcon = Icons.check_circle_outline;
      } else {
        statusColor = Colors.amber;
        statusTitle = '状态异常: ${_healthStatus!.status}';
        statusSubtitle = '服务已响应但状态非 ok';
        statusIcon = Icons.warning_amber_outlined;
      }
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        statusSubtitle,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isCheckingHealth ? null : _triggerHealthCheck,
                icon: _isCheckingHealth
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.refresh, size: 18),
                label: Text(_isCheckingHealth ? '探测中...' : '测试 /health 连通性'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationsCard(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 20, color: Colors.teal),
                    const SizedBox(width: 8),
                    Text(
                      '今日用药计划 (/medications/today)',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  tooltip: '刷新用药计划',
                  onPressed: _isLoadingMedications ? null : _loadMedications,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isLoadingMedications)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_medicationsError != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    '加载失败: $_medicationsError',
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),
              )
            else if (_medications == null || _medications!.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text('暂无用药记录', style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _medications!.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = _medications![index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal.shade50,
                      child: Text(
                        '${item.id}',
                        style: const TextStyle(
                            color: Colors.teal, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      '${item.meal} (${item.time})',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text('状态: ${item.status}'),
                    trailing: Chip(
                      label: Text(
                        item.status == 'completed' ? '已服用' : '待服药',
                        style: TextStyle(
                          fontSize: 12,
                          color: item.status == 'completed'
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                      backgroundColor: (item.status == 'completed'
                              ? Colors.green
                              : Colors.orange)
                          .withValues(alpha: 0.1),
                      side: BorderSide.none,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
