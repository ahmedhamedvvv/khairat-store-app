import 'package:flutter/widgets.dart';

/// Text stored in both languages, used for catalog data.
class Bi {
  const Bi(this.ar, this.en);
  final String ar;
  final String en;

  String of(BuildContext context) => Localizations.localeOf(context).languageCode == 'ar' ? ar : en;

  Map<String, dynamic> toJson() => {'ar': ar, 'en': en};
  factory Bi.fromJson(Map<String, dynamic> j) => Bi(j['ar'] as String, j['en'] as String);
}

enum CategoryId { perfumes, abayas, dates }

/// What kind of illustration a product is drawn with.
enum ArtKind { bottle, roundBottle, tallBottle, burner, abaya, kaftan, datesBox, datesBowl, dallah, gift }

class Category {
  const Category({required this.id, required this.name, required this.tagline, required this.art, required this.color});
  final CategoryId id;
  final Bi name;
  final Bi tagline;
  final ArtKind art;
  final Color color;
}

/// One purchasable option of a product: a size, a volume or a weight.
class Variant {
  const Variant({required this.id, required this.label, required this.price});
  final String id;
  final Bi label;

  /// Price in SAR, VAT inclusive.
  final double price;

  Map<String, dynamic> toJson() => {'id': id, 'label': label.toJson(), 'price': price};
  factory Variant.fromJson(Map<String, dynamic> j) =>
      Variant(id: j['id'] as String, label: Bi.fromJson(j['label'] as Map<String, dynamic>), price: (j['price'] as num).toDouble());
}

class Review {
  const Review({required this.author, required this.rating, required this.text, required this.city});
  final String author;
  final int rating;
  final Bi text;
  final Bi city;
}

class Product {
  const Product({
    required this.id,
    required this.category,
    required this.name,
    required this.brand,
    required this.description,
    required this.variants,
    required this.art,
    required this.color,
    required this.accent,
    required this.stock,
    this.rating = 4.7,
    this.ratingCount = 120,
    this.sold = 0,
    this.oldPrice,
    this.tags = const [],
    this.isNew = false,
    this.active = true,
    this.reviews = const [],
  });

  final String id;
  final CategoryId category;
  final Bi name;
  final Bi brand;
  final Bi description;
  final List<Variant> variants;
  final ArtKind art;
  final Color color;
  final Color accent;
  final int stock;
  final double rating;
  final int ratingCount;
  final int sold;

  /// Price before discount for the first variant, shown struck through.
  final double? oldPrice;
  final List<Bi> tags;
  final bool isNew;
  final bool active;
  final List<Review> reviews;

  double get basePrice => variants.first.price;
  bool get lowStock => stock > 0 && stock <= 5;
  bool get outOfStock => stock <= 0;
  int? get discountPercent => oldPrice == null ? null : (((oldPrice! - basePrice) / oldPrice!) * 100).round();

  Variant variant(String id) => variants.firstWhere((v) => v.id == id, orElse: () => variants.first);

  Product copyWith({int? stock, double? price, bool? active, int? sold}) => Product(
    id: id,
    category: category,
    name: name,
    brand: brand,
    description: description,
    variants: price == null
        ? variants
        : [
            Variant(id: variants.first.id, label: variants.first.label, price: price),
            ...variants.skip(1).map((v) => Variant(id: v.id, label: v.label, price: v.price - basePrice + price)),
          ],
    art: art,
    color: color,
    accent: accent,
    stock: stock ?? this.stock,
    rating: rating,
    ratingCount: ratingCount,
    sold: sold ?? this.sold,
    oldPrice: oldPrice,
    tags: tags,
    isNew: isNew,
    active: active ?? this.active,
    reviews: reviews,
  );
}

class CartItem {
  const CartItem({required this.productId, required this.variantId, required this.qty});
  final String productId;
  final String variantId;
  final int qty;

  String get key => '$productId/$variantId';

  CartItem withQty(int q) => CartItem(productId: productId, variantId: variantId, qty: q);

  Map<String, dynamic> toJson() => {'p': productId, 'v': variantId, 'q': qty};
  factory CartItem.fromJson(Map<String, dynamic> j) => CartItem(productId: j['p'] as String, variantId: j['v'] as String, qty: j['q'] as int);
}

enum CouponType { percent, fixed }

class Coupon {
  const Coupon({required this.code, required this.type, required this.value, this.minSubtotal = 0, this.active = true, this.uses = 0});
  final String code;
  final CouponType type;
  final double value;
  final double minSubtotal;
  final bool active;
  final int uses;

  Coupon copyWith({bool? active, int? uses}) =>
      Coupon(code: code, type: type, value: value, minSubtotal: minSubtotal, active: active ?? this.active, uses: uses ?? this.uses);

  Map<String, dynamic> toJson() => {'code': code, 'type': type.name, 'value': value, 'min': minSubtotal, 'active': active, 'uses': uses};
  factory Coupon.fromJson(Map<String, dynamic> j) => Coupon(
    code: j['code'] as String,
    type: CouponType.values.byName(j['type'] as String),
    value: (j['value'] as num).toDouble(),
    minSubtotal: (j['min'] as num).toDouble(),
    active: j['active'] as bool,
    uses: j['uses'] as int,
  );
}

