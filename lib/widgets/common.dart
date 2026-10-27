import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../data/models.dart';
import '../state/providers.dart';
import 'product_art.dart';

/// Key of the cart icon in the bottom navigation, the target of the add-to-cart flight.
final navCartKey = GlobalKey(debugLabel: 'navCart');

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(Tokens.s16, Tokens.s24, Tokens.s8, Tokens.s12),
    child: Row(
      children: [
        Expanded(child: Text(title, style: context.text.titleLarge)),
        if (action != null) TextButton(onPressed: onAction, child: Text(action!)),
      ],
    ),
  );
}

class PriceTag extends ConsumerWidget {
  const PriceTag({super.key, required this.price, this.oldPrice, this.big = false});
  final double price;
  final double? oldPrice;
  final bool big;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Wrap(
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: 6,
    children: [
      Text(
        ref.money(context, price),
        style: (big ? context.text.headlineSmall : context.text.titleSmall)?.copyWith(color: context.colors.primary, fontWeight: FontWeight.w700),
      ),
      if (oldPrice != null)
        Text(
          ref.money(context, oldPrice!),
          style: context.text.bodySmall?.copyWith(decoration: TextDecoration.lineThrough, color: context.colors.onSurfaceVariant),
        ),
    ],
  );
}

class Pill extends StatelessWidget {
  const Pill(this.label, {super.key, this.color, this.textColor, this.icon});
  final String label;
  final Color? color;
  final Color? textColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: color ?? context.colors.secondary, borderRadius: BorderRadius.circular(100)),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[Icon(icon, size: 12, color: textColor ?? Palette.oudDeep), const SizedBox(width: 3)],
        Text(
          label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textColor ?? Palette.oudDeep),
        ),
      ],
    ),
  );
}

class RatingRow extends StatelessWidget {
  const RatingRow({super.key, required this.rating, this.count});
  final double rating;
  final int? count;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(Icons.star_rounded, size: 16, color: Palette.gold),
      const SizedBox(width: 2),
      Text(rating.toStringAsFixed(1), style: context.text.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
      if (count != null) Text('  (${context.s.reviewsCount(count!)})', style: context.text.labelSmall?.copyWith(color: context.colors.onSurfaceVariant)),
    ],
  );
}

class FavoriteButton extends ConsumerWidget {
  const FavoriteButton({super.key, required this.productId, this.size = 20, this.filled = true});
  final String productId;
  final double size;
  final bool filled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fav = ref.watch(favoritesProvider.select((s) => s.contains(productId)));
    final icon = Icon(
      fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
      key: ValueKey(fav),
      size: size,
      color: fav ? Palette.danger : context.colors.onSurface,
    );
    return Material(
      color: filled ? context.colors.surfaceContainerLowest.withValues(alpha: 0.92) : Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => ref.read(favoritesProvider.notifier).toggle(productId),
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: fav ? icon.animate().scale(begin: const Offset(0.4, 0.4), curve: Curves.elasticOut, duration: 600.ms) : icon,
        ),
      ),
    );
  }
}

class ProductCard extends ConsumerStatefulWidget {
  const ProductCard({super.key, required this.product, required this.heroScope, this.width});
  final Product product;

  /// Distinguishes the same product shown in two lists on one screen.
  final String heroScope;
  final double? width;

  @override
  ConsumerState<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<ProductCard> {
  final artKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final width = widget.width;
    final heroTag = 'art-${widget.heroScope}-${p.id}';
    return SizedBox(
      width: width,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/product/${p.id}', extra: heroTag),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Hero(
                        tag: heroTag,
                        child: KeyedSubtree(key: artKey, child: ProductArt.of(p, radius: 0)),
                      ),
                    ),
                    PositionedDirectional(
                      top: 8,
                      start: 8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (p.discountPercent != null) Pill('-${p.discountPercent}%', color: Palette.danger, textColor: Colors.white),
                          if (p.isNew) Padding(padding: const EdgeInsets.only(top: 4), child: Pill(context.s.newBadge)),
                        ],
                      ),
                    ),
                    PositionedDirectional(top: 6, end: 6, child: FavoriteButton(productId: p.id, size: 18)),
                    if (p.outOfStock)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.35),
                          alignment: Alignment.center,
                          child: Pill(context.s.outOfStock, color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.brand.of(context), style: context.text.labelSmall?.copyWith(color: context.colors.onSurfaceVariant), maxLines: 1),
                    const SizedBox(height: 2),
                    Text(p.name.of(context), style: context.text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    RatingRow(rating: p.rating),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 6, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: PriceTag(price: p.basePrice, oldPrice: p.oldPrice),
                    ),
                    if (!p.outOfStock)
                      IconButton.filledTonal(
                        visualDensity: VisualDensity.compact,
                        iconSize: 20,
                        icon: const Icon(Icons.add_rounded),
                        onPressed: () => quickAdd(context, ref, p, artKey),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Adds the first variant, or opens the product when there's a real choice to make.
void quickAdd(BuildContext context, WidgetRef ref, Product p, GlobalKey from) {
  if (p.variants.length > 1 && p.variants.any((v) => v.price != p.basePrice || p.category == CategoryId.abayas)) {
    context.push('/product/${p.id}');
    return;
  }
  final ok = ref.read(cartProvider.notifier).add(p.id, p.variants.first.id);
  if (!ok) {
    showToast(context, context.s.stockLimit);
    return;
  }
  flyToCart(context, from: from, to: navCartKey, child: ProductArt.of(p));
}

void showToast(BuildContext context, String message, {String? action, VoidCallback? onAction, IconData icon = Icons.check_circle_rounded}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        persist: false,
        content: Row(
          children: [
            Icon(icon, size: 20, color: Palette.gold),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        action: action == null ? null : SnackBarAction(label: action, textColor: Palette.gold, onPressed: onAction ?? () {}),
      ),
    );
}

/// Flies a thumbnail along an arc from [from] to [to], then bumps the target.
void flyToCart(BuildContext context, {required GlobalKey from, required GlobalKey to, required Widget child}) {
  final overlay = Overlay.maybeOf(context);
  final fromBox = from.currentContext?.findRenderObject() as RenderBox?;
  final toBox = to.currentContext?.findRenderObject() as RenderBox?;
  final overlayBox = overlay?.context.findRenderObject() as RenderBox?;
  if (overlay == null || fromBox == null || toBox == null || overlayBox == null || !toBox.attached) return;
  final start = fromBox.localToGlobal(fromBox.size.center(Offset.zero), ancestor: overlayBox);
  final end = toBox.localToGlobal(toBox.size.center(Offset.zero), ancestor: overlayBox);
  final startSize = fromBox.size.shortestSide.clamp(40.0, 120.0);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOutCubic,
      onEnd: () {
        entry.remove();
        CartBump.bump(to);
      },
      builder: (_, t, _) {
        // Quadratic bezier with the control point above both ends.
        final control = Offset((start.dx + end.dx) / 2, start.dy < end.dy ? start.dy - 120 : end.dy - 120);
        final pos = Offset(
          (1 - t) * (1 - t) * start.dx + 2 * (1 - t) * t * control.dx + t * t * end.dx,
          (1 - t) * (1 - t) * start.dy + 2 * (1 - t) * t * control.dy + t * t * end.dy,
        );
        final size = startSize * (1 - t * 0.8);
        return Positioned(
          left: pos.dx - size / 2,
          top: pos.dy - size / 2,
          child: IgnorePointer(
            child: Opacity(
              opacity: t < 0.9 ? 1 : (1 - t) * 10,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(size / 3),
                  boxShadow: const [BoxShadow(blurRadius: 12, color: Colors.black26)],
                ),
                child: ClipRRect(borderRadius: BorderRadius.circular(size / 3), child: child),
              ),
            ),
          ),
        );
      },
    ),
  );
  overlay.insert(entry);
}

