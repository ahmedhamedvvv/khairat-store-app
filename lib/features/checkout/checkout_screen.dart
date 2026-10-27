import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../state/providers.dart';
import '../../widgets/common.dart';
import '../cart/cart_screen.dart';
import 'payment_sheets.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int _step = 0;
  int _scheduledDay = 1;

  void _next() {
    if (_step < 2) {
      setState(() => _step++);
    } else {
      _pay();
    }
  }

  Future<void> _pay() async {
    final draft = ref.read(checkoutProvider);
    final total = ref.read(totalsProvider).total;
    final ok = await runPayment(context, ref, draft.payment, total);
    if (!ok || !mounted) return;
    final order = ref.read(ordersProvider.notifier).placeFromCart();
    context.go('/success/${order.id}');
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final draft = ref.watch(checkoutProvider);
    final t = ref.watch(totalsProvider);
    if (ref.watch(cartLinesProvider).isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyState(icon: Icons.shopping_bag_outlined, title: s.cartEmpty, action: s.startShopping, onAction: () => context.go('/home')),
      );
    }
    final steps = [s.stepAddress, s.stepDelivery, s.stepPayment];

    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _step--);
      },
      child: Scaffold(
        appBar: AppBar(title: Text(s.checkout)),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(Tokens.s16, 0, Tokens.s16, Tokens.s8),
              child: Row(
                children: [
                  for (var i = 0; i < steps.length; i++) ...[
                    Expanded(
                      child: GestureDetector(
                        onTap: i < _step ? () => setState(() => _step = i) : null,
                        child: Column(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: 4,
                              decoration: BoxDecoration(
                                color: i <= _step ? context.colors.primary : context.colors.outline,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              steps[i],
                              style: context.text.labelMedium?.copyWith(
                                color: i <= _step ? context.colors.primary : context.colors.onSurfaceVariant,
                                fontWeight: i == _step ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (i < steps.length - 1) const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (c, a) => FadeTransition(
                  opacity: a,
                  child: SlideTransition(
                    position: Tween(begin: const Offset(0.06, 0), end: Offset.zero).animate(a),
                    child: c,
                  ),
                ),
                child: KeyedSubtree(
                  key: ValueKey(_step),
                  child: ListView(
                    padding: const EdgeInsets.all(Tokens.s16),
                    children: [
                      ...switch (_step) {
                        0 => _addressStep(draft),
                        1 => _deliveryStep(draft),
                        _ => _paymentStep(draft, t.total),
                      },
                      const SizedBox(height: Tokens.s16),
                      TotalsCard(totals: t),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(Tokens.s16, Tokens.s8, Tokens.s16, Tokens.s12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_step == 2)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline_rounded, size: 14, color: context.colors.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(s.paymentMock, style: context.text.labelSmall?.copyWith(color: context.colors.onSurfaceVariant)),
                    ],
                  ),
                ),
              _step == 2 && draft.payment == PaymentMethod.applePay
                  ? ApplePayButton(onPressed: _next)
                  : FilledButton(
                      onPressed: _next,
                      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                      child: Text(
                        _step < 2
                            ? s.next
                            : draft.payment == PaymentMethod.cod
                            ? s.placeOrderCod
                            : s.payAmount(ref.money(context, t.total)),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _addressStep(CheckoutDraft d) {
    final a = d.address;
    final s = context.s;
    return [
      Text(s.deliveryAddress, style: context.text.titleMedium),
      const SizedBox(height: Tokens.s12),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(Tokens.s16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: context.colors.primaryContainer, borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.location_on_rounded, color: context.colors.primary),
              ),
              const SizedBox(width: Tokens.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.name, style: context.text.titleSmall),
                    Text('${a.city}، ${a.district}', style: context.text.bodyMedium),
                    Text(a.street, style: context.text.bodySmall?.copyWith(color: context.colors.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    Text('${a.phone}  •  ${a.shortCode}', textDirection: TextDirection.ltr, style: context.text.labelMedium),
                  ],
                ),
              ),
              TextButton(onPressed: () => _editAddress(a), child: Text(s.edit)),
            ],
          ),
        ),
      ).animate().fadeIn(),
      const SizedBox(height: Tokens.s12),
      // A static, stylised map tile to make the address feel real.
      ClipRRect(
        borderRadius: BorderRadius.circular(Tokens.cardRadius),
        child: SizedBox(
          height: 140,
          child: CustomPaint(
            painter: _MapPainter(context.colors),
            child: const Center(child: Icon(Icons.location_on_rounded, size: 40, color: Palette.danger)),
          ),
        ),
      ),
    ];
  }

  Future<void> _editAddress(Address a) async {
    final s = context.s;
    final name = TextEditingController(text: a.name);
    final city = TextEditingController(text: a.city);
    final district = TextEditingController(text: a.district);
    final street = TextEditingController(text: a.street);
    final code = TextEditingController(text: a.shortCode);
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (c) => Padding(
        padding: EdgeInsets.fromLTRB(Tokens.s16, 0, Tokens.s16, MediaQuery.viewInsetsOf(c).bottom + Tokens.s16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(s.deliveryAddress, style: context.text.titleLarge),
            const SizedBox(height: Tokens.s16),
            TextField(
              controller: name,
              decoration: InputDecoration(labelText: s.fullName),
            ),
            const SizedBox(height: Tokens.s12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: city,
                    decoration: InputDecoration(labelText: s.city),
                  ),
                ),
                const SizedBox(width: Tokens.s12),
                Expanded(
                  child: TextField(
                    controller: district,
                    decoration: InputDecoration(labelText: s.district),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Tokens.s12),
            TextField(
              controller: street,
              decoration: InputDecoration(labelText: s.street),
            ),
            const SizedBox(height: Tokens.s12),
            TextField(
              controller: code,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [LengthLimitingTextInputFormatter(8)],
              decoration: InputDecoration(labelText: s.nationalAddress, hintText: 'RRRD2929'),
            ),
            const SizedBox(height: Tokens.s16),
            FilledButton(
              onPressed: () => Navigator.pop(c, true),
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
              child: Text(s.save),
            ),
          ],
        ),
      ),
    );
    if (saved == true) {
      final d = ref.read(checkoutProvider);
      ref
          .read(checkoutProvider.notifier)
          .set(
            d.copyWith(
              address: Address(
                name: name.text,
                phone: a.phone,
                city: city.text,
                district: district.text,
                street: street.text,
                shortCode: code.text.toUpperCase(),
              ),
            ),
          );
    }
    for (final c in [name, city, district, street, code]) {
      c.dispose();
    }
  }

  List<Widget> _deliveryStep(CheckoutDraft d) {
    final s = context.s;
    final t = ref.read(totalsProvider);
    final options = [
      (DeliverySlot.express, Icons.bolt_rounded, s.slotExpress, s.slotExpressBody),
      (DeliverySlot.standard, Icons.local_shipping_rounded, s.slotStandard, s.slotStandardBody),
      (DeliverySlot.scheduled, Icons.event_rounded, s.slotScheduled, s.slotScheduledBody),
    ];
    final days = List.generate(5, (i) => DateTime.now().add(Duration(days: i + 1)));
    return [
      Text(s.deliveryTime, style: context.text.titleMedium),
      const SizedBox(height: Tokens.s12),
      for (final (i, (slot, icon, title, body)) in options.indexed)
        Padding(
          padding: const EdgeInsets.only(bottom: Tokens.s12),
          child: _OptionCard(
            selected: d.slot == slot,
            icon: icon,
            title: title,
            body: body,
            trailing: Text(
              slot == DeliverySlot.express ? ref.money(context, 35) : (t.subtotal - t.discount >= 300 ? s.free : ref.money(context, 20)),
              style: context.text.titleSmall,
            ),
            onTap: () => ref.read(checkoutProvider.notifier).set(d.copyWith(slot: slot)),
          ).stagger(i),
        ),
      AnimatedSize(
        duration: const Duration(milliseconds: 250),
        child: d.slot != DeliverySlot.scheduled
            ? const SizedBox(width: double.infinity)
            : SizedBox(
                height: 76,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: days.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final sel = i == _scheduledDay;
                    final loc = Localizations.localeOf(context).languageCode;
                    return InkWell(
                      borderRadius: BorderRadius.circular(Tokens.controlRadius),
                      onTap: () => setState(() => _scheduledDay = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 64,
                        decoration: BoxDecoration(
                          color: sel ? context.colors.primary : context.colors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(Tokens.controlRadius),
                          border: Border.all(color: sel ? context.colors.primary : context.colors.outline),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(dayName(days[i], loc), style: context.text.labelSmall?.copyWith(color: sel ? context.colors.onPrimary : null)),
                            Text('${days[i].day}', style: context.text.titleLarge?.copyWith(color: sel ? context.colors.onPrimary : null)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    ];
  }

  List<Widget> _paymentStep(CheckoutDraft d, double total) {
    final s = context.s;
    final options = [
      (PaymentMethod.mada, const PaymentLogo.mada(), s.payMada, s.payMadaBody),
      (PaymentMethod.applePay, const PaymentLogo.apple(), s.payApple, s.payAppleBody),
      (PaymentMethod.stcPay, const PaymentLogo.stc(), s.paySTC, s.paySTCBody),
      (PaymentMethod.tabby, const PaymentLogo.tabby(), s.payTabby, s.payTabbyBody(ref.money(context, total / 4))),
      (PaymentMethod.cod, const PaymentLogo.cod(), s.payCod, s.payCodBody),
    ];
    return [
      Text(s.paymentMethod, style: context.text.titleMedium),
      const SizedBox(height: Tokens.s12),
      for (final (i, (m, logo, title, body)) in options.indexed)
        Padding(
          padding: const EdgeInsets.only(bottom: Tokens.s12),
          child: _OptionCard(
            selected: d.payment == m,
            leading: logo,
            title: title,
            body: body,
            onTap: () => ref.read(checkoutProvider.notifier).set(d.copyWith(payment: m)),
            expanded: d.payment == PaymentMethod.mada && m == PaymentMethod.mada ? const CardForm() : null,
          ).stagger(i),
        ),
    ];
  }
}

String dayName(DateTime d, String loc) {
  const ar = ['الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
  const en = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return (loc == 'ar' ? ar : en)[d.weekday - 1];
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.selected,
    required this.title,
    required this.body,
    required this.onTap,
    this.icon,
    this.leading,
    this.trailing,
    this.expanded,
  });
  final bool selected;
  final IconData? icon;
  final Widget? leading;
  final String title;
  final String body;
  final Widget? trailing;
  final Widget? expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: selected ? context.colors.primaryContainer.withValues(alpha: 0.45) : context.colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(Tokens.cardRadius),
        border: Border.all(color: selected ? context.colors.primary : context.colors.outlineVariant, width: selected ? 1.6 : 1),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(Tokens.cardRadius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(Tokens.s16),
            child: Column(
              children: [
                Row(
                  children: [
                    leading ?? Icon(icon, color: context.colors.primary),
                    const SizedBox(width: Tokens.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: context.text.titleSmall),
                          Text(body, style: context.text.bodySmall?.copyWith(color: context.colors.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    ?trailing,
                    const SizedBox(width: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                        key: ValueKey(selected),
                        color: selected ? context.colors.primary : context.colors.outline,
                      ),
                    ),
                  ],
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  child: expanded == null
                      ? const SizedBox(width: double.infinity)
                      : Padding(
                          padding: const EdgeInsets.only(top: Tokens.s16),
                          child: expanded,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  _MapPainter(this.c);
  final ColorScheme c;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = c.surfaceContainer);
    final block = Paint()..color = c.surfaceContainerHigh;
    for (var y = 6.0; y < size.height; y += 34) {
      for (var x = 6.0; x < size.width; x += 52) {
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, 44, 26), const Radius.circular(4)), block);
      }
    }
    final road = Paint()
      ..color = c.surfaceContainerLowest
      ..strokeWidth = 8;
    canvas.drawLine(Offset(0, size.height * 0.62), Offset(size.width, size.height * 0.48), road);
    canvas.drawLine(Offset(size.width * 0.38, 0), Offset(size.width * 0.44, size.height), road);
    canvas.drawCircle(size.center(Offset.zero), 26, Paint()..color = Palette.danger.withValues(alpha: 0.15));
  }

  @override
  bool shouldRepaint(_MapPainter old) => old.c != c;
}
