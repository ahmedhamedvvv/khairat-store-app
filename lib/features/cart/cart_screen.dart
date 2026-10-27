import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../data/pricing.dart';
import '../../state/providers.dart';
import '../../widgets/common.dart';
import '../../widgets/product_art.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final _coupon = TextEditingController();
  String? _couponError;

  @override
  void dispose() {
    _coupon.dispose();
    super.dispose();
  }

  void _applyCoupon() {
    final t = ref.read(totalsProvider);
    final r = checkCoupon(_coupon.text, ref.read(couponsProvider), t.subtotal);
    final draft = ref.read(checkoutProvider);
    if (r.coupon != null) {
      ref.read(checkoutProvider.notifier).set(draft.copyWith(coupon: r.coupon));
      FocusScope.of(context).unfocus();
      setState(() => _couponError = null);
      showToast(context, context.s.couponApplied(r.coupon!.code));
      return;
    }
    final c = ref.read(couponsProvider).where((c) => c.code == _coupon.text.trim().toUpperCase()).firstOrNull;
    setState(
      () => _couponError = switch (r.error!) {
        CouponError.notFound => context.s.couponNotFound,
        CouponError.inactive => context.s.couponInactive,
        CouponError.belowMinimum => context.s.couponMin(ref.money(context, c?.minSubtotal ?? 0)),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final lines = ref.watch(cartLinesProvider);
    final t = ref.watch(totalsProvider);
    final draft = ref.watch(checkoutProvider);

    // A coupon whose minimum is no longer met drops off silently.
    if (draft.coupon != null && t.subtotal < draft.coupon!.minSubtotal) {
      WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(checkoutProvider.notifier).set(draft.copyWith(clearCoupon: true)));
    }

    if (lines.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(s.cart)),
        body: EmptyState(
          icon: Icons.shopping_bag_outlined,
          title: s.cartEmpty,
          body: s.cartEmptyBody,
          action: s.startShopping,
          onAction: () => context.go('/home'),
        ),
      );
    }

    final progress = ((ShippingRules.freeThreshold - t.toFreeShipping) / ShippingRules.freeThreshold).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(title: Text('${s.cart} (${ref.watch(cartCountProvider)})')),
      body: ListView(
        padding: const EdgeInsets.all(Tokens.s16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(Tokens.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(t.toFreeShipping == 0 ? Icons.celebration_rounded : Icons.local_shipping_outlined, color: context.colors.primary, size: 20),
                      const SizedBox(width: Tokens.s8),
                      Expanded(
                        child: Text(
                          t.toFreeShipping == 0 ? s.freeShippingUnlocked : s.toFreeShipping(ref.money(context, t.toFreeShipping)),
                          style: context.text.titleSmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Tokens.s12),
                  TweenAnimationBuilder<double>(
                    tween: Tween(end: progress),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, _) => ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: v,
                        minHeight: 8,
                        color: v >= 1 ? Palette.success : Palette.gold,
                        backgroundColor: context.colors.surfaceContainerHigh,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Tokens.s16),
          for (final (i, l) in lines.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: Tokens.s12),
              child: Dismissible(
                key: ValueKey(l.item.key),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => ref.read(cartProvider.notifier).remove(l.item.key),
                background: Container(
                  alignment: AlignmentDirectional.centerEnd,
                  padding: const EdgeInsets.symmetric(horizontal: Tokens.s24),
                  decoration: BoxDecoration(color: Palette.danger, borderRadius: BorderRadius.circular(Tokens.cardRadius)),
                  child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                ),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(Tokens.s12),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.push('/product/${l.product.id}'),
                          child: SizedBox(width: 84, height: 84, child: ProductArt.of(l.product, radius: Tokens.controlRadius)),
                        ),
                        const SizedBox(width: Tokens.s12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l.product.name.of(context), style: context.text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                              if (l.product.variants.length > 1)
                                Text(l.variant.label.of(context), style: context.text.bodySmall?.copyWith(color: context.colors.onSurfaceVariant)),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(child: PriceTag(price: l.variant.price * l.item.qty)),
                                  QtyStepper(
                                    deletable: true,
                                    value: l.item.qty,
                                    onChanged: (q) {
                                      if (!ref.read(cartProvider.notifier).setQty(l.item.key, q)) {
                                        showToast(context, s.stockLimit, icon: Icons.error_outline_rounded);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ).stagger(i),
          const SizedBox(height: Tokens.s8),
          if (draft.coupon == null)
            TextField(
              controller: _coupon,
              textCapitalization: TextCapitalization.characters,
              onSubmitted: (_) => _applyCoupon(),
              decoration: InputDecoration(
                hintText: s.couponHint,
                helperText: s.tryCodes,
                errorText: _couponError,
                prefixIcon: const Icon(Icons.local_offer_outlined),
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(6),
                  child: FilledButton.tonal(onPressed: _applyCoupon, child: Text(s.apply)),
                ),
              ),
            )
          else
            Card(
              color: context.colors.primaryContainer,
              child: ListTile(
                leading: const Icon(Icons.local_offer_rounded, color: Palette.gold),
                title: Text(s.couponApplied(draft.coupon!.code), style: context.text.titleSmall),
                subtitle: Text('-${ref.money(context, t.discount)}'),
                trailing: TextButton(
                  onPressed: () {
                    _coupon.clear();
                    ref.read(checkoutProvider.notifier).set(draft.copyWith(clearCoupon: true));
                  },
                  child: Text(s.remove),
                ),
              ),
            ).animate().scale(begin: const Offset(0.95, 0.95), duration: 300.ms, curve: Curves.easeOutBack),
          const SizedBox(height: Tokens.s16),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.card_giftcard_rounded, color: Palette.gold),
                  title: Text(s.giftWrap, style: context.text.titleSmall),
                  subtitle: Text(s.giftWrapBody(ref.money(context, ShippingRules.giftWrap))),
                  value: draft.giftWrap,
                  onChanged: (v) => ref.read(checkoutProvider.notifier).set(draft.copyWith(giftWrap: v)),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  child: draft.giftWrap
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(Tokens.s16, 0, Tokens.s16, Tokens.s16),
                          child: TextFormField(
                            initialValue: draft.giftMessage,
                            maxLines: 2,
                            maxLength: 120,
                            onChanged: (v) => ref.read(checkoutProvider.notifier).set(ref.read(checkoutProvider).copyWith(giftMessage: v)),
                            decoration: InputDecoration(hintText: s.giftMessageHint),
                          ),
                        )
                      : const SizedBox(width: double.infinity),
                ),
              ],
            ),
          ),
          const SizedBox(height: Tokens.s16),
          TotalsCard(totals: t),
          const SizedBox(height: Tokens.s24),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(Tokens.s16, Tokens.s8, Tokens.s16, Tokens.s12),
        child: FilledButton(
          onPressed: () => context.push('/checkout'),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(s.checkout),
              const SizedBox(width: Tokens.s12),
              Container(width: 1, height: 18, color: context.colors.onPrimary.withValues(alpha: 0.4)),
              const SizedBox(width: Tokens.s12),
              Text(ref.money(context, t.total)),
            ],
          ),
        ),
      ),
    );
  }
}

class TotalsCard extends ConsumerWidget {
  const TotalsCard({super.key, required this.totals});
  final Totals totals;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = context.s;
    final t = totals;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Tokens.s16),
        child: Column(
          children: [
            SummaryRow(s.subtotal, ref.money(context, t.subtotal)),
            if (t.discount > 0) SummaryRow(s.discount, '-${ref.money(context, t.discount)}', valueColor: Palette.success),
            SummaryRow(s.shipping, t.shipping == 0 ? s.free : ref.money(context, t.shipping), valueColor: t.shipping == 0 ? Palette.success : null),
            if (t.giftWrap > 0) SummaryRow(s.giftWrapFee, ref.money(context, t.giftWrap)),
            const Divider(height: 20),
            SummaryRow(s.total, ref.money(context, t.total), bold: true),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                s.vatLine('${(t.vatRate * 100).round()}', ref.money(context, t.vat)),
                style: context.text.labelSmall?.copyWith(color: context.colors.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
