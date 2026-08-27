import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class PrescriptionReviewScreen extends StatefulWidget {
  const PrescriptionReviewScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<PrescriptionReviewScreen> createState() => _PrescriptionReviewScreenState();
}

class _PrescriptionReviewScreenState extends State<PrescriptionReviewScreen> {
  final Set<String> _confirmed = {'calcium', 'calcitriol'};

  @override
  Widget build(BuildContext context) {
    final recognized = widget.appState.medications
        .where((medication) => medication.source == '处方识别')
        .toList();

    return FlowScaffold(
      title: '核对识别结果',
      step: 1,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          const PageIntro(
            eyebrow: '识别完成 · 2 种药',
            title: '请逐项核对后再保存',
            description: '重点检查药品名称、每次数量和服药时间。如有差异，可点击卡片修改。',
          ),
          const SizedBox(height: 18),
          const InfoBanner(
            text: '识别清晰度 96% · 处方日期 2026/03/12',
            icon: Icons.verified_outlined,
            color: AppColors.success,
            background: AppColors.successSoft,
          ),
          const SizedBox(height: 18),
          ...recognized.map(
            (medication) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ReviewCard(
                medication: medication,
                confirmed: _confirmed.contains(medication.id),
                onEdit: () => _editMedication(medication),
                onConfirmed: (value) {
                  setState(() {
                    if (value) {
                      _confirmed.add(medication.id);
                    } else {
                      _confirmed.remove(medication.id);
                    }
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 4),
          const InfoBanner(
            text: '本功能不判断处方是否合理，也不会改变医生给出的用药方案。',
            icon: Icons.warning_amber_rounded,
            color: AppColors.warning,
            background: AppColors.warningSoft,
          ),
        ],
      ),
      bottom: ElevatedButton(
        onPressed: _confirmed.length == recognized.length
            ? () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('识别结果已保存到本次计划')),
                );
                Navigator.of(context).pop();
              }
            : null,
        child: Text('确认并保存（${_confirmed.length}/${recognized.length}）'),
      ),
    );
  }

  Future<void> _editMedication(MedicationPlan medication) async {
    final nameController = TextEditingController(text: medication.name);
    final doseController = TextEditingController(text: medication.dose.toString());
    final times = medication.times.toSet();
    final updated = await showModalBottomSheet<MedicationPlan>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          final bottom = MediaQuery.viewInsetsOf(context).bottom;
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 20 + bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('修改识别结果',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 18),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: '药品名称'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: doseController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: '每次数量（${medication.unit}）'),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    children: ['早餐后', '午餐后', '晚餐后'].map((time) {
                      return FilterChip(
                        label: Text(time),
                        selected: times.contains(time),
                        onSelected: (selected) {
                          setSheetState(() {
                            if (selected) {
                              times.add(time);
                            } else if (times.length > 1) {
                              times.remove(time);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(
                      medication.copyWith(
                        name: nameController.text.trim().isEmpty
                            ? medication.name
                            : nameController.text.trim(),
                        dose: int.tryParse(doseController.text) ?? medication.dose,
                        times: times.toList(),
                      ),
                    ),
                    child: const Text('保存修改'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    nameController.dispose();
    doseController.dispose();
    if (updated != null) widget.appState.replaceMedication(updated);
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.medication,
    required this.confirmed,
    required this.onEdit,
    required this.onConfirmed,
  });

  final MedicationPlan medication;
  final bool confirmed;
  final VoidCallback onEdit;
  final ValueChanged<bool> onConfirmed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: medication.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(Icons.medication_rounded, color: medication.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(medication.name,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 5),
                      const StatusPill(
                        label: '识别置信度 97%',
                        color: AppColors.success,
                        background: AppColors.successSoft,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: '修改',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
            const SizedBox(height: 15),
            const Divider(height: 1),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _FieldLabel(label: '每次', value: medication.doseText)),
                Expanded(child: _FieldLabel(label: '时间', value: medication.timeText)),
              ],
            ),
            const SizedBox(height: 14),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text('我已与处方原件核对'),
              value: confirmed,
              onChanged: (value) => onConfirmed(value ?? false),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 3),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
