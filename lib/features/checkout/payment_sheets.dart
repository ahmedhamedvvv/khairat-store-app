import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../widgets/common.dart';

/// Walks through the mock flow of each payment method. Returns true once "paid".
Future<bool> runPayment(BuildContext context, WidgetRef ref, PaymentMethod m, double total) async {
  final totalText = ref.money(context, total);
  final sheet = switch (m) {
    PaymentMethod.applePay => _ApplePaySheet(total: totalText),
    PaymentMethod.stcPay => _StcPaySheet(total: totalText),
    PaymentMethod.tabby => _TabbySheet(total: total),
    PaymentMethod.mada || PaymentMethod.cod => null,
  };
  final apple = m == PaymentMethod.applePay;
  final confirmed =
      sheet == null ||
      (await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            showDragHandle: !apple,
            backgroundColor: apple ? Colors.transparent : null,
            builder: (_) => sheet,
          ) ??
          false);
  if (!confirmed || !context.mounted) return false;
  if (m != PaymentMethod.cod && m != PaymentMethod.applePay) {
    await showDialog<void>(context: context, barrierDismissible: false, builder: (_) => const _ProcessingDialog());
  }
  return true;
}

class _ProcessingDialog extends StatefulWidget {
  const _ProcessingDialog();

  @override
  State<_ProcessingDialog> createState() => _ProcessingDialogState();
}

class _ProcessingDialogState extends State<_ProcessingDialog> {
  bool _done = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      setState(() => _done = true);
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) Navigator.pop(context);
      });
    });
  }

  @override
  Widget build(BuildContext context) => Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Tokens.cardRadius)),
    child: Padding(
      padding: const EdgeInsets.all(Tokens.s32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _done
                  ? const Icon(
                      Icons.check_circle_rounded,
                      key: ValueKey(1),
                      size: 64,
                      color: Palette.success,
                    ).animate().scale(begin: const Offset(0.3, 0.3), curve: Curves.elasticOut, duration: 700.ms)
                  : const CircularProgressIndicator(key: ValueKey(0), strokeWidth: 3),
            ),
          ),
          const SizedBox(height: Tokens.s16),
          Text(context.s.processing, style: context.text.titleMedium),
        ],
      ),
    ),
  );
}

class PaymentLogo extends StatelessWidget {
  const PaymentLogo.mada({super.key}) : kind = PaymentMethod.mada;
  const PaymentLogo.apple({super.key}) : kind = PaymentMethod.applePay;
  const PaymentLogo.stc({super.key}) : kind = PaymentMethod.stcPay;
  const PaymentLogo.tabby({super.key}) : kind = PaymentMethod.tabby;
  const PaymentLogo.cod({super.key}) : kind = PaymentMethod.cod;
  final PaymentMethod kind;

  @override
  Widget build(BuildContext context) {
    // Lettermarks, not the real trademarks.
    Widget box(Color bg, Widget child, {Color? border}) => Container(
      width: 52,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border ?? bg),
      ),
      child: child,
    );
    const t = TextStyle(fontFamily: Tokens.font, fontWeight: FontWeight.w700, fontSize: 13);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: switch (kind) {
        PaymentMethod.mada => box(
          Colors.white,
          const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'm',
                  style: TextStyle(color: Color(0xFF84B740)),
                ),
                TextSpan(
                  text: 'ada',
                  style: TextStyle(color: Color(0xFF259BD6)),
                ),
              ],
            ),
            style: t,
          ),
          border: const Color(0xFFE0E0E0),
        ),
        PaymentMethod.applePay => box(
          Colors.black,
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.apple, color: Colors.white, size: 16),
              Text(
                'Pay',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ],
          ),
        ),
        PaymentMethod.stcPay => box(
          const Color(0xFF4F008C),
          const Text(
            'stc pay',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11),
          ),
        ),
        PaymentMethod.tabby => box(
          const Color(0xFF3BFFC1),
          const Text(
            'tabby',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 13),
          ),
        ),
        PaymentMethod.cod => box(context.colors.primaryContainer, Icon(Icons.payments_rounded, size: 20, color: context.colors.primary)),
      },
    );
  }
}

