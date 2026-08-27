import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'layout_preview_screen.dart';
import 'prescription_capture_screen.dart';

class PlanSetupScreen extends StatelessWidget {
  const PlanSetupScreen({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final activeCount = appState.activeMedications.length;
        return FlowScaffold(
          title: '确认吃药计划',
          step: 1,
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            children: [
              PageIntro(
                eyebrow: '${appState.selectedBoard.name} · 第 1 步',
                title: '这次要排哪些药？',
                description: '已为李秀兰载入长期计划。你可以拍照识别新处方，也可以手动补充。',
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.document_scanner_outlined,
                      title: '识别处方',
                      subtitle: '拍照后逐项核对',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => PrescriptionCaptureScreen(appState: appState),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.add_circle_outline_rounded,
                      title: '手动添加',
                      subtitle: '录入药名与时间',
                      onTap: () => _showMedicationEditor(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Text('本次计划', style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  StatusPill(label: '$activeCount 种药'),
                ],
              ),
              const SizedBox(height: 12),
              ...appState.medications.map(
                (medication) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _MedicationCard(
                    medication: medication,
                    onChanged: (value) =>
                        appState.toggleMedication(medication.id, value),
                  ),
                ),
              ),
              const InfoBanner(
                text: '处方识别结果仅用于辅助录入。开始排药前，请按医生处方或药品标签逐项确认。',
                icon: Icons.health_and_safety_outlined,
                color: AppColors.warning,
                background: AppColors.warningSoft,
              ),
            ],
          ),
          bottom: ElevatedButton(
            onPressed: activeCount == 0
                ? null
                : () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => LayoutPreviewScreen(appState: appState),
                      ),
                    ),
            child: Text('下一步 · 预览格子布局（$activeCount 种药）'),
          ),
        );
      },
    );
  }

  Future<void> _showMedicationEditor(BuildContext context) async {
    final nameController = TextEditingController();
    final doseController = TextEditingController(text: '1');
    final result = await showModalBottomSheet<MedicationPlan>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _MedicationEditorSheet(
        nameController: nameController,
        doseController: doseController,
      ),
    );
    nameController.dispose();
    doseController.dispose();
    if (result != null) appState.addMedication(result);
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(height: 14),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 3),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _MedicationCard extends StatelessWidget {
  const _MedicationCard({required this.medication, required this.onChanged});

  final MedicationPlan medication;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: medication.enabled ? 1 : 0.55,
      duration: const Duration(milliseconds: 180),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
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
                    const SizedBox(height: 6),
                    Text(
                      '${medication.doseText} · ${medication.timeText}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    StatusPill(
                      label: medication.source,
                      color: medication.color,
                      background: medication.color.withValues(alpha: 0.10),
                    ),
                  ],
                ),
              ),
              Switch(
                value: medication.enabled,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MedicationEditorSheet extends StatefulWidget {
  const _MedicationEditorSheet({
    required this.nameController,
    required this.doseController,
  });

  final TextEditingController nameController;
  final TextEditingController doseController;

  @override
  State<_MedicationEditorSheet> createState() => _MedicationEditorSheetState();
}

class _MedicationEditorSheetState extends State<_MedicationEditorSheet> {
  final Set<String> _times = {'早餐后'};
  String _unit = '片';

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 4, 20, 20 + bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('手动添加药品', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 18),
            TextField(
              controller: widget.nameController,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(labelText: '药品名称'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.doseController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '每次数量'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _unit,
                    decoration: const InputDecoration(labelText: '单位'),
                    items: const ['片', '粒', '袋']
                        .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                        .toList(),
                    onChanged: (value) => setState(() => _unit = value ?? '片'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('服药时间', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['早餐后', '午餐后', '晚餐后'].map((time) {
                return FilterChip(
                  label: Text(time),
                  selected: _times.contains(time),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _times.add(time);
                      } else if (_times.length > 1) {
                        _times.remove(time);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: widget.nameController.text.trim().isEmpty
                  ? null
                  : () {
                      Navigator.of(context).pop(
                        MedicationPlan(
                          id: 'manual_${DateTime.now().millisecondsSinceEpoch}',
                          name: widget.nameController.text.trim(),
                          dose: int.tryParse(widget.doseController.text) ?? 1,
                          unit: _unit,
                          times: _times.toList(),
                          color: const Color(0xFF2BA3A0),
                          source: '手动添加',
                        ),
                      );
                    },
              child: const Text('保存到本次计划'),
            ),
          ],
        ),
      ),
    );
  }
}
