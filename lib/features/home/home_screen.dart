import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../data/photos.dart';
import '../../data/pricing.dart';
import '../../data/seed.dart';
import '../../state/providers.dart';
import '../../widgets/common.dart';
import '../../widgets/product_art.dart';
import '../../widgets/shells.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // A short skeleton on first open, like a real store fetching its catalog.
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final products = ref.watch(visibleProductsProvider);
    final settings = ref.watch(settingsProvider);
    final best = [...products]..sort((a, b) => b.sold.compareTo(a.sold));
    final gifts = products.where((p) => p.tags.any((t) => t.en == 'Gift')).toList();
    final fresh = products.where((p) => p.isNew).toList();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(Tokens.s16, Tokens.s12, Tokens.s8, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(settings.phone == null ? s.greetingGuest : s.greeting(context.isAr ? 'نورة' : 'Noura'), style: context.text.titleLarge),
                          Row(
                            children: [
                              Icon(Icons.location_on_rounded, size: 14, color: context.colors.secondary),
                              const SizedBox(width: 2),
                              Text(
                                '${s.deliverTo} ${context.isAr ? 'الرياض، حي الملقا' : 'Riyadh, Al Malqa'}',
                                style: context.text.bodySmall?.copyWith(color: context.colors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(onPressed: () => context.push('/favorites'), icon: const Icon(Icons.favorite_border_rounded)),
                    const RoleSwitchButton(),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(Tokens.s16, Tokens.s16, Tokens.s16, 0),
                child: Hero(
                  tag: 'search',
                  child: Material(
                    color: context.colors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(Tokens.controlRadius),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(Tokens.controlRadius),
                      onTap: () => context.push('/search'),
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: Tokens.s16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Tokens.controlRadius),
                          border: Border.all(color: context.colors.outline),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search_rounded, color: context.colors.onSurfaceVariant),
                            const SizedBox(width: Tokens.s12),
                            Text(s.searchHint, style: context.text.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: _OfferCarousel()),
            SliverToBoxAdapter(
              child: SectionHeader(s.categories, action: s.seeAll, onAction: () => context.go('/categories')),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 128,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: Tokens.s16),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: Tokens.s12),
                  itemBuilder: (_, i) => _CategoryChip(category: categories[i]).stagger(i),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(Tokens.s16, Tokens.s16, Tokens.s16, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: Tokens.s16, vertical: Tokens.s12),
                  decoration: BoxDecoration(color: context.colors.primaryContainer, borderRadius: BorderRadius.circular(Tokens.controlRadius)),
                  child: Row(
                    children: [
                      Icon(Icons.local_shipping_rounded, color: context.colors.primary),
                      const SizedBox(width: Tokens.s12),
                      Expanded(
                        child: Text(
                          s.freeShippingOver(ref.money(context, ShippingRules.freeThreshold)),
                          style: context.text.titleSmall?.copyWith(color: context.colors.onPrimaryContainer),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SectionHeader(s.bestSellers, action: s.seeAll, onAction: () => context.push('/category/all?f=best')),
            ),
            SliverToBoxAdapter(
              child: _ProductRail(products: best.take(8).toList(), scope: 'best', loading: _loading),
            ),
            SliverToBoxAdapter(child: SectionHeader(s.giftIdeas)),
            SliverToBoxAdapter(
              child: _ProductRail(products: gifts, scope: 'gift', loading: _loading),
            ),
            SliverToBoxAdapter(
              child: SectionHeader(s.newArrivals, action: s.seeAll, onAction: () => context.push('/category/all?f=new')),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(Tokens.s16, 0, Tokens.s16, Tokens.s32),
              sliver: SliverGrid.builder(
                gridDelegate: productGridDelegate,
                itemCount: _loading ? 4 : fresh.length,
                itemBuilder: (_, i) => _loading ? const ProductSkeleton() : ProductCard(product: fresh[i], heroScope: 'new').stagger(i),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const productGridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 2,
  mainAxisSpacing: Tokens.s12,
  crossAxisSpacing: Tokens.s12,
  childAspectRatio: 0.6,
);

class ProductSkeleton extends StatelessWidget {
  const ProductSkeleton({super.key, this.width});
  final double? width;

  @override
  Widget build(BuildContext context) {
    final c = context.colors.surfaceContainerHigh;
    Widget bar(double w, double h) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(6)),
    );
    return SizedBox(
      width: width,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: c,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(Tokens.cardRadius)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [bar(50, 10), const SizedBox(height: 8), bar(110, 14), const SizedBox(height: 8), bar(70, 12)],
              ),
            ),
          ],
        ),
      ).animate(onPlay: (a) => a.repeat()).shimmer(duration: 1100.ms, color: Colors.white.withValues(alpha: 0.5)),
    );
  }
}

class _ProductRail extends StatelessWidget {
  const _ProductRail({required this.products, required this.scope, required this.loading});
  final List<Product> products;
  final String scope;
  final bool loading;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 290,
    child: ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: Tokens.s16),
      scrollDirection: Axis.horizontal,
      itemCount: loading ? 3 : products.length,
      separatorBuilder: (_, _) => const SizedBox(width: Tokens.s12),
      itemBuilder: (_, i) => loading ? const ProductSkeleton(width: 168) : ProductCard(product: products[i], heroScope: scope, width: 168).stagger(i),
    ),
  );
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category});
  final Category category;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112,
      child: InkWell(
        borderRadius: BorderRadius.circular(Tokens.cardRadius),
        onTap: () => context.push('/category/${category.id.name}'),
        child: Column(
          children: [
            SizedBox(
              width: 96,
              height: 92,
              child: ProductArt(kind: category.art, color: category.color, accent: Palette.gold, radius: Tokens.cardRadius, photo: categoryPhoto(category.id)),
            ),
            const SizedBox(height: 8),
            Text(category.name.of(context), style: context.text.labelLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _OfferCarousel extends StatefulWidget {
  const _OfferCarousel();

  @override
  State<_OfferCarousel> createState() => _OfferCarouselState();
}

class _OfferCarouselState extends State<_OfferCarousel> {
  final _page = PageController(viewportFraction: 0.92);
  late final DateTime _endsAt = DateTime.now().add(const Duration(days: 2, hours: 5, minutes: 41));
  Timer? _tick;
  Timer? _auto;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
    _auto = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_page.hasClients) _page.animateToPage((_index + 1) % 3, duration: const Duration(milliseconds: 600), curve: Curves.easeInOutCubic);
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    _auto?.cancel();
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final left = _endsAt.difference(DateTime.now());
    String two(int v) => v.toString().padLeft(2, '0');
    final banners = [
      (s.offerTitle, s.offerBody, ArtKind.burner, const Color(0xFF7A4B2A), '/category/perfumes?f=sale', true, productPhoto('p2')),
      (s.giftIdeas, s.bannerGiftBody, ArtKind.gift, const Color(0xFF4A1E2C), '/product/p10', false, productPhoto('p10')),
      (s.bannerDatesTitle, s.bannerDatesBody, ArtKind.datesBox, const Color(0xFF8A5A2B), '/category/dates', false, productPhoto('d1')),
    ];
    return Column(
      children: [
        const SizedBox(height: Tokens.s16),
        SizedBox(
          height: 168,
          child: PageView.builder(
            controller: _page,
            itemCount: banners.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) {
              final (title, body, art, color, route, countdown, photo) = banners[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Material(
                  color: color,
                  borderRadius: BorderRadius.circular(Tokens.cardRadius),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => context.push(route),
                    child: Stack(
                      children: [
                        if (photo == null)
                          PositionedDirectional(
                            end: -10,
                            top: 0,
                            bottom: 0,
                            width: 160,
                            child: ProductArt(kind: art, color: Color.lerp(color, Colors.white, 0.15)!, accent: Palette.gold, background: false),
                          )
                        else ...[
                          Positioned.fill(
                            child: Image.asset(photo, fit: BoxFit.cover, alignment: AlignmentDirectional.centerEnd.resolve(Directionality.of(context))),
                          ),
                          // Fade the photo into the banner color behind the text.
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: AlignmentDirectional.centerStart.resolve(Directionality.of(context)),
                                  end: AlignmentDirectional.centerEnd.resolve(Directionality.of(context)),
                                  colors: [color, color.withValues(alpha: 0.9), color.withValues(alpha: 0)],
                                  stops: const [0, 0.45, 0.85],
                                ),
                              ),
                            ),
                          ),
                        ],
                        Padding(
                          padding: const EdgeInsets.all(Tokens.s16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 190,
                                child: Text(title, style: context.text.titleLarge?.copyWith(color: Colors.white)),
                              ),
                              const SizedBox(height: 4),
                              SizedBox(
                                width: 190,
                                child: Text(body, maxLines: 2, style: context.text.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.85))),
                              ),
                              const Spacer(),
                              if (countdown)
                                Row(
                                  children: [
                                    Text('${s.endsIn} ', style: context.text.labelSmall?.copyWith(color: Palette.goldSoft)),
                                    Directionality(
                                      textDirection: TextDirection.ltr,
                                      child: Row(
                                        children: [
                                          for (final v in [left.inDays * 24 + left.inHours % 24, left.inMinutes % 60, left.inSeconds % 60]) ...[
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              margin: const EdgeInsets.symmetric(horizontal: 2),
                                              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(6)),
                                              child: Text(
                                                two(v),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                  fontFeatures: [FontFeature.tabularFigures()],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(color: Palette.gold, borderRadius: BorderRadius.circular(100)),
                                  child: Text(
                                    s.shopNow,
                                    style: const TextStyle(color: Palette.oudDeep, fontWeight: FontWeight.w700, fontSize: 12),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: Tokens.s8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < 3; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _index ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(color: i == _index ? context.colors.primary : context.colors.outline, borderRadius: BorderRadius.circular(3)),
              ),
          ],
        ),
      ],
    );
  }
}