class ApplePayButton extends StatelessWidget {
  const ApplePayButton({super.key, required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fg = dark ? Colors.black : Colors.white;
    return Material(
      color: dark ? Colors.white : Colors.black,
      borderRadius: BorderRadius.circular(Tokens.controlRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(Tokens.controlRadius),
        onTap: onPressed,
        child: SizedBox(
          height: 52,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Buy with ',
                  style: TextStyle(color: fg, fontSize: 17, fontWeight: FontWeight.w500),
                ),
                Icon(Icons.apple, color: fg, size: 22),
                Text(
                  'Pay',
                  style: TextStyle(color: fg, fontSize: 19, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ApplePaySheet extends StatefulWidget {
  const _ApplePaySheet({required this.total});
  final String total;

  @override
  State<_ApplePaySheet> createState() => _ApplePaySheetState();
}

class _ApplePaySheetState extends State<_ApplePaySheet> {
  // 0: waiting for side button, 1: Face ID scan, 2: done.
  int _phase = 0;

  void _confirm() {
    if (_phase != 0) return;
    HapticFeedback.mediumImpact();
    setState(() => _phase = 1);
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      setState(() => _phase = 2);
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) Navigator.pop(context, true);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF2F2F7);
    const ink = Colors.black;
    Widget row(String label, String value, {Widget? lead}) => Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFDADADF))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 13)),
          ),
          if (lead != null) ...[lead, const SizedBox(width: 8)],
          Expanded(
            child: Text(value, style: const TextStyle(color: ink, fontSize: 14)),
          ),
        ],
      ),
    );
    return Directionality(
      textDirection: TextDirection.ltr,
      child: GestureDetector(
        onTap: _confirm,
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(28)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.apple, size: 22, color: ink),
                  const Text(
                    'Pay',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: ink),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context, false),
                    icon: const Icon(Icons.cancel, color: Color(0xFFB0B0B5)),
                  ),
                ],
              ),
              row('CARD', 'mada •••• 4242\nAl Rajhi Bank', lead: const PaymentLogo.mada()),
              row('SHIP TO', 'Noura Al-Otaibi\nAl Malqa, Riyadh 13521'),
              row('CONTACT', '+966 55 123 4567'),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Text('PAY KHAIRAT', style: TextStyle(color: Color(0xFF8E8E93), fontSize: 13)),
                  const Spacer(),
                  Text(
                    widget.total,
                    style: const TextStyle(color: ink, fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _confirm,
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  height: 90,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: switch (_phase) {
                      0 => Column(
                        key: const ValueKey(0),
                        children: [
                          const Icon(
                            Icons.touch_app_rounded,
                            size: 40,
                            color: Color(0xFF007AFF),
                          ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(1, 1), end: const Offset(1.12, 1.12), duration: 700.ms),
                          const SizedBox(height: 8),
                          Text(context.s.applePayConfirm, style: const TextStyle(color: ink, fontSize: 15)),
                        ],
                      ),
                      1 => const Column(
                        key: ValueKey(1),
                        children: [
                          SizedBox(width: 44, height: 44, child: CircularProgressIndicator(strokeWidth: 3, color: Color(0xFF007AFF))),
                          SizedBox(height: 12),
                          Text('Face ID', style: TextStyle(color: ink, fontSize: 15)),
                        ],
                      ),
                      _ => Column(
                        key: const ValueKey(2),
                        children: [
                          const Icon(Icons.check_circle, size: 52, color: Color(0xFF34C759)).animate().scale(curve: Curves.elasticOut, duration: 600.ms),
                          const SizedBox(height: 8),
                          const Text('Done', style: TextStyle(color: ink, fontSize: 15)),
                        ],
                      ),
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().slideY(begin: 0.3, duration: 350.ms, curve: Curves.easeOutCubic);
  }
}

class _StcPaySheet extends StatefulWidget {
  const _StcPaySheet({required this.total});
  final String total;

  @override
  State<_StcPaySheet> createState() => _StcPaySheetState();
}

class _StcPaySheetState extends State<_StcPaySheet> {
  String _code = '';

  @override
  void initState() {
    super.initState();
    // Fill the code digit by digit, like an SMS autofill.
    for (var i = 1; i <= 4; i++) {
      Future.delayed(Duration(milliseconds: 600 + i * 180), () {
        if (mounted) setState(() => _code = '7391'.substring(0, i));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF4F008C);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Tokens.s24, 0, Tokens.s24, Tokens.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PaymentLogo.stc(),
            const SizedBox(height: Tokens.s16),
            Text(widget.total, style: context.text.headlineSmall),
            const SizedBox(height: Tokens.s8),
            Text(
              context.s.stcOtp,
              style: context.text.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Tokens.s16),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < 4; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: 52,
                      height: 58,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: i < _code.length ? purple : context.colors.outline, width: i < _code.length ? 2 : 1),
                      ),
                      child: Text(i < _code.length ? _code[i] : '', style: context.text.headlineSmall),
                    ),
                ],
              ),
            ),
            const SizedBox(height: Tokens.s24),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: purple, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(52)),
              onPressed: _code.length == 4 ? () => Navigator.pop(context, true) : null,
              child: Text(context.s.verify),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabbySheet extends ConsumerWidget {
  const _TabbySheet({required this.total});
  final double total;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = context.s;
    final part = total / 4;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Tokens.s24, 0, Tokens.s24, Tokens.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const PaymentLogo.tabby(),
                const SizedBox(width: 12),
                Text(s.tabbyPlan, style: context.text.titleLarge),
              ],
            ),
            const SizedBox(height: Tokens.s24),
            Row(
              children: [
                for (var i = 0; i < 4; i++)
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: CircularProgressIndicator(
                            value: (i + 1) / 4,
                            strokeWidth: 5,
                            color: const Color(0xFF292929),
                            backgroundColor: const Color(0xFF3BFFC1).withValues(alpha: 0.35),
                          ),
                        ).animate().scale(delay: (120 * i).ms, curve: Curves.easeOutBack),
                        const SizedBox(height: 8),
                        Text(ref.money(context, part), style: context.text.titleSmall),
                        Text(i == 0 ? s.tabbyToday : s.tabbyInMonths(i), style: context.text.labelSmall?.copyWith(color: context.colors.onSurfaceVariant)),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: Tokens.s24),
            SummaryRow(s.total, ref.money(context, total), bold: true),
            const SizedBox(height: Tokens.s16),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF292929), foregroundColor: Colors.white, minimumSize: const Size.fromHeight(52)),
              onPressed: () => Navigator.pop(context, true),
              child: Text(s.payAmount(ref.money(context, part))),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card entry with live formatting and brand detection. Prefilled for the demo.