enum PaymentMethod { mada, applePay, stcPay, tabby, cod }

enum DeliverySlot { express, standard, scheduled }

/// Order lifecycle. [cancelled] can only be reached before shipping.
enum OrderStatus { placed, confirmed, preparing, shipped, delivered, cancelled }

class Address {
  const Address({required this.name, required this.phone, required this.city, required this.district, required this.street, this.shortCode = ''});
  final String name;
  final String phone;
  final String city;
  final String district;
  final String street;

  /// Saudi National Address short code, e.g. RRRD2929.
  final String shortCode;

  Map<String, dynamic> toJson() => {'name': name, 'phone': phone, 'city': city, 'district': district, 'street': street, 'short': shortCode};
  factory Address.fromJson(Map<String, dynamic> j) => Address(
    name: j['name'] as String,
    phone: j['phone'] as String,
    city: j['city'] as String,
    district: j['district'] as String,
    street: j['street'] as String,
    shortCode: (j['short'] ?? '') as String,
  );
}

class OrderLine {
  const OrderLine({
    required this.productId,
    required this.variantId,
    required this.name,
    required this.variantLabel,
    required this.unitPrice,
    required this.qty,
  });
  final String productId;
  final String variantId;
  final Bi name;
  final Bi variantLabel;
  final double unitPrice;
  final int qty;

  double get total => unitPrice * qty;

  Map<String, dynamic> toJson() => {'p': productId, 'v': variantId, 'n': name.toJson(), 'vl': variantLabel.toJson(), 'u': unitPrice, 'q': qty};
  factory OrderLine.fromJson(Map<String, dynamic> j) => OrderLine(
    productId: j['p'] as String,
    variantId: j['v'] as String,
    name: Bi.fromJson(j['n'] as Map<String, dynamic>),
    variantLabel: Bi.fromJson(j['vl'] as Map<String, dynamic>),
    unitPrice: (j['u'] as num).toDouble(),
    qty: j['q'] as int,
  );
}

class Order {
  const Order({
    required this.id,
    required this.createdAt,
    required this.lines,
    required this.address,
    required this.payment,
    required this.slot,
    required this.subtotal,
    required this.discount,
    required this.shipping,
    required this.giftWrap,
    required this.total,
    required this.vat,
    required this.vatRate,
    required this.history,
    this.couponCode,
    this.giftMessage,
    this.rated = false,
  });

  final String id;
  final DateTime createdAt;
  final List<OrderLine> lines;
  final Address address;
  final PaymentMethod payment;
  final DeliverySlot slot;
  final double subtotal;
  final double discount;
  final double shipping;
  final double giftWrap;
  final double total;
  final double vat;
  final double vatRate;
  final String? couponCode;
  final String? giftMessage;
  final bool rated;

  /// Each status the order reached, with when it reached it.
  final Map<OrderStatus, DateTime> history;

  OrderStatus get status => history.keys.reduce((a, b) => history[a]!.isAfter(history[b]!) ? a : b);
  int get itemCount => lines.fold(0, (s, l) => s + l.qty);

  Order copyWith({Map<OrderStatus, DateTime>? history, bool? rated}) => Order(
    id: id,
    createdAt: createdAt,
    lines: lines,
    address: address,
    payment: payment,
    slot: slot,
    subtotal: subtotal,
    discount: discount,
    shipping: shipping,
    giftWrap: giftWrap,
    total: total,
    vat: vat,
    vatRate: vatRate,
    history: history ?? this.history,
    couponCode: couponCode,
    giftMessage: giftMessage,
    rated: rated ?? this.rated,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'at': createdAt.toIso8601String(),
    'lines': lines.map((l) => l.toJson()).toList(),
    'addr': address.toJson(),
    'pay': payment.name,
    'slot': slot.name,
    'sub': subtotal,
    'disc': discount,
    'ship': shipping,
    'gift': giftWrap,
    'total': total,
    'vat': vat,
    'vatRate': vatRate,
    'coupon': couponCode,
    'msg': giftMessage,
    'rated': rated,
    'hist': history.map((k, v) => MapEntry(k.name, v.toIso8601String())),
  };

  factory Order.fromJson(Map<String, dynamic> j) => Order(
    id: j['id'] as String,
    createdAt: DateTime.parse(j['at'] as String),
    lines: (j['lines'] as List).map((e) => OrderLine.fromJson(e as Map<String, dynamic>)).toList(),
    address: Address.fromJson(j['addr'] as Map<String, dynamic>),
    payment: PaymentMethod.values.byName(j['pay'] as String),
    slot: DeliverySlot.values.byName(j['slot'] as String),
    subtotal: (j['sub'] as num).toDouble(),
    discount: (j['disc'] as num).toDouble(),
    shipping: (j['ship'] as num).toDouble(),
    giftWrap: (j['gift'] as num).toDouble(),
    total: (j['total'] as num).toDouble(),
    vat: (j['vat'] as num).toDouble(),
    vatRate: (j['vatRate'] as num).toDouble(),
    couponCode: j['coupon'] as String?,
    giftMessage: j['msg'] as String?,
    rated: (j['rated'] ?? false) as bool,
    history: (j['hist'] as Map<String, dynamic>).map((k, v) => MapEntry(OrderStatus.values.byName(k), DateTime.parse(v as String))),
  );
}
