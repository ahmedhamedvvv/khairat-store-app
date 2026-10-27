import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../state/providers.dart';
import '../../widgets/common.dart';
import '../../widgets/product_art.dart';

const _highlights = {
  CategoryId.perfumes: [
    (Icons.timer_outlined, Bi('ثبات عالي', 'Long lasting')),
    (Icons.verified_outlined, Bi('أصلي 100%', '100% authentic')),
    (Icons.card_giftcard_rounded, Bi('مناسب للإهداء', 'Gift ready')),
  ],
  CategoryId.abayas: [
    (Icons.straighten_rounded, Bi('مقاسات 52-60', 'Sizes 52-60')),
    (Icons.dry_cleaning_outlined, Bi('غسيل جاف', 'Dry clean')),
    (Icons.swap_horiz_rounded, Bi('استبدال خلال 7 أيام', '7-day exchange')),
  ],
  CategoryId.dates: [
    (Icons.eco_outlined, Bi('موسم 2026', '2026 season')),
    (Icons.agriculture_outlined, Bi('من المزرعة مباشرة', 'Farm direct')),
    (Icons.ac_unit_rounded, Bi('تغليف مبرد', 'Chilled packing')),
  ],
};

class ProductScreen extends ConsumerStatefulWidget {
  const ProductScreen({super.key, required this.id, this.heroTag});
  final String id;
  final String? heroTag;

