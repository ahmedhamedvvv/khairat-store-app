import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models.dart';
import '../data/pricing.dart';
import '../data/repository.dart';
import '../data/seed.dart';

final repositoryProvider = Provider<StoreRepository>((ref) => throw UnimplementedError('overridden in main'));

enum Role { customer, merchant }

class AppSettings {
  const AppSettings({this.locale = const Locale('ar'), this.themeMode = ThemeMode.light, this.region = Region.sa, this.role, this.phone});
  final Locale locale;
  final ThemeMode themeMode;
  final Region region;
  final Role? role;

  /// Null while browsing as a guest.
  final String? phone;

  AppSettings copyWith({Locale? locale, ThemeMode? themeMode, Region? region, Role? role, bool clearRole = false, String? phone}) => AppSettings(
    locale: locale ?? this.locale,
    themeMode: themeMode ?? this.themeMode,
    region: region ?? this.region,
    role: clearRole ? null : (role ?? this.role),
    phone: phone ?? this.phone,
  );

  Map<String, dynamic> toJson() => {'locale': locale.languageCode, 'theme': themeMode.name, 'region': region.name, 'role': role?.name, 'phone': phone};

  factory AppSettings.fromJson(Map<String, dynamic> j) => AppSettings(
    locale: Locale((j['locale'] ?? 'ar') as String),
    themeMode: ThemeMode.values.byName((j['theme'] ?? 'light') as String),
    region: Region.values.byName((j['region'] ?? 'sa') as String),
    role: j['role'] == null ? null : Role.values.byName(j['role'] as String),
    phone: j['phone'] as String?,
  );
}

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => AppSettings.fromJson(ref.read(repositoryProvider).loadSettings());

  void _set(AppSettings s) {
    state = s;
    ref.read(repositoryProvider).saveSettings(s.toJson());
  }

  void toggleLocale() => _set(state.copyWith(locale: Locale(state.locale.languageCode == 'ar' ? 'en' : 'ar')));
  void setTheme(ThemeMode m) => _set(state.copyWith(themeMode: m));
  void setRegion(Region r) => _set(state.copyWith(region: r));
  void setRole(Role? r) => _set(r == null ? state.copyWith(clearRole: true) : state.copyWith(role: r));
  void login(String phone) => _set(state.copyWith(phone: phone));
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

class ProductsNotifier extends Notifier<List<Product>> {
  @override
  List<Product> build() => ref.read(repositoryProvider).loadProducts();

  void _set(List<Product> v) {
    state = v;
    ref.read(repositoryProvider).saveProducts(v);
  }

  Product byId(String id) => state.firstWhere((p) => p.id == id);

  void update(String id, {int? stock, double? price, bool? active}) =>
      _set([for (final p in state) p.id == id ? p.copyWith(stock: stock, price: price, active: active) : p]);

  /// Takes stock out and counts the sale when an order is placed.
  void consume(List<OrderLine> lines) {
    final byProduct = <String, int>{};
    for (final l in lines) {
      byProduct[l.productId] = (byProduct[l.productId] ?? 0) + l.qty;
    }
    _set([
      for (final p in state)
        byProduct.containsKey(p.id) ? p.copyWith(stock: (p.stock - byProduct[p.id]!).clamp(0, 1 << 30), sold: p.sold + byProduct[p.id]!) : p,
    ]);
  }

  void restock(List<OrderLine> lines) {
    _set([for (final p in state) p.copyWith(stock: p.stock + lines.where((l) => l.productId == p.id).fold(0, (s, l) => s + l.qty))]);
  }
}

final productsProvider = NotifierProvider<ProductsNotifier, List<Product>>(ProductsNotifier.new);

final visibleProductsProvider = Provider<List<Product>>((ref) => ref.watch(productsProvider).where((p) => p.active).toList());

final productProvider = Provider.family<Product, String>(
  (ref, id) => ref.watch(productsProvider).firstWhere((p) => p.id == id, orElse: () => seedProducts.first),
);

class FavoritesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => ref.read(repositoryProvider).loadFavorites();

  bool toggle(String id) {
    final added = !state.contains(id);
    state = added ? {...state, id} : ({...state}..remove(id));
    ref.read(repositoryProvider).saveFavorites(state);
    return added;
  }
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, Set<String>>(FavoritesNotifier.new);

class RecentSearchesNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => ref.read(repositoryProvider).loadSearches();

  void add(String q) {
    q = q.trim();
    if (q.isEmpty) return;
    state = [q, ...state.where((e) => e != q)].take(6).toList();
    ref.read(repositoryProvider).saveSearches(state);
  }

  void clear() {
    state = [];
    ref.read(repositoryProvider).saveSearches(state);
  }
}

final recentSearchesProvider = NotifierProvider<RecentSearchesNotifier, List<String>>(RecentSearchesNotifier.new);

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => ref.read(repositoryProvider).loadCart();

  void _set(List<CartItem> v) {
    state = v;
    ref.read(repositoryProvider).saveCart(v);
  }

  /// Returns false when the stock can't cover the requested quantity.
  bool add(String productId, String variantId, {int qty = 1}) {
    final stock = ref.read(productProvider(productId)).stock;
    final inCart = state.where((c) => c.productId == productId).fold(0, (s, c) => s + c.qty);
    if (inCart + qty > stock) return false;
    final i = state.indexWhere((c) => c.productId == productId && c.variantId == variantId);
    if (i < 0) {
      _set([...state, CartItem(productId: productId, variantId: variantId, qty: qty)]);
    } else {
      _set([for (var j = 0; j < state.length; j++) j == i ? state[j].withQty(state[j].qty + qty) : state[j]]);
    }
    return true;
  }

  bool setQty(String key, int qty) {
    if (qty <= 0) {
      remove(key);
      return true;
    }
    final item = state.firstWhere((c) => c.key == key);
    final stock = ref.read(productProvider(item.productId)).stock;
    final others = state.where((c) => c.productId == item.productId && c.key != key).fold(0, (s, c) => s + c.qty);
    if (others + qty > stock) return false;
    _set([for (final c in state) c.key == key ? c.withQty(qty) : c]);
    return true;
  }

  void remove(String key) => _set(state.where((c) => c.key != key).toList());
  void clear() => _set([]);
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);

final cartCountProvider = Provider<int>((ref) => ref.watch(cartProvider).fold(0, (s, c) => s + c.qty));

class CheckoutDraft {
  const CheckoutDraft({
    this.coupon,
    this.giftWrap = false,
    this.giftMessage = '',
    this.slot = DeliverySlot.standard,
    this.payment = PaymentMethod.mada,
    this.address = demoAddress,
  });
  final Coupon? coupon;
  final bool giftWrap;
  final String giftMessage;
  final DeliverySlot slot;
  final PaymentMethod payment;
  final Address address;

  CheckoutDraft copyWith({
    Coupon? coupon,
    bool clearCoupon = false,
    bool? giftWrap,
    String? giftMessage,
    DeliverySlot? slot,
    PaymentMethod? payment,
    Address? address,
  }) => CheckoutDraft(
    coupon: clearCoupon ? null : (coupon ?? this.coupon),
    giftWrap: giftWrap ?? this.giftWrap,
    giftMessage: giftMessage ?? this.giftMessage,
    slot: slot ?? this.slot,
    payment: payment ?? this.payment,
    address: address ?? this.address,
  );
}

class CheckoutNotifier extends Notifier<CheckoutDraft> {
  @override
  CheckoutDraft build() => const CheckoutDraft();

  void set(CheckoutDraft d) => state = d;
  void reset() => state = const CheckoutDraft();
}

final checkoutProvider = NotifierProvider<CheckoutNotifier, CheckoutDraft>(CheckoutNotifier.new);

/// Cart lines resolved against the catalog, dropping anything no longer sold.
final cartLinesProvider = Provider<List<({CartItem item, Product product, Variant variant})>>((ref) {
  final products = ref.watch(productsProvider);
  return [
    for (final c in ref.watch(cartProvider))
      if (products.where((p) => p.id == c.productId).firstOrNull case final p?) (item: c, product: p, variant: p.variant(c.variantId)),
  ];
});

final totalsProvider = Provider<Totals>((ref) {
  final draft = ref.watch(checkoutProvider);
  return computeTotals(
    lines: [for (final l in ref.watch(cartLinesProvider)) (unitPrice: l.variant.price, qty: l.item.qty)],
    coupon: draft.coupon,
    slot: draft.slot,
    giftWrap: draft.giftWrap,
    region: ref.watch(settingsProvider).region,
  );
});

class CouponsNotifier extends Notifier<List<Coupon>> {
  @override
  List<Coupon> build() => ref.read(repositoryProvider).loadCoupons();