class CardForm extends StatefulWidget {
  const CardForm({super.key});

  @override
  State<CardForm> createState() => _CardFormState();
}

class _CardFormState extends State<CardForm> {
  final _number = TextEditingController(text: '4464 0400 0000 4242');
  final _expiry = TextEditingController(text: '08/29');
  final _cvv = TextEditingController(text: '123');
  final _name = TextEditingController(text: 'NOURA ALOTAIBI');

  @override
  void dispose() {
    for (final c in [_number, _expiry, _cvv, _name]) {
      c.dispose();
    }
    super.dispose();
  }

  String _brand(String digits) {
    // A few real mada BIN prefixes; enough to show the detection.
    const madaBins = ['446404', '440647', '588845', '968208', '457865', '636120'];
    if (madaBins.any(digits.startsWith)) return 'mada';
    if (digits.startsWith('4')) return 'VISA';
    if (RegExp(r'^5[1-5]').hasMatch(digits)) return 'Mastercard';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final digits = _number.text.replaceAll(' ', '');
    final brand = _brand(digits);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        children: [
          // A small card preview that updates as you type.
          AspectRatio(
            aspectRatio: 1.7,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(colors: [Palette.oud, Color(0xFF7A4B2A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 26,
                        decoration: BoxDecoration(color: Palette.gold, borderRadius: BorderRadius.circular(5)),
                      ),
                      const Spacer(),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          brand,
                          key: ValueKey(brand),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    _number.text.isEmpty ? '•••• •••• •••• ••••' : _number.text,
                    style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 2, fontFeatures: [FontFeature.tabularFigures()]),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(_name.text, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ),
                      Text(_expiry.text, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Tokens.s12),
          TextField(
            controller: _number,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(16), _GroupFormatter(4, ' ')],
            decoration: InputDecoration(labelText: s.cardNumber, prefixIcon: const Icon(Icons.credit_card_rounded)),
          ),
          const SizedBox(height: Tokens.s12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _expiry,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4), _GroupFormatter(2, '/')],
                  decoration: InputDecoration(labelText: s.cardExpiry),
                ),
              ),
              const SizedBox(width: Tokens.s12),
              Expanded(
                child: TextField(
                  controller: _cvv,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
                  decoration: InputDecoration(labelText: s.cardCvv),
                ),
              ),
            ],
          ),
          const SizedBox(height: Tokens.s12),
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.characters,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(labelText: s.cardHolder),
          ),
        ],
      ),
    );
  }
}

class _GroupFormatter extends TextInputFormatter {
  _GroupFormatter(this.size, this.sep);
  final int size;
  final String sep;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final raw = newValue.text.replaceAll(sep, '');
    final b = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      if (i > 0 && i % size == 0 && (sep == ' ' || i == size)) b.write(sep);
      b.write(raw[i]);
    }
    final text = b.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
