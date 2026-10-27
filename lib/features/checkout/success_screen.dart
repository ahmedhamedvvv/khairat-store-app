import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../state/providers.dart';
import '../../widgets/common.dart';

class SuccessScreen extends ConsumerWidget {
  const SuccessScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = context.s;
    final order = ref.watch(orderProvider(id));
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go('/home');
      },
      child: Scaffold(
        body: Stack(
          children: [
            const Positioned.fill(child: IgnorePointer(child: _Confetti())),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(Tokens.s24),
                child: Column(
                  children: [
                    const Spacer(),
                    Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(color: Palette.success, shape: BoxShape.circle),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 72,
                        color: Colors.white,
                      ).animate().scale(delay: 250.ms, duration: 500.ms, curve: Curves.elasticOut).rotate(begin: -0.1, end: 0),
                    ).animate().scale(duration: 450.ms, curve: Curves.easeOutBack),
                    const SizedBox(height: Tokens.s24),
                    Text(s.orderPlaced, style: context.text.headlineMedium, textAlign: TextAlign.center).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),
                    const SizedBox(height: Tokens.s8),
                    Text(
                      s.orderPlacedBody(id),
                      style: context.text.bodyLarge?.copyWith(color: context.colors.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 400.ms),
                    if (order != null) ...[
                      const SizedBox(height: Tokens.s24),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(Tokens.s16),
                          child: Column(
                            children: [
                              SummaryRow(s.itemsCount(order.itemCount), ref.money(context, order.total), bold: true),
                              SummaryRow(s.paidWith, paymentLabel(context, order.payment)),
                              if (order.giftMessage != null) SummaryRow(s.giftMessage, '"${order.giftMessage}"'),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
                    ],
                    const Spacer(),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                      onPressed: () {
                        context.go('/orders');
                        context.push('/order/$id');
                      },
                      icon: const Icon(Icons.local_shipping_rounded),
                      label: Text(s.trackOrder),
                    ),
                    const SizedBox(height: Tokens.s12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(onPressed: () => context.push('/invoice/$id'), child: Text(s.viewInvoice)),
                        ),
                        const SizedBox(width: Tokens.s12),
                        Expanded(
                          child: OutlinedButton(onPressed: () => context.go('/home'), child: Text(s.continueShopping)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Confetti extends StatefulWidget {
  const _Confetti();

  @override
  State<_Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<_Confetti> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))..forward();
  final _rnd = math.Random(4);
  late final _bits = List.generate(70, (_) => (_rnd.nextDouble(), _rnd.nextDouble() * 0.4 + 0.6, _rnd.nextDouble() * 6.28, _rnd.nextInt(4)));

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (_, _) => CustomPaint(painter: _ConfettiPainter(_c.value, _bits)),
  );
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.t, this.bits);
  final double t;
  final List<(double, double, double, int)> bits;
  static const _colors = [Palette.gold, Palette.oud, Color(0xFF2F7D5B), Color(0xFFB4485A)];

  @override
  void paint(Canvas canvas, Size size) {
    if (t >= 1) return;
    for (final (x, speed, rot, color) in bits) {
      final y = -20 + (size.height + 40) * t * speed;
      final dx = x * size.width + math.sin(t * 8 + rot) * 18;
      canvas.save();
      canvas.translate(dx, y);
      canvas.rotate(rot + t * 10);
      canvas.drawRect(const Rect.fromLTWH(-4, -2, 8, 4), Paint()..color = _colors[color].withValues(alpha: (1 - t).clamp(0, 1)));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
