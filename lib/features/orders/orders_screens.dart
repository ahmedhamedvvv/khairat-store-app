import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../data/pricing.dart';
import '../../state/providers.dart';
import '../../widgets/common.dart';
import '../../widgets/product_art.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = context.s;
    final orders = ref.watch(ordersProvider);
    final active = orders.where((o) => o.status != OrderStatus.delivered && o.status != OrderStatus.cancelled).toList();
    final past = orders.where((o) => o.status == OrderStatus.delivered || o.status == OrderStatus.cancelled).toList();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(s.myOrders),
          bottom: TabBar(
            tabs: [
              Tab(text: '${s.ordersActive} (${active.length})'),
              Tab(text: s.ordersPast),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OrderList(orders: active),
            _OrderList(orders: past),
          ],
        ),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  const _OrderList({required this.orders});
  final List<Order> orders;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) return EmptyState(icon: Icons.receipt_long_outlined, title: context.s.ordersEmpty);
    return ListView.separated(
      padding: const EdgeInsets.all(Tokens.s16),
      itemCount: orders.length,
      separatorBuilder: (_, _) => const SizedBox(height: Tokens.s12),
      itemBuilder: (_, i) => OrderCard(order: orders[i], onTap: () => context.push('/order/${orders[i].id}')).stagger(i),
    );
  }
}

