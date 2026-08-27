import 'package:flutter/material.dart';

import '../app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/pill_grid.dart';
import 'nfc_write_screen.dart';

enum VerificationState { ready, checking, passed, needsReview }

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  VerificationState _state = VerificationState.ready;

  @override
  Widget build(BuildContext context) {
    final passed = _state == VerificationState.passed;
    final needsReview = _state == VerificationState.needsReview;
    return FlowScaffold(
      title: '拍照验药',
      step: 4,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          PageIntro(
            eyebrow: '${widget.appState.selectedBoard.name} · 第 4 步',
            title: passed
                ? '28 个格子检查完成'
                : needsReview
                    ? '有 2 个格子需要确认'
                    : '拍下整块格子板',
            description: passed
                ? '未发现明显漏放或位置错误，请在写入计划前做最后一次目视确认。'
                : needsReview
                    ? '系统无法确认 B3 和 C5，请按提示检查后重新拍摄。'
                : '保持格子板正面朝上，让 28 个格子全部出现在取景框内。',
          ),
          const SizedBox(height: 22),
          AspectRatio(
            aspectRatio: 1.08,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: passed
                    ? AppColors.successSoft
                    : needsReview
                        ? AppColors.errorSoft
                        : const Color(0xFF151D28),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: passed
                      ? AppColors.success
                      : needsReview
                          ? AppColors.error
                          : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 18)],
                      ),
                      child: PillGrid(
                        compact: true,
                        completed: passed,
                        completedRows: widget.appState.activeLayoutRows,
                        showLabels: true,
                        labels: widget.appState.layoutRowLabels,
                      ),
                    ),
                  ),
                  if (_state == VerificationState.checking)
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.64),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(color: Colors.white),
                              SizedBox(height: 14),
                              Text('正在检查 28 个格子…',
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (passed)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_rounded, color: Colors.white, size: 28),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (passed)
            InfoBanner(
              text: '检查通过：${widget.appState.usedSlots} 个计划格已放药，${28 - widget.appState.usedSlots} 个备用格保持为空。',
              icon: Icons.verified_rounded,
              color: AppColors.success,
              background: AppColors.successSoft,
            )
          else if (needsReview)
            const InfoBanner(
              text: 'B3：疑似漏放 · C5：数量可能不一致。请打开对应格子核对。',
              icon: Icons.error_outline_rounded,
              color: AppColors.error,
              background: AppColors.errorSoft,
            )
          else
            const InfoBanner(
              text: '演示版会模拟完成图像检查，不会上传或保存真实照片。',
              icon: Icons.lock_outline_rounded,
            ),
          if (passed || needsReview) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => setState(() => _state = VerificationState.ready),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(needsReview ? '核对完成，重新拍摄' : '重新拍摄'),
            ),
          ] else ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => setState(() => _state = VerificationState.needsReview),
              child: const Text('查看疑似错放状态'),
            ),
          ],
        ],
      ),
      bottom: ElevatedButton.icon(
        onPressed: _state == VerificationState.checking
            ? null
            : passed
                ? () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => NfcWriteScreen(appState: widget.appState),
                      ),
                    )
                : needsReview
                    ? () => setState(() => _state = VerificationState.ready)
                    : _verify,
        icon: Icon(passed ? Icons.nfc_rounded : Icons.camera_alt_rounded),
        label: Text(passed
            ? '下一步 · 写入格子板'
            : needsReview
                ? '重新拍摄'
                : '拍照并检查'),
      ),
    );
  }

  Future<void> _verify() async {
    setState(() => _state = VerificationState.checking);
    await Future<void>.delayed(const Duration(milliseconds: 1300));
    if (!mounted) return;
    setState(() => _state = VerificationState.passed);
  }
}
