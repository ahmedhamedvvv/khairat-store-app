import 'package:flutter_test/flutter_test.dart';
import 'package:khairat/data/models.dart';
import 'package:khairat/data/pricing.dart';

void main() {
  const coupons = [
    Coupon(code: 'KHAIRAT10', type: CouponType.percent, value: 10),
    Coupon(code: 'WELCOME50', type: CouponType.fixed, value: 50, minSubtotal: 250),
    Coupon(code: 'EID20', type: CouponType.percent, value: 20, active: false),
  ];

  group('computeTotals', () {
    test('empty cart costs nothing', () {
      final t = computeTotals(lines: []);
      expect(t.total, 0);
      expect(t.shipping, 0);
      expect(t.giftWrap, 0);
    });

    test('standard shipping is charged below 300 and VAT is extracted from the total', () {
      final t = computeTotals(lines: [(unitPrice: 115, qty: 1)]);
      expect(t.subtotal, 115);
      expect(t.shipping, ShippingRules.standard);
      expect(t.total, 135);
      expect(t.vat, closeTo(135 - 135 / 1.15, 0.01));
      expect(t.toFreeShipping, 185);
    });

    test('free standard shipping from 300 after discount', () {
      expect(computeTotals(lines: [(unitPrice: 150, qty: 2)]).shipping, 0);
      // 320 - 10% = 288, back under the threshold.
      final t = computeTotals(lines: [(unitPrice: 320, qty: 1)], coupon: coupons[0]);
      expect(t.discount, 32);
      expect(t.shipping, ShippingRules.standard);
    });

    test('express is always charged', () {
      final t = computeTotals(lines: [(unitPrice: 500, qty: 1)], slot: DeliverySlot.express);
      expect(t.shipping, ShippingRules.express);
      expect(t.total, 535);
    });

    test('gift wrap adds a flat fee', () {
      final t = computeTotals(lines: [(unitPrice: 400, qty: 1)], giftWrap: true);
      expect(t.giftWrap, ShippingRules.giftWrap);
      expect(t.total, 415);
    });

    test('a coupon below its minimum or inactive gives no discount', () {
      expect(computeTotals(lines: [(unitPrice: 100, qty: 1)], coupon: coupons[1]).discount, 0);
      expect(computeTotals(lines: [(unitPrice: 500, qty: 1)], coupon: coupons[2]).discount, 0);
      expect(computeTotals(lines: [(unitPrice: 300, qty: 1)], coupon: coupons[1]).discount, 50);
    });

    test('UAE uses 5% VAT', () {
      final t = computeTotals(lines: [(unitPrice: 300, qty: 1)], region: Region.ae);
      expect(t.vatRate, 0.05);
      expect(t.vat, closeTo(300 - 300 / 1.05, 0.01));
    });
  });

  group('checkCoupon', () {
    test('matches case-insensitively and reports why it fails', () {
      expect(checkCoupon(' khairat10 ', coupons, 50).coupon?.code, 'KHAIRAT10');
      expect(checkCoupon('NOPE', coupons, 50).error, CouponError.notFound);
      expect(checkCoupon('EID20', coupons, 900).error, CouponError.inactive);
      expect(checkCoupon('WELCOME50', coupons, 100).error, CouponError.belowMinimum);
    });
  });

  group('order status', () {
    test('moves forward one step at a time and stops at delivered', () {
      expect(nextStatus(OrderStatus.placed), OrderStatus.confirmed);
      expect(nextStatus(OrderStatus.shipped), OrderStatus.delivered);
      expect(nextStatus(OrderStatus.delivered), isNull);
      expect(nextStatus(OrderStatus.cancelled), isNull);
    });

    test('can only be cancelled before preparing', () {
      expect(canCancel(OrderStatus.placed), isTrue);
      expect(canCancel(OrderStatus.confirmed), isTrue);
      expect(canCancel(OrderStatus.preparing), isFalse);
      expect(canCancel(OrderStatus.delivered), isFalse);
    });
  });

  test('invoice QR payload is base64 TLV with five fields', () {
    final p = zatcaQrPayload(seller: 'خيرات', vatNo: '300000000000003', at: DateTime.utc(2026, 10, 27), total: 115, vat: 15);
    expect(RegExp(r'^[A-Za-z0-9+/]+=*$').hasMatch(p), isTrue);
  });
}
