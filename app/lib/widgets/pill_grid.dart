import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class PillGrid extends StatelessWidget {
  const PillGrid({
    super.key,
    this.highlightRows = const <int>{},
    this.completed = false,
    this.completedRows = const <int>{0, 1, 2},
    this.showLabels = true,
    this.compact = false,
    this.labels = rowLabels,
  });

  final Set<int> highlightRows;
  final bool completed;
  final Set<int> completedRows;
  final bool showLabels;
  final bool compact;
  final List<String> labels;

  static const rowLabels = ['早餐后', '午餐后', '晚餐后', '备用'];
  static const rowColors = [
    AppColors.breakfast,
    AppColors.lunch,
    AppColors.dinner,
    AppColors.spare,
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final labelWidth = showLabels ? (compact ? 34.0 : 48.0) : 0.0;
        final gap = compact ? 4.0 : 6.0;
        final cellWidth =
            (constraints.maxWidth - labelWidth - (gap * 6)) / 7;
        final cellHeight = compact ? cellWidth * 0.86 : cellWidth;

        return Column(
          children: List.generate(4, (row) {
            final active = highlightRows.contains(row);
            return Padding(
              padding: EdgeInsets.only(bottom: row == 3 ? 0 : gap),
              child: Row(
                children: [
                  if (showLabels)
                    SizedBox(
                      width: labelWidth,
                      child: Text(
                        compact ? labels[row].substring(0, 1) : labels[row],
                        style: TextStyle(
                          fontSize: compact ? 10 : 11,
                          fontWeight: FontWeight.w700,
                          color: active
                              ? rowColors[row]
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ...List.generate(7, (column) {
                    return Padding(
                      padding: EdgeInsets.only(right: column == 6 ? 0 : gap),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: cellWidth,
                        height: cellHeight,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: completed && completedRows.contains(row)
                              ? AppColors.successSoft
                              : active
                                  ? rowColors[row].withValues(alpha: 0.15)
                                  : const Color(0xFFF0F3F7),
                          borderRadius: BorderRadius.circular(compact ? 6 : 9),
                          border: Border.all(
                            color: completed && completedRows.contains(row)
                                ? AppColors.success
                                : active
                                    ? rowColors[row]
                                    : AppColors.divider,
                            width: active || (completed && completedRows.contains(row))
                                ? 1.5
                                : 1,
                          ),
                        ),
                        child: completed && completedRows.contains(row)
                            ? const Icon(
                                Icons.check_rounded,
                                color: AppColors.success,
                                size: 16,
                              )
                            : active
                                ? Text(
                                    '${column + 1}',
                                    style: TextStyle(
                                      color: rowColors[row],
                                      fontSize: compact ? 10 : 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  )
                                : null,
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}

Set<int> rowsForTimes(
  Iterable<String> times, {
  List<String> activeTimeSlots = const ['早餐后', '午餐后', '晚餐后'],
}) {
  if (activeTimeSlots.length == 1) return const {0, 1, 2, 3};
  if (activeTimeSlots.length == 2) {
    final rows = <int>{};
    if (times.contains(activeTimeSlots[0])) rows.addAll(const {0, 2});
    if (times.contains(activeTimeSlots[1])) rows.addAll(const {1, 3});
    return rows;
  }
  final rows = <int>{};
  for (var index = 0; index < activeTimeSlots.length; index += 1) {
    if (times.contains(activeTimeSlots[index])) rows.add(index);
  }
  return rows;
}
