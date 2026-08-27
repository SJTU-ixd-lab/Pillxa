import 'package:flutter/material.dart';

import '../app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/pill_grid.dart';
import 'verification_screen.dart';

class FillingGuideScreen extends StatelessWidget {
  const FillingGuideScreen({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final medications = appState.activeMedications;
        final index =
            appState.fillingMedicationIndex.clamp(0, medications.length - 1).toInt();
        final medication = medications[index];
        final isLast = index == medications.length - 1;
        final progress = (index + 1) / medications.length;

        return FlowScaffold(
          title: '逐一排药',
          step: 3,
          actions: [
            TextButton(
              onPressed: () => _confirmExit(context),
              child: const Text('保存退出'),
            ),
          ],
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            children: [
              Row(
                children: [
                  StatusPill(label: '第 ${index + 1}/${medications.length} 种药'),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        minHeight: 8,
                        value: progress,
                        backgroundColor: AppColors.divider,
                        color: medication.color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${(progress * 100).round()}%',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          color: medication.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(Icons.medication_rounded,
                            size: 34, color: medication.color),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(medication.name,
                                style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 7),
                            Text(
                              '${medication.doseText} · ${medication.timeText}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                            if (medication.note.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(medication.note,
                                  style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text('把药放入高亮格子', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(
                '每个高亮格放 ${medication.dose}${medication.unit}，按从左到右的顺序操作。',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 14),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: PillGrid(
                    highlightRows: rowsForTimes(
                      medication.times,
                      activeTimeSlots: appState.activeTimeSlots,
                    ),
                    labels: appState.layoutRowLabels,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              InfoBanner(
                text: '本步共需放入 ${medication.times.length * appState.coverageDays * medication.dose} ${medication.unit}。放完后请再次核对高亮格。',
                icon: Icons.calculate_outlined,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(Icons.pause_circle_outline_rounded,
                      size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      '临时离开也没关系，进度会保留在当前药品。',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
          ),
          bottom: Row(
            children: [
              if (index > 0) ...[
                SizedBox(
                  width: 104,
                  child: OutlinedButton(
                    onPressed: appState.previousMedication,
                    child: const Text('上一步'),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (isLast) {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => VerificationScreen(appState: appState),
                        ),
                      );
                    } else {
                      appState.nextMedication();
                    }
                  },
                  icon: Icon(isLast ? Icons.check_rounded : Icons.arrow_forward_rounded),
                  label: Text(isLast ? '全部放好了' : '已放好，下一种药'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmExit(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('保存当前进度？'),
        content: const Text('下次进入格子板 02 时，会从当前药品继续。'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('继续排药')),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('保存并退出'),
          ),
        ],
      ),
    );
  }
}
