import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../data/photos.dart';
import '../../data/seed.dart';
import '../../state/providers.dart';
import '../../widgets/common.dart';
import '../../widgets/product_art.dart';
import '../home/home_screen.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(visibleProductsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(context.s.categories),
        actions: [IconButton(onPressed: () => context.push('/search'), icon: const Icon(Icons.search_rounded))],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(Tokens.s16),
        itemCount: categories.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: Tokens.s16),
        itemBuilder: (_, i) {
          if (i == categories.length) {
            return OutlinedButton.icon(
              onPressed: () => context.push('/category/all'),
              icon: const Icon(Icons.apps_rounded),
              label: Text(context.s.allProducts),
            );
          }
          final c = categories[i];
          final count = products.where((p) => p.category == c.id).length;
          return Material(
            color: c.color,
            borderRadius: BorderRadius.circular(Tokens.cardRadius),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => context.push('/category/${c.id.name}'),
              child: SizedBox(
                height: 150,
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(Tokens.s24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(c.name.of(context), style: context.text.titleLarge?.copyWith(color: Colors.white)),
                            const SizedBox(height: 4),
                            Text(c.tagline.of(context), style: context.text.bodySmall?.copyWith(color: Colors.white70)),
                            const SizedBox(height: Tokens.s12),
                            Pill(context.s.productsCount(count)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 140,
                      child: ProductArt(kind: c.art, color: Color.lerp(c.color, Colors.white, 0.2)!, accent: Palette.gold, background: false, photo: categoryPhoto(c.id)),
                    ),
                  ],
                ),
              ),
            ),
          ).stagger(i);
        },
      ),
    );
  }
}

enum SortBy { popular, priceLow, priceHigh, rating, newest }

class _Filters {
  const _Filters({this.sort = SortBy.popular, this.inStock = false, this.onSale = false, this.maxPrice, this.brand});
  final SortBy sort;
  final bool inStock;
  final bool onSale;
  final double? maxPrice;
  final String? brand;

  _Filters copyWith({SortBy? sort, bool? inStock, bool? onSale, double? maxPrice, bool clearMax = false, String? brand, bool clearBrand = false}) => _Filters(
    sort: sort ?? this.sort,
    inStock: inStock ?? this.inStock,
    onSale: onSale ?? this.onSale,
    maxPrice: clearMax ? null : (maxPrice ?? this.maxPrice),
    brand: clearBrand ? null : (brand ?? this.brand),
  );

  int get activeCount => (inStock ? 1 : 0) + (onSale ? 1 : 0) + (maxPrice != null ? 1 : 0);
}

class CategoryScreen extends ConsumerStatefulWidget {
  const CategoryScreen({super.key, required this.id, this.initialFilter});
  final String id;

  /// `best`, `new` or `sale`, from home page shortcuts.
  final String? initialFilter;

  @override
  ConsumerState<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen> {
  late _Filters _f = switch (widget.initialFilter) {
    'new' => const _Filters(sort: SortBy.newest),
    'sale' => const _Filters(onSale: true),
    _ => const _Filters(),
  };
  late final bool _onlyNew = widget.initialFilter == 'new';

  Category? get _category => categories.where((c) => c.id.name == widget.id).firstOrNull;

  List<Product> _apply(List<Product> all) {
    var list = all.where((p) => _category == null || p.category == _category!.id).toList();
    if (_onlyNew) list = list.where((p) => p.isNew).toList();
    if (_f.brand != null) list = list.where((p) => p.brand.en == _f.brand).toList();
    if (_f.inStock) list = list.where((p) => !p.outOfStock).toList();
    if (_f.onSale) list = list.where((p) => p.oldPrice != null).toList();
    if (_f.maxPrice != null) list = list.where((p) => p.basePrice <= _f.maxPrice!).toList();
    switch (_f.sort) {
      case SortBy.popular:
        list.sort((a, b) => b.sold.compareTo(a.sold));
      case SortBy.priceLow:
        list.sort((a, b) => a.basePrice.compareTo(b.basePrice));
      case SortBy.priceHigh:
        list.sort((a, b) => b.basePrice.compareTo(a.basePrice));
      case SortBy.rating:
        list.sort((a, b) => b.rating.compareTo(a.rating));
      case SortBy.newest:
        list.sort((a, b) => (b.isNew ? 1 : 0).compareTo(a.isNew ? 1 : 0));
    }
    return list;
  }

  String _sortLabel(SortBy s) => switch (s) {
    SortBy.popular => context.s.sortPopular,
    SortBy.priceLow => context.s.sortPriceLow,
    SortBy.priceHigh => context.s.sortPriceHigh,
    SortBy.rating => context.s.sortRating,
    SortBy.newest => context.s.sortNewest,
  };

  Future<void> _openSort() async {
    final picked = await showModalBottomSheet<SortBy>(
      context: context,
      builder: (c) => SafeArea(
        child: RadioGroup<SortBy>(
          groupValue: _f.sort,
          onChanged: (v) => Navigator.pop(c, v),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [for (final s in SortBy.values) RadioListTile<SortBy>(value: s, title: Text(_sortLabel(s)))],
          ),
        ),
      ),
    );
    if (picked != null) setState(() => _f = _f.copyWith(sort: picked));
  }

