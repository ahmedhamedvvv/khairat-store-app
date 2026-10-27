import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../widgets/shells.dart';
import '../checkout/checkout_screen.dart' show dayName;
import '../orders/orders_screens.dart';

String _shortDay(DateTime d, String loc) => loc == 'ar' ? const ['إثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة', 'سبت', 'أحد'][d.weekday - 1] : dayName(d, loc);

bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = context.s;
    final orders = ref.watch(ordersProvider).where((o) => o.status != OrderStatus.cancelled).toList();
    final products = ref.watch(productsProvider);
    final now = DateTime.now();
    final days = List.generate(7, (i) => DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - i)));
    final perDay = [for (final d in days) orders.where((o) => _sameDay(o.createdAt, d)).fold<double>(0, (a, o) => a + o.total)];
    final today = orders.where((o) => _sameDay(o.createdAt, now)).toList();
    final todaySales = today.fold<double>(0, (a, o) => a + o.total);
    final week = perDay.fold<double>(0, (a, b) => a + b);
    final weekCount = orders.where((o) => o.createdAt.isAfter(days.first)).length;
    final waiting = ref.watch(ordersProvider).where((o) => o.status == OrderStatus.placed).toList();
    final low = products.where((p) => p.stock <= 5).toList();
    final top = [...products]..sort((a, b) => b.sold.compareTo(a.sold));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.dashboard),
            Text(s.merchantHello, style: context.text.labelSmall?.copyWith(color: context.colors.onSurfaceVariant)),
          ],
        ),
        actions: const [RoleSwitchButton(), SizedBox(width: 4)],
      ),
      body: ListView(
        padding: const EdgeInsets.all(Tokens.s16),
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: Tokens.s12,
            crossAxisSpacing: Tokens.s12,
            childAspectRatio: 1.55,
            children: [
              _Kpi(icon: Icons.payments_rounded, label: s.todaySales, value: ref.money(context, todaySales), highlight: true),
              _Kpi(icon: Icons.shopping_bag_rounded, label: s.ordersToday, value: '${today.length}'),
              _Kpi(icon: Icons.trending_up_rounded, label: s.weekSales, value: ref.money(context, week)),
              _Kpi(icon: Icons.analytics_rounded, label: s.avgOrder, value: ref.money(context, weekCount == 0 ? 0 : week / weekCount)),
            ].indexed.map((e) => e.$2.stagger(e.$1)).toList(),
          ),
          if (low.isNotEmpty) ...[
            const SizedBox(height: Tokens.s12),
            Material(
              color: const Color(0xFFB7791F).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(Tokens.controlRadius),
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Tokens.controlRadius)),
                leading: const Icon(Icons.warning_amber_rounded, color: Color(0xFFB7791F)),
                title: Text(s.lowStockAlert(low.length), style: context.text.titleSmall),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.go('/merchant/products?low=1'),
              ),
            ),
          ],
          const SizedBox(height: Tokens.s16),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Tokens.s16, Tokens.s16, Tokens.s16, Tokens.s8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.salesChart, style: context.text.titleMedium),
                  const SizedBox(height: Tokens.s16),
                  SizedBox(
                    height: 180,
                    child: _SalesChart(days: days, values: perDay),
                  ),
                ],
              ),
            ),
          ),
          SectionHeader(s.needsAction, action: s.seeAll, onAction: () => context.go('/merchant/orders?s=placed')),
          if (waiting.isEmpty)
            Card(
              child: ListTile(
                leading: const Icon(Icons.check_circle_outline_rounded, color: Palette.success),
                title: Text(s.ordersEmpty),
              ),
            )
          else
            for (final (i, o) in waiting.take(3).indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: Tokens.s12),
                child: OrderCard(order: o, showCustomer: true, onTap: () => context.push('/merchant/order/${o.id}')).stagger(i),
              ),
          SectionHeader(s.topProducts),
          Card(
            child: Column(
              children: [
                for (final (i, p) in top.take(5).indexed)
                  ListTile(
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 20,
                          child: Text('${i + 1}', style: context.text.titleSmall?.copyWith(color: context.colors.secondary)),
                        ),
                        SizedBox(width: 44, height: 44, child: ProductArt.of(p, radius: 10)),
                      ],
                    ),
                    title: Text(p.name.of(context), style: context.text.titleSmall),
                    subtitle: Text(s.soldCount(p.sold)),
                    trailing: Text(ref.money(context, p.basePrice)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({required this.icon, required this.label, required this.value, this.highlight = false});
  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final fg = highlight ? Colors.white : context.colors.onSurface;
    return Container(
      padding: const EdgeInsets.all(Tokens.s16),
      decoration: BoxDecoration(
        color: highlight ? Palette.oud : context.colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(Tokens.cardRadius),
        border: highlight ? null : Border.all(color: context.colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: highlight ? Palette.gold : context.colors.secondary, size: 22),
          FittedBox(
            child: Text(value, style: context.text.titleLarge?.copyWith(color: fg)),
          ),
          Text(label, style: context.text.labelSmall?.copyWith(color: highlight ? Palette.goldSoft : context.colors.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _SalesChart extends ConsumerWidget {
  const _SalesChart({required this.days, required this.values});
  final List<DateTime> days;
  final List<double> values;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final max = values.fold<double>(0, (a, b) => a > b ? a : b);
    final top = max == 0 ? 100.0 : (max * 1.25 / 100).ceil() * 100.0;
    final loc = Localizations.localeOf(context).languageCode;
    return BarChart(
      BarChartData(
        maxY: top,
        alignment: BarChartAlignment.spaceAround,
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: top / 4,
          getDrawingHorizontalLine: (_) => FlLine(color: context.colors.outlineVariant, strokeWidth: 1, dashArray: [4, 4]),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: const AxisTitles(),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 26,
              getTitlesWidget: (v, _) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  v.toInt() == 6 ? (loc == 'ar' ? 'اليوم' : 'Today') : _shortDay(days[v.toInt()], loc),
                  style: context.text.labelSmall?.copyWith(color: context.colors.onSurfaceVariant),
                ),
              ),
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => Palette.oudDeep,
            getTooltipItem: (g, _, rod, _) =>
                BarTooltipItem(ref.money(context, rod.toY), const TextStyle(color: Colors.white, fontFamily: Tokens.font, fontWeight: FontWeight.w600)),
          ),
        ),
        barGroups: [
          for (var i = 0; i < values.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: values[i],
                  width: 22,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: i == 6 ? [Palette.gold, const Color(0xFFE3C88F)] : [context.colors.primary.withValues(alpha: 0.75), context.colors.primary],
                  ),
                  backDrawRodData: BackgroundBarChartRodData(show: true, toY: top, color: context.colors.surfaceContainer),
                ),
              ],
            ),
        ],
      ),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
    );
  }
}