  @override
  ConsumerState<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends ConsumerState<ProductScreen> {
  final _artKey = GlobalKey();
  final _cartKey = GlobalKey();
  String? _variantId;
  int _qty = 1;

  void _add(Product p, Variant v) {
    final ok = ref.read(cartProvider.notifier).add(p.id, v.id, qty: _qty);
    if (!ok) {
      showToast(context, context.s.stockLimit, icon: Icons.error_outline_rounded);
      return;
    }
    flyToCart(context, from: _artKey, to: _cartKey, child: ProductArt.of(p));
    showToast(context, context.s.addedToCart, action: context.s.viewCart, onAction: () => context.go('/cart'));
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final p = ref.watch(productProvider(widget.id));
    final v = p.variant(_variantId ?? p.variants.first.id);
    final similar = ref.watch(visibleProductsProvider).where((e) => e.category == p.category && e.id != p.id).take(6).toList();
    final oldPrice = p.oldPrice == null ? null : p.oldPrice! + (v.price - p.basePrice);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 380,
            pinned: true,
            stretch: true,
            backgroundColor: context.colors.surface,
            leading: Padding(
              padding: const EdgeInsets.all(6),
              child: IconButton.filledTonal(onPressed: () => context.pop(), icon: const BackButtonIcon()),
            ),
            actions: [
              FavoriteButton(productId: p.id),
              const SizedBox(width: 6),
              CartBump(
                key: _cartKey,
                child: IconButton.filledTonal(onPressed: () => context.go('/cart'), icon: const CartBadgeIcon()),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Hero(
                tag: widget.heroTag ?? 'art-${p.id}',
                child: KeyedSubtree(key: _artKey, child: ProductArt.of(p, radius: 0)),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(Tokens.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(p.brand.of(context), style: context.text.labelLarge?.copyWith(color: context.colors.secondary)),
                      const Spacer(),
                      for (final t in p.tags) Padding(padding: const EdgeInsetsDirectional.only(start: 6), child: Pill(t.of(context))),
                      if (p.isNew) Padding(padding: const EdgeInsetsDirectional.only(start: 6), child: Pill(s.newBadge)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(p.name.of(context), style: context.text.headlineSmall),
                  const SizedBox(height: Tokens.s8),
                  Row(
                    children: [
                      RatingRow(rating: p.rating, count: p.ratingCount),
                      const SizedBox(width: Tokens.s12),
                      Text('• ${s.soldCount(p.sold)}', style: context.text.labelMedium?.copyWith(color: context.colors.onSurfaceVariant)),
                    ],
                  ),
                  const SizedBox(height: Tokens.s16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (c, a) => FadeTransition(
                          opacity: a,
                          child: SlideTransition(
                            position: Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(a),
                            child: c,
                          ),
                        ),
                        child: PriceTag(key: ValueKey(v.id), price: v.price, oldPrice: oldPrice, big: true),
                      ),
                      const Spacer(),
                      _StockLabel(product: p),
                    ],
                  ),
                  Text(s.vatIncluded, style: context.text.labelSmall?.copyWith(color: context.colors.onSurfaceVariant)),
                  if (p.variants.length > 1) ...[
                    const SizedBox(height: Tokens.s24),
                    Text(s.chooseOption, style: context.text.titleMedium),
                    const SizedBox(height: Tokens.s8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final o in p.variants)
                          ChoiceChip(
                            label: Text(o.label.of(context)),
                            selected: o.id == v.id,
                            showCheckmark: false,
                            selectedColor: context.colors.primary,
                            labelStyle: TextStyle(color: o.id == v.id ? context.colors.onPrimary : context.colors.onSurface, fontWeight: FontWeight.w600),
                            onSelected: (_) => setState(() => _variantId = o.id),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: Tokens.s24),
                  Row(
                    children: [
                      for (final (icon, label) in _highlights[p.category]!)
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(color: context.colors.primaryContainer, shape: BoxShape.circle),
                                child: Icon(icon, size: 22, color: context.colors.primary),
                              ),
                              const SizedBox(height: 6),
                              Text(label.of(context), style: context.text.labelSmall, textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: Tokens.s24),
                  Text(s.description, style: context.text.titleMedium),
                  const SizedBox(height: Tokens.s8),
                  Text(p.description.of(context), style: context.text.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant)),
                  const SizedBox(height: Tokens.s24),
                  Row(
                    children: [
                      Expanded(child: Text(s.reviews, style: context.text.titleMedium)),
                      RatingRow(rating: p.rating, count: p.ratingCount),
                    ],
                  ),
                  const SizedBox(height: Tokens.s8),
                  for (final r in p.reviews) _ReviewTile(review: r),
                ],
              ),
            ),
          ),
          if (similar.isNotEmpty) ...[
            SliverToBoxAdapter(child: SectionHeader(s.similar)),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 290,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: Tokens.s16),
                  scrollDirection: Axis.horizontal,
                  itemCount: similar.length,
                  separatorBuilder: (_, _) => const SizedBox(width: Tokens.s12),
                  itemBuilder: (_, i) => ProductCard(product: similar[i], heroScope: 'similar-${p.id}', width: 168),
                ),
              ),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(Tokens.s16, Tokens.s12, Tokens.s16, Tokens.s12 + MediaQuery.paddingOf(context).bottom),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerLowest,
          border: Border(top: BorderSide(color: context.colors.outlineVariant)),
        ),
        child: Row(
          children: [
            QtyStepper(value: _qty, min: 1, onChanged: (q) => setState(() => _qty = q.clamp(1, 20))),
            const SizedBox(width: Tokens.s12),
            Expanded(
              child: FilledButton.icon(
                onPressed: p.outOfStock ? null : () => _add(p, v),
                icon: const Icon(Icons.shopping_bag_rounded),
                label: Text(p.outOfStock ? s.outOfStock : '${s.addToCart} • ${ref.money(context, v.price * _qty)}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StockLabel extends StatelessWidget {
  const _StockLabel({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final (label, color) = product.outOfStock
        ? (context.s.outOfStock, Palette.danger)
        : product.lowStock
        ? (context.s.onlyLeft(product.stock), const Color(0xFFB7791F))
        : (context.s.inStock, Palette.success);
    final w = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: context.text.labelLarge?.copyWith(color: color)),
      ],
    );
    return product.lowStock ? w.animate(onPlay: (c) => c.repeat(reverse: true)).fade(begin: 1, end: 0.55, duration: 900.ms) : w;
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});
  final Review review;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: context.colors.primaryContainer,
          child: Text(
            review.author.characters.first,
            style: TextStyle(color: context.colors.primary, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: Tokens.s12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(review.author, style: context.text.titleSmall),
                  Text(' • ${review.city.of(context)}', style: context.text.labelSmall?.copyWith(color: context.colors.onSurfaceVariant)),
                  const Spacer(),
                  for (var i = 0; i < 5; i++) Icon(Icons.star_rounded, size: 14, color: i < review.rating ? Palette.gold : context.colors.outline),
                ],
              ),
              const SizedBox(height: 2),
              Text(review.text.of(context), style: context.text.bodySmall),
            ],
          ),
        ),
      ],
    ),
  );
}