  Future<void> _openFilter(double ceiling) async {
    var draft = _f;
    final result = await showModalBottomSheet<_Filters>(
      context: context,
      isScrollControlled: true,
      builder: (c) => StatefulBuilder(
        builder: (c, set) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Tokens.s16, 0, Tokens.s16, Tokens.s16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.s.filter, style: context.text.titleLarge),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.s.inStockOnly),
                  value: draft.inStock,
                  onChanged: (v) => set(() => draft = draft.copyWith(inStock: v)),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.s.onSaleOnly),
                  value: draft.onSale,
                  onChanged: (v) => set(() => draft = draft.copyWith(onSale: v)),
                ),
                const SizedBox(height: Tokens.s8),
                Text(context.s.maxPrice(ref.money(context, draft.maxPrice ?? ceiling)), style: context.text.titleSmall),
                Slider(
                  min: 40,
                  max: ceiling,
                  divisions: 20,
                  value: (draft.maxPrice ?? ceiling).clamp(40, ceiling),
                  onChanged: (v) => set(() => draft = v >= ceiling ? draft.copyWith(clearMax: true) : draft.copyWith(maxPrice: v.roundToDouble())),
                ),
                const SizedBox(height: Tokens.s8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(c, _Filters(sort: draft.sort, brand: draft.brand)),
                        child: Text(context.s.reset),
                      ),
                    ),
                    const SizedBox(width: Tokens.s12),
                    Expanded(
                      child: FilledButton(onPressed: () => Navigator.pop(c, draft), child: Text(context.s.apply)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (result != null) setState(() => _f = result);
  }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(visibleProductsProvider);
    final inScope = all.where((p) => _category == null || p.category == _category!.id).toList();
    final brands = {for (final p in inScope) p.brand.en: p.brand}.values.toList();
    final ceiling = inScope.isEmpty ? 1000.0 : (inScope.map((p) => p.basePrice).reduce((a, b) => a > b ? a : b) / 50).ceil() * 50.0;
    final list = _apply(all);
    final title =
        _category?.name.of(context) ??
        (widget.initialFilter == 'best'
            ? context.s.bestSellers
            : widget.initialFilter == 'new'
            ? context.s.newArrivals
            : context.s.allProducts);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [IconButton(onPressed: () => context.push('/search'), icon: const Icon(Icons.search_rounded))],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: Tokens.s16, vertical: 6),
                children: [
                  ChoiceChip(label: Text(context.s.all), selected: _f.brand == null, onSelected: (_) => setState(() => _f = _f.copyWith(clearBrand: true))),
                  for (final b in brands)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: Tokens.s8),
                      child: ChoiceChip(
                        label: Text(b.of(context)),
                        selected: _f.brand == b.en,
                        onSelected: (_) => setState(() => _f = _f.copyWith(brand: b.en)),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Tokens.s16, Tokens.s4, Tokens.s8, Tokens.s8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(context.s.productsCount(list.length), style: context.text.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant)),
                  ),
                  TextButton.icon(onPressed: _openSort, icon: const Icon(Icons.swap_vert_rounded, size: 18), label: Text(_sortLabel(_f.sort))),
                  Badge(
                    isLabelVisible: _f.activeCount > 0,
                    label: Text('${_f.activeCount}'),
                    child: TextButton.icon(
                      onPressed: () => _openFilter(ceiling),
                      icon: const Icon(Icons.tune_rounded, size: 18),
                      label: Text(context.s.filter),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (list.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.search_off_rounded,
                title: context.s.noResults,
                body: context.s.noResultsBody,
                action: context.s.reset,
                onAction: () => setState(() => _f = const _Filters()),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(Tokens.s16, 0, Tokens.s16, Tokens.s32),
              sliver: SliverGrid.builder(
                gridDelegate: productGridDelegate,
                itemCount: list.length,
                itemBuilder: (_, i) => ProductCard(key: ValueKey(list[i].id), product: list[i], heroScope: 'cat').stagger(i),
              ),
            ),
        ],
      ),
    );
  }
}

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _q = TextEditingController();

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  List<Product> _results(List<Product> all, String q) {
    final terms = q.trim().toLowerCase().split(RegExp(r'\s+')).where((t) => t.isNotEmpty);
    if (terms.isEmpty) return [];
    return all.where((p) {
      final hay = '${p.name.ar} ${p.name.en} ${p.brand.ar} ${p.brand.en} ${p.description.ar} ${p.description.en}'.toLowerCase();
      return terms.every(hay.contains);
    }).toList()..sort((a, b) => b.sold.compareTo(a.sold));
  }

  void _search(String v) {
    _q.text = v;
    _q.selection = TextSelection.collapsed(offset: v.length);
    ref.read(recentSearchesProvider.notifier).add(v);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final all = ref.watch(visibleProductsProvider);
    final recent = ref.watch(recentSearchesProvider);
    final results = _results(all, _q.text);
    final popular = context.isAr ? ['عود', 'سكري', 'عباية مطرزة', 'هدية', 'قهوة', 'مسك'] : ['oud', 'sukkari', 'embroidered', 'gift', 'coffee', 'musk'];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Hero(
          tag: 'search',
          child: Material(
            type: MaterialType.transparency,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(end: Tokens.s16),
              child: TextField(
                controller: _q,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onChanged: (_) => setState(() {}),
                onSubmitted: (v) => ref.read(recentSearchesProvider.notifier).add(v),
                decoration: InputDecoration(
                  hintText: s.searchHint,
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _q.text.isEmpty ? null : IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => setState(_q.clear)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
        ),
      ),
      body: _q.text.trim().isEmpty
          ? ListView(
              padding: const EdgeInsets.all(Tokens.s16),
              children: [
                if (recent.isNotEmpty) ...[
                  Row(
                    children: [
                      Expanded(child: Text(s.recentSearches, style: context.text.titleMedium)),
                      TextButton(onPressed: () => ref.read(recentSearchesProvider.notifier).clear(), child: Text(s.clear)),
                    ],
                  ),
                  for (final r in recent)
                    ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.history_rounded), title: Text(r), onTap: () => _search(r)),
                  const SizedBox(height: Tokens.s16),
                ],
                Text(s.popularSearches, style: context.text.titleMedium),
                const SizedBox(height: Tokens.s12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final p in popular) ActionChip(avatar: const Icon(Icons.trending_up_rounded, size: 16), label: Text(p), onPressed: () => _search(p)),
                  ],
                ),
              ],
            ).animate().fadeIn(duration: 200.ms)
          : results.isEmpty
          ? EmptyState(icon: Icons.search_off_rounded, title: s.noResults, body: s.noResultsBody)
          : GridView.builder(
              padding: const EdgeInsets.all(Tokens.s16),
              gridDelegate: productGridDelegate,
              itemCount: results.length,
              itemBuilder: (_, i) => ProductCard(key: ValueKey(results[i].id), product: results[i], heroScope: 'search').stagger(i),
            ),
    );
  }
}

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ids = ref.watch(favoritesProvider);
    final list = ref.watch(visibleProductsProvider).where((p) => ids.contains(p.id)).toList();
    return Scaffold(
      appBar: AppBar(title: Text(context.s.favorites)),
      body: list.isEmpty
          ? EmptyState(
              icon: Icons.favorite_border_rounded,
              title: context.s.favoritesEmpty,
              body: context.s.favoritesEmptyBody,
              action: context.s.startShopping,
              onAction: () => context.go('/home'),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(Tokens.s16),
              gridDelegate: productGridDelegate,
              itemCount: list.length,
              itemBuilder: (_, i) => ProductCard(key: ValueKey(list[i].id), product: list[i], heroScope: 'fav').stagger(i),
            ),
    );
  }
}