  void _set(List<Coupon> v) {
    state = v;
    ref.read(repositoryProvider).saveCoupons(v);
  }

  void toggle(String code) => _set([for (final c in state) c.code == code ? c.copyWith(active: !c.active) : c]);
  bool add(Coupon c) {
    if (state.any((e) => e.code == c.code)) return false;
    _set([c, ...state]);
    return true;
  }

  void use(String code) => _set([for (final c in state) c.code == code ? c.copyWith(uses: c.uses + 1) : c]);
}

final couponsProvider = NotifierProvider<CouponsNotifier, List<Coupon>>(CouponsNotifier.new);

class OrdersNotifier extends Notifier<List<Order>> {
  @override
  List<Order> build() => ref.read(repositoryProvider).loadOrders();

  void _set(List<Order> v) {
    state = v;
    ref.read(repositoryProvider).saveOrders(v);
  }

  Order byId(String id) => state.firstWhere((o) => o.id == id);

  /// Turns the current cart into an order, takes stock, and empties the cart.
  Order placeFromCart() {
    final lines = ref.read(cartLinesProvider);
    final draft = ref.read(checkoutProvider);
    final t = ref.read(totalsProvider);
    final now = DateTime.now();
    final last = state.map((o) => int.tryParse(o.id.split('-').last) ?? 0).fold(10482, (a, b) => a > b ? a : b);
    final order = Order(
      id: 'KH-${last + 1}',
      createdAt: now,
      lines: [
        for (final l in lines)
          OrderLine(
            productId: l.product.id,
            variantId: l.variant.id,
            name: l.product.name,
            variantLabel: l.variant.label,
            unitPrice: l.variant.price,
            qty: l.item.qty,
          ),
      ],
      address: draft.address,
      payment: draft.payment,
      slot: draft.slot,
      subtotal: t.subtotal,
      discount: t.discount,
      shipping: t.shipping,
      giftWrap: t.giftWrap,
      total: t.total,
      vat: t.vat,
      vatRate: t.vatRate,
      couponCode: draft.coupon?.code,
      giftMessage: draft.giftWrap && draft.giftMessage.isNotEmpty ? draft.giftMessage : null,
      history: {OrderStatus.placed: now},
    );
    _set([order, ...state]);
    ref.read(productsProvider.notifier).consume(order.lines);
    if (order.couponCode != null) ref.read(couponsProvider.notifier).use(order.couponCode!);
    ref.read(cartProvider.notifier).clear();
    ref.read(checkoutProvider.notifier).reset();
    return order;
  }

  void advance(String id) {
    _set([
      for (final o in state)
        if (o.id == id && nextStatus(o.status) != null) o.copyWith(history: {...o.history, nextStatus(o.status)!: DateTime.now()}) else o,
    ]);
  }

  void cancel(String id) {
    final o = byId(id);
    if (!canCancel(o.status)) return;
    _set([
      for (final e in state) e.id == id ? e.copyWith(history: {...e.history, OrderStatus.cancelled: DateTime.now()}) : e,
    ]);
    ref.read(productsProvider.notifier).restock(o.lines);
  }

  void markRated(String id) => _set([for (final o in state) o.id == id ? o.copyWith(rated: true) : o]);

  /// Puts the order's items back in the cart, skipping what's out of stock. Returns how many were added.
  int reorder(String id) {
    var added = 0;
    for (final l in byId(id).lines) {
      if (ref.read(cartProvider.notifier).add(l.productId, l.variantId, qty: l.qty)) added++;
    }
    return added;
  }
}

final ordersProvider = NotifierProvider<OrdersNotifier, List<Order>>(OrdersNotifier.new);

final orderProvider = Provider.family<Order?, String>((ref, id) => ref.watch(ordersProvider).where((o) => o.id == id).firstOrNull);

/// Drops all demo state and rebuilds every provider from the seed.
Future<void> resetDemo(WidgetRef ref) async {
  await ref.read(repositoryProvider).resetDemo();
  ref
    ..invalidate(settingsProvider)
    ..invalidate(productsProvider)
    ..invalidate(favoritesProvider)
    ..invalidate(cartProvider)
    ..invalidate(checkoutProvider)
    ..invalidate(couponsProvider)
    ..invalidate(ordersProvider)
    ..invalidate(recentSearchesProvider);
}
