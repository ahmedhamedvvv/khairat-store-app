import 'dart:convert';

import 'models.dart';

/// Where the shopper is. Prices are kept in SAR and converted for display.
enum Region {
  sa(currencyAr: 'ر.س', currencyEn: 'SAR', vatRate: 0.15, fxFromSar: 1),
  ae(currencyAr: 'د.إ', currencyEn: 'AED', vatRate: 0.05, fxFromSar: 0.98);

  const Region({required this.currencyAr, required this.currencyEn, required this.vatRate, required this.fxFromSar});
  final String currencyAr;
  final String currencyEn;
  final double vatRate;
  final double fxFromSar;
}

class ShippingRules {
  static const freeThreshold = 300.0;
  static const standard = 20.0;
  static const express = 35.0;
  static const giftWrap = 15.0;

  static double feeFor(DeliverySlot slot, double payable) {
    if (slot == DeliverySlot.express) return express;
    return payable >= freeThreshold ? 0 : standard;
  }
}

enum CouponError { notFound, inactive, belowMinimum }

class CouponCheck {
  const CouponCheck.ok(this.coupon) : error = null;
  const CouponCheck.fail(this.error) : coupon = null;
  final Coupon? coupon;
  final CouponError? error;
}

CouponCheck checkCoupon(String code, List<Coupon> coupons, double subtotal) {
  final c = coupons.where((c) => c.code.toUpperCase() == code.trim().toUpperCase()).firstOrNull;
  if (c == null) return const CouponCheck.fail(CouponError.notFound);
  if (!c.active) return const CouponCheck.fail(CouponError.inactive);
  if (subtotal < c.minSubtotal) return const CouponCheck.fail(CouponError.belowMinimum);
  return CouponCheck.ok(c);
}

class Totals {
  const Totals({
    required this.subtotal,
    required this.discount,
    required this.shipping,
    required this.giftWrap,
    required this.total,
    required this.vat,
    required this.vatRate,
    required this.toFreeShipping,
  });
  final double subtotal;
  final double discount;
  final double shipping;
  final double giftWrap;
  final double total;

  /// VAT already included in [total].
  final double vat;
  final double vatRate;

  /// How much more the shopper must add to get free standard shipping, 0 if reached.
  final double toFreeShipping;
}

double _round2(double v) => (v * 100).roundToDouble() / 100;

/// All amounts in SAR. Prices are VAT inclusive, so VAT is extracted, never added.
Totals computeTotals({
  required List<({double unitPrice, int qty})> lines,
  Coupon? coupon,
  DeliverySlot slot = DeliverySlot.standard,
  bool giftWrap = false,
  Region region = Region.sa,
}) {
  final subtotal = lines.fold<double>(0, (s, l) => s + l.unitPrice * l.qty);
  var discount = 0.0;
  if (coupon != null && coupon.active && subtotal >= coupon.minSubtotal) {
    discount = coupon.type == CouponType.percent ? subtotal * coupon.value / 100 : coupon.value;
    if (discount > subtotal) discount = subtotal;
  }
  final payable = subtotal - discount;
  final shipping = lines.isEmpty ? 0.0 : ShippingRules.feeFor(slot, payable);
  final wrap = giftWrap && lines.isNotEmpty ? ShippingRules.giftWrap : 0.0;
  final total = payable + shipping + wrap;
  final vat = total - total / (1 + region.vatRate);
  final toFree = payable >= ShippingRules.freeThreshold ? 0.0 : ShippingRules.freeThreshold - payable;
  return Totals(
    subtotal: _round2(subtotal),
    discount: _round2(discount),
    shipping: shipping,
    giftWrap: wrap,
    total: _round2(total),
    vat: _round2(vat),
    vatRate: region.vatRate,
    toFreeShipping: _round2(toFree),
  );
}

/// The order of the happy path; [OrderStatus.cancelled] sits outside it.
const orderFlow = [OrderStatus.placed, OrderStatus.confirmed, OrderStatus.preparing, OrderStatus.shipped, OrderStatus.delivered];

OrderStatus? nextStatus(OrderStatus s) {
  final i = orderFlow.indexOf(s);
  if (i < 0 || i == orderFlow.length - 1) return null;
  return orderFlow[i + 1];
}

bool canCancel(OrderStatus s) => s == OrderStatus.placed || s == OrderStatus.confirmed;

/// Simplified ZATCA phase-1 style TLV payload (seller, VAT no., time, total, VAT), base64 encoded.
String zatcaQrPayload({required String seller, required String vatNo, required DateTime at, required double total, required double vat}) {
  final fields = [seller, vatNo, at.toUtc().toIso8601String(), total.toStringAsFixed(2), vat.toStringAsFixed(2)];
  final bytes = <int>[];
  for (var i = 0; i < fields.length; i++) {
    final v = utf8.encode(fields[i]);
    bytes
      ..add(i + 1)
      ..add(v.length)
      ..addAll(v);
  }
  return base64Encode(bytes);
}