class MerchantOrdersScreen extends ConsumerStatefulWidget {
  const MerchantOrdersScreen({super.key, this.initial});
  final String? initial;

  @override
  ConsumerState<MerchantOrdersScreen> createState() => _MerchantOrdersScreenState();
}

class _MerchantOrdersScreenState extends ConsumerState<MerchantOrdersScreen> {
  late OrderStatus? _filter = widget.initial == null ? null : OrderStatus.values.asNameMap()[widget.initial];

  @override
  void didUpdateWidget(MerchantOrdersScreen old) {
    super.didUpdateWidget(old);
    if (old.initial != widget.initial && widget.initial != null) _filter = OrderStatus.values.asNameMap()[widget.initial];
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final all = ref.watch(ordersProvider);
    final list = _filter == null ? all : all.where((o) => o.status == _filter).toList();
    return Scaffold(
      appBar: AppBar(title: Text(s.orders), actions: const [RoleSwitchButton(), SizedBox(width: 4)]),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Tokens.s16, vertical: 6),
              children: [
                ChoiceChip(label: Text('${s.all} (${all.length})'), selected: _filter == null, onSelected: (_) => setState(() => _filter = null)),
                for (final st in OrderStatus.values)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 8),
                    child: ChoiceChip(
                      label: Text('${statusLabel(context, st)} (${all.where((o) => o.status == st).length})'),
                      selected: _filter == st,
                      onSelected: (_) => setState(() => _filter = st),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? EmptyState(icon: Icons.inbox_outlined, title: s.ordersEmpty)
                : ListView.separated(
                    padding: const EdgeInsets.all(Tokens.s16),
                    itemCount: list.length,
                    separatorBuilder: (_, _) => const SizedBox(height: Tokens.s12),
                    itemBuilder: (_, i) => OrderCard(
                      key: ValueKey(list[i].id),
                      order: list[i],
                      showCustomer: true,
                      onTap: () => context.push('/merchant/order/${list[i].id}'),
                    ).stagger(i),
                  ),
          ),
        ],
      ),
    );
  }
}