/// Wraps a cart icon so a finished flight can make it bounce.
class CartBump extends StatefulWidget {
  const CartBump({required GlobalKey key, required this.child}) : super(key: key);
  final Widget child;

  static void bump(GlobalKey key) {
    final state = key.currentState;
    if (state is _CartBumpState) state.bump();
  }

  @override
  State<CartBump> createState() => _CartBumpState();
}

class _CartBumpState extends State<CartBump> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));

  void bump() => _c.forward(from: 0);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (_, child) => Transform.scale(scale: 1 + 0.35 * Curves.elasticOut.transform(_c.value) * (1 - _c.value), child: child),
    child: widget.child,
  );
}

class CartBadgeIcon extends ConsumerWidget {
  const CartBadgeIcon({super.key, this.selected = false});
  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = ref.watch(cartCountProvider);
    return Badge(
      isLabelVisible: n > 0,
      label: Text('$n'),
      backgroundColor: Palette.gold,
      textColor: Palette.oudDeep,
      child: Icon(selected ? Icons.shopping_bag_rounded : Icons.shopping_bag_outlined),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, this.body, this.action, this.onAction});
  final IconData icon;
  final String title;
  final String? body;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(Tokens.s32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(color: context.colors.primaryContainer, shape: BoxShape.circle),
            child: Icon(icon, size: 44, color: context.colors.primary),
          ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
          const SizedBox(height: Tokens.s16),
          Text(title, style: context.text.titleLarge, textAlign: TextAlign.center),
          if (body != null) ...[
            const SizedBox(height: Tokens.s8),
            Text(
              body!,
              style: context.text.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
          if (action != null) ...[const SizedBox(height: Tokens.s24), FilledButton(onPressed: onAction, child: Text(action!))],
        ],
      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05),
    ),
  );
}

class QtyStepper extends StatelessWidget {
  const QtyStepper({super.key, required this.value, required this.onChanged, this.min = 1, this.deletable = false});
  final int value;
  final ValueChanged<int> onChanged;
  final int min;

  /// Shows a bin instead of minus at the minimum, for removing cart lines.
  final bool deletable;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      border: Border.all(color: context.colors.outline),
      borderRadius: BorderRadius.circular(Tokens.controlRadius),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: Icon(deletable && value <= min ? Icons.delete_outline_rounded : Icons.remove_rounded, size: 18),
          onPressed: !deletable && value <= min ? null : () => onChanged(value - 1),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
          child: SizedBox(
            width: 22,
            child: Text('$value', key: ValueKey(value), textAlign: TextAlign.center, style: context.text.titleSmall),
          ),
        ),
        IconButton(visualDensity: VisualDensity.compact, icon: const Icon(Icons.add_rounded, size: 18), onPressed: () => onChanged(value + 1)),
      ],
    ),
  );
}

/// Staggered entrance used by lists and grids.
extension StaggerX on Widget {
  Widget stagger(int index) => animate(delay: (40 * (index % 12)).ms).fadeIn(duration: 320.ms).slideY(begin: 0.08, curve: Curves.easeOutCubic);
}

class SummaryRow extends StatelessWidget {
  const SummaryRow(this.label, this.value, {super.key, this.bold = false, this.valueColor});
  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final style = bold ? context.text.titleMedium : context.text.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: style?.copyWith(color: bold ? null : context.colors.onSurfaceVariant)),
          ),
          Text(
            value,
            style: style?.copyWith(fontWeight: bold ? FontWeight.w700 : FontWeight.w600, color: valueColor),
          ),
        ],
      ),
    );
  }
}
