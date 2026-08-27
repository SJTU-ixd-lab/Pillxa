import 'package:flutter/material.dart';

import '../app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/pill_grid.dart';
import 'filling_guide_screen.dart';

class LayoutPreviewScreen extends StatelessWidget {
  const LayoutPreviewScreen({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        return FlowScaffold(
          title: '预览格子布局',
          step: 2,
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            children: [
              PageIntro(
                eyebrow: '${appState.selectedBoard.name} · 第 2 步',
                title: '这块板可覆盖 ${appState.coverageDays} 天',
                description:
                    '当前计划每天包含 ${appState.maxDailyTimes} 个服药时段，系统已将 28 个格子按时段排列。',
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('8月26日 - 9月1日',
                              style: Theme.of(context).textTheme.titleMedium),
                          const Spacer(),
                          StatusPill(label: '使用 ${appState.usedSlots}/28 格'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      PillGrid(
                        highlightRows: appState.activeLayoutRows,
                        labels: appState.layoutRowLabels,
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 14,
                        runSpacing: 8,
                        children: List.generate(
                          4,
                          (index) => _Legend(
                            color: PillGrid.rowColors[index],
                            label: appState.layoutRowLabels[index],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text('开始前的三个动作', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              const _PreparationStep(
                number: '1',
                icon: Icons.flip_to_front_rounded,
                title: '正面朝上',
                description: '确认看到全部格子编号和 NFC 标识。',
              ),
              const SizedBox(height: 10),
              const _PreparationStep(
                number: '2',
                icon: Icons.grid_on_rounded,
                title: '全部打开',
                description: '一次打开 28 个格子，避免放药时反复操作。',
              ),
              const SizedBox(height: 10),
              const _PreparationStep(
                number: '3',
                icon: Icons.medication_outlined,
                title: '药品放在手边',
                description: '核对药名和有效期，再按照引导逐一放入。',
              ),
              const SizedBox(height: 18),
              InfoBanner(
                text: appState.maxDailyTimes >= 3
                    ? '未使用的备用行请保持为空。'
                    : '同一服药时段会跨多行排列，请按周次标签依次放药。',
                icon: Icons.block_outlined,
                color: AppColors.textSecondary,
                background: const Color(0xFFEEF1F5),
              ),
            ],
          ),
          bottom: ElevatedButton.icon(
            onPressed: () {
              appState.resetFillingProgress();
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => FillingGuideScreen(appState: appState),
                ),
              );
            },
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('格子板已打开，开始排药'),
          ),
        );
      },
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _PreparationStep extends StatelessWidget {
  const _PreparationStep({
    required this.number,
    required this.icon,
    required this.title,
    required this.description,
  });

  final String number;
  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icon, color: AppColors.primary),
                ),
                Positioned(
                  top: -6,
                  left: -6,
                  child: Container(
                    width: 21,
                    height: 21,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(number,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        )),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 3),
                  Text(description, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