class MerchantOrderScreen extends ConsumerWidget {
  const MerchantOrderScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = context.s;
    final o = ref.watch(orderProvider(id));
    if (o == null) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyState(icon: Icons.search_off_rounded, title: s.noResults),
      );
    }
    final next = nextStatus(o.status);
    return Scaffold(
      appBar: AppBar(title: Text(s.orderNo(o.id))),
      body: ListView(
        padding: const EdgeInsets.all(Tokens.s16),
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person_rounded)),
              title: Text(o.address.name, style: context.text.titleSmall),
              subtitle: Text('${o.address.phone}\n${o.address.city}، ${o.address.district}'),
              isThreeLine: true,
              trailing: IconButton.filledTonal(onPressed: () {}, icon: const Icon(Icons.call_rounded)),
            ),
          ),
          const SizedBox(height: Tokens.s12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(Tokens.s16),
              child: OrderTimeline(order: o),
            ),
          ),
          const SizedBox(height: Tokens.s12),
          Card(
            child: Column(children: [for (final l in o.lines) OrderLineTile(line: l)]),
          ),
          const SizedBox(height: Tokens.s12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(Tokens.s16),
              child: Column(
                children: [
                  SummaryRow(s.total, ref.money(context, o.total), bold: true),
                  SummaryRow(s.paidWith, paymentLabel(context, o.payment)),
                  if (o.giftMessage != null) SummaryRow(s.giftMessage, '"${o.giftMessage}"'),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: next == null && !canCancel(o.status)
          ? null
          : Padding(
              padding: const EdgeInsets.fromLTRB(Tokens.s16, Tokens.s8, Tokens.s16, Tokens.s12),
              child: Row(
                children: [
                  if (canCancel(o.status)) ...[
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Palette.danger,
                        side: const BorderSide(color: Palette.danger),
                      ),
                      onPressed: () => ref.read(ordersProvider.notifier).cancel(id),
                      child: Text(s.cancel),
                    ),
                    const SizedBox(width: Tokens.s12),
                  ],
                  if (next != null)
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          ref.read(ordersProvider.notifier).advance(id);
                          showToast(context, s.statusUpdated(statusLabel(context, next)));
                        },
                        icon: Icon(statusIcon(next)),
                        label: Text(s.moveTo(statusLabel(context, next))),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class MerchantProductsScreen extends ConsumerStatefulWidget {
  const MerchantProductsScreen({super.key, this.lowOnly = false});
  final bool lowOnly;

  @override
  ConsumerState<MerchantProductsScreen> createState() => _MerchantProductsScreenState();
}

class _MerchantProductsScreenState extends ConsumerState<MerchantProductsScreen> {
  late bool _low = widget.lowOnly;

  @override
  void didUpdateWidget(MerchantProductsScreen old) {
    super.didUpdateWidget(old);
    if (widget.lowOnly != old.lowOnly) _low = widget.lowOnly;
  }

  Future<void> _edit(Product p) async {
    final s = context.s;
    var stock = p.stock;
    var active = p.active;
    final price = TextEditingController(text: p.basePrice.toStringAsFixed(0));
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (c) => StatefulBuilder(
        builder: (c, set) => Padding(
          padding: EdgeInsets.fromLTRB(Tokens.s16, 0, Tokens.s16, MediaQuery.viewInsetsOf(c).bottom + Tokens.s16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(width: 56, height: 56, child: ProductArt.of(p, radius: 12)),
                  const SizedBox(width: Tokens.s12),
                  Expanded(child: Text(p.name.of(context), style: context.text.titleMedium)),
                ],
              ),
              const SizedBox(height: Tokens.s16),
              TextField(
                controller: price,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(labelText: '${s.price} (SAR)'),
              ),
              const SizedBox(height: Tokens.s16),
              Row(
                children: [
                  Expanded(child: Text(s.stock, style: context.text.titleSmall)),
                  QtyStepper(value: stock, min: 0, onChanged: (v) => set(() => stock = v.clamp(0, 999))),
                  const SizedBox(width: 8),
                  TextButton(onPressed: () => set(() => stock += 10), child: const Text('+10')),
                ],
              ),
              SwitchListTile(contentPadding: EdgeInsets.zero, title: Text(s.visible), value: active, onChanged: (v) => set(() => active = v)),
              const SizedBox(height: Tokens.s8),
              FilledButton(
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                onPressed: () => Navigator.pop(c, true),
                child: Text(s.save),
              ),
            ],
          ),
        ),
      ),
    );
    if (saved == true) {
      final v = double.tryParse(price.text);
      ref.read(productsProvider.notifier).update(p.id, stock: stock, active: active, price: v == null || v <= 0 ? null : v);
      if (mounted) showToast(context, s.saved);
    }
    price.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final all = ref.watch(productsProvider);
    final list = _low ? all.where((p) => p.stock <= 5).toList() : all;
    return Scaffold(
      appBar: AppBar(title: Text(s.products), actions: const [RoleSwitchButton(), SizedBox(width: 4)]),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Tokens.s16, 4, Tokens.s16, 4),
            child: Row(
              children: [
                ChoiceChip(label: Text('${s.all} (${all.length})'), selected: !_low, onSelected: (_) => setState(() => _low = false)),
                const SizedBox(width: 8),
                ChoiceChip(
                  avatar: const Icon(Icons.warning_amber_rounded, size: 16),
                  label: Text('${s.lowStock} (${all.where((p) => p.stock <= 5).length})'),
                  selected: _low,
                  onSelected: (_) => setState(() => _low = true),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(Tokens.s16),
              itemCount: list.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final p = list[i];
                final stockColor = p.outOfStock
                    ? Palette.danger
                    : p.lowStock
                    ? const Color(0xFFB7791F)
                    : Palette.success;
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => _edit(p),
                    child: Padding(
                      padding: const EdgeInsets.all(Tokens.s12),
                      child: Row(
                        children: [
                          Opacity(
                            opacity: p.active ? 1 : 0.4,
                            child: SizedBox(width: 56, height: 56, child: ProductArt.of(p, radius: 12)),
                          ),
                          const SizedBox(width: Tokens.s12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.name.of(context), style: context.text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Text(ref.money(context, p.basePrice), style: context.text.bodySmall),
                                    const SizedBox(width: 8),
                                    if (!p.active) Pill(s.hidden, color: context.colors.surfaceContainerHigh, textColor: context.colors.onSurfaceVariant),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('${p.stock}', style: context.text.titleMedium?.copyWith(color: stockColor)),
                              Text(s.stock, style: context.text.labelSmall?.copyWith(color: context.colors.onSurfaceVariant)),
                            ],
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.edit_outlined, size: 18, color: context.colors.onSurfaceVariant),
                        ],
                      ),
                    ),
                  ),
                ).stagger(i);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CouponsScreen extends ConsumerWidget {
  const CouponsScreen({super.key});

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final s = context.s;
    final code = TextEditingController();
    final value = TextEditingController(text: '15');
    final min = TextEditingController(text: '0');
    var type = CouponType.percent;
    String? error;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (c) => StatefulBuilder(
        builder: (c, set) => Padding(
          padding: EdgeInsets.fromLTRB(Tokens.s16, 0, Tokens.s16, MediaQuery.viewInsetsOf(c).bottom + Tokens.s16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.newCoupon, style: context.text.titleLarge),
              const SizedBox(height: Tokens.s16),
              TextField(
                controller: code,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')), LengthLimitingTextInputFormatter(12)],
                decoration: InputDecoration(labelText: s.couponCode, hintText: 'RAMADAN25', errorText: error),
              ),
              const SizedBox(height: Tokens.s12),
              SegmentedButton<CouponType>(
                segments: [
                  ButtonSegment(value: CouponType.percent, label: Text(s.percentOff), icon: const Icon(Icons.percent_rounded)),
                  ButtonSegment(value: CouponType.fixed, label: Text(s.fixedOff), icon: const Icon(Icons.payments_outlined)),
                ],
                selected: {type},
                onSelectionChanged: (v) => set(() => type = v.first),
              ),
              const SizedBox(height: Tokens.s12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: value,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(labelText: s.couponValue),
                    ),
                  ),
                  const SizedBox(width: Tokens.s12),
                  Expanded(
                    child: TextField(
                      controller: min,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(labelText: s.minOrder),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Tokens.s16),
              FilledButton(
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                onPressed: () {
                  final v = double.tryParse(value.text) ?? 0;
                  if (code.text.length < 3 || v <= 0 || (type == CouponType.percent && v > 90)) return;
                  final ok = ref
                      .read(couponsProvider.notifier)
                      .add(Coupon(code: code.text.toUpperCase(), type: type, value: v, minSubtotal: double.tryParse(min.text) ?? 0));
                  if (!ok) {
                    set(() => error = s.couponExists);
                    return;
                  }
                  Navigator.pop(c);
                },
                child: Text(s.create),
              ),
            ],
          ),
        ),
      ),
    );
    for (final c in [code, value, min]) {
      c.dispose();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = context.s;
    final coupons = ref.watch(couponsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(s.coupons), actions: const [RoleSwitchButton(), SizedBox(width: 4)]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _create(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: Text(s.newCoupon),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(Tokens.s16, Tokens.s16, Tokens.s16, 96),
        itemCount: coupons.length,
        separatorBuilder: (_, _) => const SizedBox(height: Tokens.s12),
        itemBuilder: (_, i) {
          final c = coupons[i];
          return _CouponTicket(
            coupon: c,
            onToggle: () => ref.read(couponsProvider.notifier).toggle(c.code),
          ).animate(key: ValueKey(c.code)).fadeIn().slideX(begin: 0.05);
        },
      ),
    );
  }
}

