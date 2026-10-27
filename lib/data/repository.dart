import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';
import 'seed.dart';

/// Local persistence for the demo. Swapping this class for an API client
/// (Firebase, Supabase, Salla, Zid) is the only change a real backend needs.
class StoreRepository {
  StoreRepository(this._prefs);
  final SharedPreferences _prefs;

  static const _kCart = 'cart';
  static const _kFav = 'favorites';
  static const _kOrders = 'orders';
  static const _kCoupons = 'coupons';
  static const _kProducts = 'product_overrides';
  static const _kSettings = 'settings';
  static const _kSearches = 'recent_searches';

  List<T> _list<T>(String key, T Function(Map<String, dynamic>) f) {
    final raw = _prefs.getString(key);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).map((e) => f(e as Map<String, dynamic>)).toList();
  }

  Future<void> _put(String key, Object value) => _prefs.setString(key, jsonEncode(value));

  List<CartItem> loadCart() => _list(_kCart, CartItem.fromJson);
  Future<void> saveCart(List<CartItem> v) => _put(_kCart, v.map((e) => e.toJson()).toList());

  Set<String> loadFavorites() => (_prefs.getStringList(_kFav) ?? const []).toSet();
  Future<void> saveFavorites(Set<String> v) => _prefs.setStringList(_kFav, v.toList());

  List<String> loadSearches() => _prefs.getStringList(_kSearches) ?? const [];
  Future<void> saveSearches(List<String> v) => _prefs.setStringList(_kSearches, v);

  List<Order> loadOrders() {
    if (!_prefs.containsKey(_kOrders)) return seedOrders(DateTime.now());
    return _list(_kOrders, Order.fromJson);
  }

  Future<void> saveOrders(List<Order> v) => _put(_kOrders, v.map((e) => e.toJson()).toList());

  List<Coupon> loadCoupons() {
    if (!_prefs.containsKey(_kCoupons)) return seedCoupons;
    return _list(_kCoupons, Coupon.fromJson);
  }

  Future<void> saveCoupons(List<Coupon> v) => _put(_kCoupons, v.map((e) => e.toJson()).toList());

  /// Products are seeded from code; only merchant edits (stock, price, active, sold) are stored.
  List<Product> loadProducts() {
    final raw = _prefs.getString(_kProducts);
    if (raw == null) return seedProducts;
    final o = jsonDecode(raw) as Map<String, dynamic>;
    return seedProducts.map((p) {
      final e = o[p.id] as Map<String, dynamic>?;
      if (e == null) return p;
      return p.copyWith(stock: e['stock'] as int?, price: (e['price'] as num?)?.toDouble(), active: e['active'] as bool?, sold: e['sold'] as int?);
    }).toList();
  }

  Future<void> saveProducts(List<Product> v) => _put(_kProducts, {
    for (final p in v) p.id: {'stock': p.stock, 'price': p.basePrice, 'active': p.active, 'sold': p.sold},
  });

  Map<String, dynamic> loadSettings() {
    final raw = _prefs.getString(_kSettings);
    return raw == null ? {} : jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> saveSettings(Map<String, dynamic> v) => _put(_kSettings, v);

  /// Wipes everything except language and theme, so a visitor can replay the demo.
  Future<void> resetDemo() async {
    final s = loadSettings();
    await _prefs.clear();
    await saveSettings({'locale': s['locale'], 'theme': s['theme']});
  }
}
