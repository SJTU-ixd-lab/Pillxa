import 'dart:async';

import 'package:flutter/material.dart';

import '../app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'prescription_review_screen.dart';

class PrescriptionCaptureScreen extends StatefulWidget {
  const PrescriptionCaptureScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<PrescriptionCaptureScreen> createState() => _PrescriptionCaptureScreenState();
}

class _PrescriptionCaptureScreenState extends State<PrescriptionCaptureScreen> {
  bool _processing = false;

  @override
  Widget build(BuildContext context) {
    return FlowScaffold(
      title: '识别处方',
      step: 1,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        children: [
          const PageIntro(
            eyebrow: '智能录入',
            title: '把处方完整放入框内',
            description: '保持光线充足、文字清晰，尽量避免折痕、反光和遮挡。',
          ),
          const SizedBox(height: 22),
          AspectRatio(
            aspectRatio: 0.78,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF18202B),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x25000000),
                    blurRadius: 24,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        width: 220,
                        height: 286,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F5EF),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 12),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Center(
                              child: Text(
                                '门 诊 处 方',
                                style: TextStyle(
                                  color: Color(0xFF24344D),
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 3,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            const _FakeLine(width: 118),
                            const SizedBox(height: 10),
                            const _FakeLine(width: 176),
                            const Divider(height: 26),
                            ...List.generate(
                              5,
                              (index) => const Padding(
                                padding: EdgeInsets.only(bottom: 10),
                                child: _FakeLine(width: double.infinity),
                              ),
                            ),
                            const Spacer(),
                            const Align(
                              alignment: Alignment.bottomRight,
                              child: Icon(Icons.draw_rounded,
                                  color: Color(0xFF5A6A81), size: 34),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Positioned.fill(
                    child: CustomPaint(painter: _CornerFramePainter()),
                  ),
                  if (_processing)
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.58),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(color: Colors.white),
                              SizedBox(height: 14),
                              Text('正在识别药品和用法…',
                                  style: TextStyle(color: Colors.white, fontSize: 15)),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LabeledIcon(icon: Icons.light_mode_outlined, label: '光线充足'),
              SizedBox(width: 18),
              LabeledIcon(icon: Icons.crop_free_rounded, label: '边缘完整'),
              SizedBox(width: 18),
              LabeledIcon(icon: Icons.text_fields_rounded, label: '文字清晰'),
            ],
          ),
        ],
      ),
      bottom: ElevatedButton.icon(
        onPressed: _processing ? null : _capture,
        icon: const Icon(Icons.camera_alt_rounded),
        label: Text(_processing ? '正在识别…' : '拍照并识别'),
      ),
    );
  }

  Future<void> _capture() async {
    setState(() => _processing = true);
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;
    setState(() => _processing = false);
    unawaited(
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => PrescriptionReviewScreen(appState: widget.appState),
        ),
      ),
    );
  }
}

class _FakeLine extends StatelessWidget {
  const _FakeLine({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 7,
      decoration: BoxDecoration(
        color: const Color(0xFFD4D7DB),
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}

class _CornerFramePainter extends CustomPainter {
  const _CornerFramePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    const inset = 26.0;
    const length = 34.0;
    const left = inset;
    const top = inset;
    final right = size.width - inset;
    final bottom = size.height - inset;

    canvas.drawLine(const Offset(left, top), const Offset(left + length, top), paint);
    canvas.drawLine(const Offset(left, top), const Offset(left, top + length), paint);
    canvas.drawLine(Offset(right, top), Offset(right - length, top), paint);
    canvas.drawLine(Offset(right, top), Offset(right, top + length), paint);
    canvas.drawLine(Offset(left, bottom), Offset(left + length, bottom), paint);
    canvas.drawLine(Offset(left, bottom), Offset(left, bottom - length), paint);
    canvas.drawLine(Offset(right, bottom), Offset(right - length, bottom), paint);
    canvas.drawLine(Offset(right, bottom), Offset(right, bottom - length), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