class OrderCard extends ConsumerWidget {
  const OrderCard({super.key, required this.order, required this.onTap, this.showCustomer = false});
  final Order order;
  final VoidCallback onTap;
  final bool showCustomer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    final arts = order.lines.take(3).map((l) => products.where((p) => p.id == l.productId).firstOrNull).nonNulls.toList();
    final st = order.status;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(Tokens.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.s.orderNo(order.id), style: context.text.titleSmall),
                        Text(
                          showCustomer ? '${order.address.name} • ${formatDate(context, order.createdAt)}' : formatDate(context, order.createdAt),
                          style: context.text.labelSmall?.copyWith(color: context.colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  StatusChip(status: st),
                ],
              ),
              const SizedBox(height: Tokens.s12),
              Row(
                children: [
                  for (final p in arts)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 6),
                      child: SizedBox(width: 44, height: 44, child: ProductArt.of(p, radius: 10)),
                    ),
                  if (order.lines.length > 3) Text('+${order.lines.length - 3}', style: context.text.labelMedium),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(ref.money(context, order.total), style: context.text.titleSmall?.copyWith(color: context.colors.primary)),
                      Text(context.s.itemsCount(order.itemCount), style: context.text.labelSmall?.copyWith(color: context.colors.onSurfaceVariant)),
                    ],
                  ),
                ],
              ),
              if (st != OrderStatus.cancelled) ...[
                const SizedBox(height: Tokens.s12),
                Row(
                  children: [
                    for (var i = 0; i < orderFlow.length; i++) ...[
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: i <= orderFlow.indexOf(st) ? statusColor(context, st) : context.colors.outlineVariant,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      if (i < orderFlow.length - 1) const SizedBox(width: 4),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});
  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final c = statusColor(context, status);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Container(
        key: ValueKey(status),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(100)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(statusIcon(status), size: 14, color: c),
            const SizedBox(width: 4),
            Text(
              statusLabel(context, status),
              style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

/// The step-by-step tracker shared by the shopper and merchant views.
class OrderTimeline extends StatelessWidget {
  const OrderTimeline({super.key, required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final cancelled = order.status == OrderStatus.cancelled;
    final steps = cancelled ? [OrderStatus.placed, OrderStatus.cancelled] : orderFlow;
    final reached = steps.where(order.history.containsKey).length;
    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 36,
                  child: Column(
                    children: [
                      _Dot(
                        done: i < reached,
                        current: i == reached - 1 && !cancelled && order.status != OrderStatus.delivered,
                        color: statusColor(context, steps[i]),
                        icon: statusIcon(steps[i]),
                      ),
                      if (i < steps.length - 1)
                        Expanded(
                          child: Container(
                            width: 3,
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            color: context.colors.outlineVariant,
                            alignment: Alignment.topCenter,
                            child: i < reached - 1
                                ? Container(color: statusColor(context, steps[i + 1]))
                                      .animate()
                                      .scaleY(begin: 0, alignment: Alignment.topCenter, duration: 400.ms, delay: (150 * i).ms)
                                : null,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: Tokens.s12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: Tokens.s16, top: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          statusLabel(context, steps[i]),
                          style: context.text.titleSmall?.copyWith(color: i < reached ? null : context.colors.onSurfaceVariant),
                        ),
                        Text(
                          order.history[steps[i]] != null
                              ? '${statusBody(context, steps[i])} • ${formatDate(context, order.history[steps[i]]!)}'
                              : statusBody(context, steps[i]),
                          style: context.text.bodySmall?.copyWith(color: context.colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.done, required this.current, required this.color, required this.icon});
  final bool done;
  final bool current;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final dot = AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 32,
      height: 32,
      decoration: BoxDecoration(color: done ? color : context.colors.surfaceContainerHigh, shape: BoxShape.circle),
      child: Icon(icon, size: 17, color: done ? Colors.white : context.colors.onSurfaceVariant),
    );
    if (!current) return dot;
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.3), shape: BoxShape.circle),
        ).animate(onPlay: (c) => c.repeat()).scale(begin: const Offset(1, 1), end: const Offset(1.6, 1.6), duration: 1200.ms).fadeOut(duration: 1200.ms),
        dot,
      ],
    );
  }
}

class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.id});
  final String id;

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    final s = context.s;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(s.cancelConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(s.keepOrder)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Palette.danger, minimumSize: const Size(0, 44)),
            onPressed: () => Navigator.pop(c, true),
            child: Text(s.cancelYes),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      ref.read(ordersProvider.notifier).cancel(id);
      showToast(context, s.orderCancelled);
    }
  }

  Future<void> _rate(BuildContext context, WidgetRef ref) async {
    var stars = 5;
    final s = context.s;
    final ok = await showModalBottomSheet<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, set) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Tokens.s24, 0, Tokens.s24, Tokens.s24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(s.rateTitle, style: context.text.titleLarge),
                const SizedBox(height: Tokens.s16),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 1; i <= 5; i++)
                        IconButton(
                          iconSize: 40,
                          onPressed: () => set(() => stars = i),
                          icon: AnimatedScale(
                            scale: i <= stars ? 1.1 : 0.9,
                            duration: const Duration(milliseconds: 200),
                            child: Icon(Icons.star_rounded, color: i <= stars ? Palette.gold : context.colors.outline),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: Tokens.s16),
                FilledButton(
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                  onPressed: () => Navigator.pop(c, true),
                  child: Text(s.submit),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (ok == true && context.mounted) {
      ref.read(ordersProvider.notifier).markRated(id);
      showToast(context, s.rateThanks, icon: Icons.star_rounded);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = context.s;
    final order = ref.watch(orderProvider(id));
    if (order == null) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyState(icon: Icons.search_off_rounded, title: s.noResults),
      );
    }
    final st = order.status;
    final eta = order.createdAt.add(Duration(hours: order.slot == DeliverySlot.express ? 3 : 30));

    return Scaffold(
      appBar: AppBar(
        title: Text(s.orderNo(order.id)),
        actions: [IconButton(tooltip: s.viewInvoice, onPressed: () => context.push('/invoice/$id'), icon: const Icon(Icons.receipt_rounded))],
      ),
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
                      Expanded(
                        child: Text(statusLabel(context, st), style: context.text.titleLarge?.copyWith(color: statusColor(context, st))),
                      ),
                      if (st != OrderStatus.cancelled && st != OrderStatus.delivered)
                        Text(s.eta(formatDate(context, eta)), style: context.text.labelMedium?.copyWith(color: context.colors.onSurfaceVariant)),
                    ],
                  ),
                  const SizedBox(height: Tokens.s16),
                  OrderTimeline(order: order),
                  if (st == OrderStatus.shipped)
                    Container(
                      padding: const EdgeInsets.all(Tokens.s12),
                      decoration: BoxDecoration(color: context.colors.primaryContainer, borderRadius: BorderRadius.circular(Tokens.controlRadius)),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Palette.gold,
                            child: const Icon(Icons.delivery_dining_rounded, color: Palette.oudDeep),
                          ),
                          const SizedBox(width: Tokens.s12),
                          Expanded(child: Text(s.courier, style: context.text.titleSmall)),
                          IconButton.filled(onPressed: () {}, icon: const Icon(Icons.call_rounded)),
                        ],
                      ),
                    ).animate().fadeIn().slideY(begin: 0.2),
                  if (nextStatus(st) != null) ...[
                    const SizedBox(height: Tokens.s8),
                    Center(
                      child: TextButton.icon(
                        onPressed: () => ref.read(ordersProvider.notifier).advance(id),
                        icon: const Icon(Icons.fast_forward_rounded, size: 18),
                        label: Text(s.demoAdvance),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: Tokens.s16),
          Text(s.orderItems, style: context.text.titleMedium),
          const SizedBox(height: Tokens.s8),
          Card(
            child: Column(children: [for (final l in order.lines) OrderLineTile(line: l)]),
          ),
          if (order.giftMessage != null) ...[
            const SizedBox(height: Tokens.s12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.card_giftcard_rounded, color: Palette.gold),
                title: Text(s.giftMessage, style: context.text.titleSmall),
                subtitle: Text('"${order.giftMessage}"'),
              ),
            ),
          ],
          const SizedBox(height: Tokens.s12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: Text(order.address.name, style: context.text.titleSmall),
              subtitle: Text('${order.address.city}، ${order.address.district}\n${order.address.street}'),
              isThreeLine: true,
            ),
          ),
          const SizedBox(height: Tokens.s12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(Tokens.s16),
              child: Column(
                children: [
                  SummaryRow(s.subtotal, ref.money(context, order.subtotal)),
                  if (order.discount > 0)
                    SummaryRow('${s.discount} (${order.couponCode})', '-${ref.money(context, order.discount)}', valueColor: Palette.success),
                  SummaryRow(s.shipping, order.shipping == 0 ? s.free : ref.money(context, order.shipping)),
                  if (order.giftWrap > 0) SummaryRow(s.giftWrapFee, ref.money(context, order.giftWrap)),
                  const Divider(height: 20),
                  SummaryRow(s.total, ref.money(context, order.total), bold: true),
                  SummaryRow(s.paidWith, paymentLabel(context, order.payment)),
                ],
              ),
            ),
          ),
          const SizedBox(height: Tokens.s24),
          if (canCancel(st))
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Palette.danger,
                side: const BorderSide(color: Palette.danger),
              ),
              onPressed: () => _cancel(context, ref),
              icon: const Icon(Icons.close_rounded),
              label: Text(s.cancelOrder),
            ),
          if (st == OrderStatus.delivered || st == OrderStatus.cancelled)
            FilledButton.icon(
              onPressed: () {
                ref.read(ordersProvider.notifier).reorder(id);
                showToast(context, s.reorderDone, action: s.viewCart, onAction: () => context.go('/cart'));
              },
              icon: const Icon(Icons.replay_rounded),
              label: Text(s.reorder),
            ),
          if (st == OrderStatus.delivered && !order.rated) ...[
            const SizedBox(height: Tokens.s12),
            OutlinedButton.icon(onPressed: () => _rate(context, ref), icon: const Icon(Icons.star_outline_rounded), label: Text(s.rateOrder)),
          ],
        ],
      ),
    );
  }
}

class OrderLineTile extends ConsumerWidget {
  const OrderLineTile({super.key, required this.line});
  final OrderLine line;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(productProvider(line.productId));
    return ListTile(
      leading: SizedBox(width: 48, height: 48, child: ProductArt.of(p, radius: 10)),
      title: Text(line.name.of(context), style: context.text.titleSmall),
      subtitle: Text('${line.variantLabel.of(context)} × ${line.qty}'),
      trailing: Text(ref.money(context, line.total), style: context.text.titleSmall),
    );
  }
}
