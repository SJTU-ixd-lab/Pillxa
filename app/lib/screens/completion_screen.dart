import 'package:flutter/material.dart';

import '../app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/pill_grid.dart';

class CompletionScreen extends StatelessWidget {
  const CompletionScreen({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 34, 20, 28),
            children: [
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: const BoxDecoration(
                    color: AppColors.successSoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: AppColors.success, size: 52),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                '排药完成',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '${appState.selectedBoard.name} 已准备好，可在当前格子板用完后替换。',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(appState.selectedBoard.name,
                              style: Theme.of(context).textTheme.titleLarge),
                          const Spacer(),
                          const StatusPill(
                            label: '待启用',
                            color: AppColors.warning,
                            background: AppColors.warningSoft,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      PillGrid(
                        compact: true,
                        completed: true,
                        completedRows: appState.activeLayoutRows,
                        labels: appState.layoutRowLabels,
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 15),
                      const _SummaryRow(
                        icon: Icons.calendar_today_outlined,
                        label: '覆盖周期',
                        value: '8月26日 - 9月1日',
                      ),
                      const SizedBox(height: 12),
                      _SummaryRow(
                        icon: Icons.medication_outlined,
                        label: '药品数量',
                        value: '${appState.activeMedications.length} 种',
                      ),
                      const SizedBox(height: 12),
                      _SummaryRow(
                        icon: Icons.grid_on_outlined,
                        label: '格子状态',
                        value:
                            '${appState.usedSlots} 格有药 · ${28 - appState.usedSlots} 格备用',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const InfoBanner(
                text: '请盖好全部格子，并将格子板正面朝下扣回基座或妥善保存。',
                icon: Icons.inventory_2_outlined,
                color: AppColors.warning,
                background: AppColors.warningSoft,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                child: const Text('返回排药首页'),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('排药记录摘要已生成（演示）')),
                ),
                icon: const Icon(Icons.ios_share_rounded),
                label: const Text('分享本次排药记录'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        Text(value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                )),
      ],
    );
  }
}
