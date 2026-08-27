import 'package:flutter/material.dart';

import '../app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'completion_screen.dart';

enum NfcWriteState { ready, writing, success, failed }

class NfcWriteScreen extends StatefulWidget {
  const NfcWriteScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<NfcWriteScreen> createState() => _NfcWriteScreenState();
}

class _NfcWriteScreenState extends State<NfcWriteScreen>
    with SingleTickerProviderStateMixin {
  NfcWriteState _state = NfcWriteState.ready;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
      lowerBound: 0,
      upperBound: 1,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final writing = _state == NfcWriteState.writing;
    final success = _state == NfcWriteState.success;
    final failed = _state == NfcWriteState.failed;

    return PopScope(
      canPop: !writing,
      child: FlowScaffold(
        title: '写入格子板',
        step: 5,
        body: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
          child: Column(
            children: [
              PageIntro(
                eyebrow: '${widget.appState.selectedBoard.name} · 第 5 步',
                title: success
                    ? '写入成功'
                    : failed
                        ? '没有检测到格子板'
                        : writing
                            ? '保持手机不要移动'
                            : '用手机碰一碰 NFC 区域',
                description: success
                    ? '吃药计划已保存到格子板，可以盖回基座。'
                    : failed
                        ? '请确认 NFC 已开启，并将手机顶部贴近格子板右上角。'
                        : '将手机顶部靠近格子板右上角，听到提示音后继续保持约 2 秒。',
              ),
              const Spacer(),
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final pulse = writing || _state == NfcWriteState.ready
                      ? _pulseController.value
                      : 0.0;
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 196 + pulse * 24,
                        height: 196 + pulse * 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (success ? AppColors.success : AppColors.primary)
                              .withValues(alpha: 0.04 + (1 - pulse) * 0.04),
                        ),
                      ),
                      Container(
                        width: 158,
                        height: 158,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: success
                              ? AppColors.successSoft
                              : failed
                                  ? AppColors.errorSoft
                                  : AppColors.primarySoft,
                          border: Border.all(
                            width: 2,
                            color: success
                                ? AppColors.success
                                : failed
                                    ? AppColors.error
                                    : AppColors.primary,
                          ),
                        ),
                        child: Icon(
                          success
                              ? Icons.check_rounded
                              : failed
                                  ? Icons.nfc_rounded
                                  : Icons.nfc_rounded,
                          size: 76,
                          color: success
                              ? AppColors.success
                              : failed
                                  ? AppColors.error
                                  : AppColors.primary,
                        ),
                      ),
                      if (writing)
                        const SizedBox(
                          width: 186,
                          height: 186,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: AppColors.primary,
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 28),
              StatusPill(
                label: success
                    ? '计划已写入 · 28 格'
                    : failed
                        ? '等待重新连接'
                        : writing
                            ? '正在写入，请勿移开'
                            : '等待触碰',
                color: success
                    ? AppColors.success
                    : failed
                        ? AppColors.error
                        : AppColors.primary,
                background: success
                    ? AppColors.successSoft
                    : failed
                        ? AppColors.errorSoft
                        : AppColors.primarySoft,
              ),
              const Spacer(),
              if (!success)
                const InfoBanner(
                  text: '前端演示模式：此步骤模拟 NFC 发现、写入和结果反馈。',
                  icon: Icons.developer_mode_rounded,
                ),
            ],
          ),
        ),
        bottom: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: writing
                  ? null
                  : success
                      ? () {
                          widget.appState.finishBoard();
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => CompletionScreen(appState: widget.appState),
                            ),
                          );
                        }
                      : _write,
              child: Text(success
                  ? '完成排药'
                  : failed
                      ? '重新尝试'
                      : '模拟触碰并写入'),
            ),
            if (_state == NfcWriteState.ready) ...[
              const SizedBox(height: 6),
              TextButton(
                onPressed: () => setState(() => _state = NfcWriteState.failed),
                child: const Text('查看写入失败状态'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _write() async {
    setState(() => _state = NfcWriteState.writing);
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() => _state = NfcWriteState.success);
  }
}