class _CouponTicket extends ConsumerWidget {
  const _CouponTicket({required this.coupon, required this.onToggle});
  final Coupon coupon;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = context.s;
    final c = coupon;
    final value = c.type == CouponType.percent ? '${c.value.toStringAsFixed(0)}%' : ref.money(context, c.value);
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: c.active ? 1 : 0.55,
      child: ClipPath(
        clipper: _TicketClipper(rtl: Directionality.of(context) == TextDirection.rtl),
        child: Container(
          color: context.colors.surfaceContainerLowest,
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 96,
                  color: c.active ? Palette.oud : context.colors.surfaceContainerHigh,
                  alignment: Alignment.center,
                  child: Text(value, style: context.text.titleLarge?.copyWith(color: c.active ? Palette.gold : context.colors.onSurfaceVariant)),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(Tokens.s16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.code, style: context.text.titleMedium?.copyWith(letterSpacing: 1.5)),
                        if (c.minSubtotal > 0) Text('${s.minOrder}: ${ref.money(context, c.minSubtotal)}', style: context.text.labelSmall),
                        Text(s.couponUses(c.uses), style: context.text.labelSmall?.copyWith(color: context.colors.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Switch(value: c.active, onChanged: (_) => onToggle()),
                      Text(c.active ? s.active : s.inactive, style: context.text.labelSmall),
                    ],
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

class _TicketClipper extends CustomClipper<Path> {
  _TicketClipper({required this.rtl});
  final bool rtl;

  @override
  Path getClip(Size size) {
    const r = 10.0;
    final notchX = rtl ? size.width - 96 : 96.0;
    final p = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(Tokens.cardRadius)));
    final notches = Path()
      ..addOval(Rect.fromCircle(center: Offset(notchX, 0), radius: r))
      ..addOval(Rect.fromCircle(center: Offset(notchX, size.height), radius: r));
    return Path.combine(PathOperation.difference, p, notches);
  }

  @override
  bool shouldReclip(_TicketClipper old) => old.rtl != rtl;
}
