import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/pill_grid.dart';
import 'plan_setup_screen.dart';

class BoardOverviewScreen extends StatelessWidget {
  const BoardOverviewScreen({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('排药'),
            actions: [
              IconButton(
                tooltip: '排药说明',
                onPressed: () => _showHelp(context),
                icon: const Icon(Icons.help_outline_rounded),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: [
                const PageIntro(
                  eyebrow: 'PILLXA SMART MEDICATION',
                  title: '准备下一周期的药',
                  description: '选择一块空置格子板，App 会按药品逐一引导放药，完成后再碰一碰写入计划。',
                ),
                const SizedBox(height: 22),
                const InfoBanner(
                  text: '格子板 01 还可使用约 3 天。建议现在准备格子板 02，避免出现空档。',
                  icon: Icons.notifications_active_outlined,
                  color: AppColors.warning,
                  background: AppColors.warningSoft,
                ),
                const SizedBox(height: 20),
                Text('我的格子板', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                ...appState.boards.map(
                  (board) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _BoardCard(
                      board: board,
                      onPressed: board.status == BoardStatus.inUse
                          ? null
                          : () {
                              appState.selectBoard(board.id);
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => PlanSetupScreen(appState: appState),
                                ),
                              );
                            },
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: AppColors.primarySoft,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.auto_awesome_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('固定动作，不怕中断',
                                  style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 3),
                              Text(
                                '从左到右、从上到下，随时退出都能继续。',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: 2,
            onDestinationSelected: (_) {},
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: '首页',
              ),
              NavigationDestination(
                icon: Icon(Icons.calendar_month_outlined),
                selectedIcon: Icon(Icons.calendar_month_rounded),
                label: '计划',
              ),
              NavigationDestination(
                icon: Icon(Icons.grid_view_outlined),
                selectedIcon: Icon(Icons.grid_view_rounded),
                label: '排药',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: '我的',
              ),
            ],
          ),
        );
      },
    );
  }

  void _showHelp(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => const SafeArea(
        minimum: EdgeInsets.fromLTRB(24, 8, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('排药前请确认',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            SizedBox(height: 18),
            _HelpRow(number: '1', text: '将格子板正面朝上，并把 28 个格子全部打开。'),
            SizedBox(height: 14),
            _HelpRow(number: '2', text: '准备好计划内的全部药品，核对名称和有效期。'),
            SizedBox(height: 14),
            _HelpRow(number: '3', text: '按照 App 高亮提示逐格放药，完成后统一检查。'),
          ],
        ),
      ),
    );
  }
}

class _BoardCard extends StatelessWidget {
  const _BoardCard({required this.board, this.onPressed});

  final PillBoard board;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isInUse = board.status == BoardStatus.inUse;
    final isReady = board.status == BoardStatus.ready;
    final statusColor = isInUse
        ? AppColors.success
        : isReady
            ? AppColors.warning
            : AppColors.primary;
    final statusBackground = isInUse
        ? AppColors.successSoft
        : isReady
            ? AppColors.warningSoft
            : AppColors.primarySoft;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: statusBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.grid_on_rounded, color: statusColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(board.name, style: Theme.of(context).textTheme.titleLarge),
                  ),
                  StatusPill(
                    label: board.status.label,
                    color: statusColor,
                    background: statusBackground,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              PillGrid(
                compact: true,
                completed: isInUse || isReady,
                showLabels: true,
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      isInUse
                          ? '预计还可使用 ${board.remainingDays} 天'
                          : isReady
                              ? '已完成 ${board.remainingDays} 天用药计划'
                              : board.status == BoardStatus.filling
                                  ? '上次排药尚未完成'
                                  : '可用于准备下一周期',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  if (onPressed != null)
                    Row(
                      children: [
                        Text(
                          board.status == BoardStatus.filling ? '继续排药' : '开始排药',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_rounded,
                            size: 18, color: AppColors.primary),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HelpRow extends StatelessWidget {
  const _HelpRow({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.primarySoft,
            shape: BoxShape.circle,
          ),
          child: Text(number,
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
      ],
    );
  }
}
