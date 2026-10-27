import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/models.dart';
import '../data/pricing.dart';
import '../l10n/app_localizations.dart';
import '../state/providers.dart';

extension L10nX on BuildContext {
  S get s => S.of(this);
  bool get isAr => Localizations.localeOf(this).languageCode == 'ar';
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
}

final _num = NumberFormat('#,##0.##', 'en');

/// Formats a SAR amount in the shopper's currency, with Western digits as Gulf stores do.
String formatMoney(double sar, Region region, {required bool ar}) {
  final v = _num.format(sar * region.fxFromSar);
  return ar ? '$v ${region.currencyAr}' : '${region.currencyEn} $v';
}

extension MoneyRef on WidgetRef {
  String money(BuildContext context, double sar) => formatMoney(sar, watch(settingsProvider).region, ar: context.isAr);
}

String formatDate(BuildContext context, DateTime d, {bool time = true}) {
  final loc = Localizations.localeOf(context).languageCode;
  return _westernDigits(DateFormat(time ? 'd MMM, h:mm a' : 'd MMMM y', loc).format(d));
}

/// Gulf apps show Western digits even in Arabic, so dates match prices.
String _westernDigits(String s) => s.replaceAllMapped(RegExp('[٠-٩]'), (m) => '${m[0]!.codeUnitAt(0) - 0x0660}');

String statusLabel(BuildContext context, OrderStatus s) => switch (s) {
  OrderStatus.placed => context.s.statusPlaced,
  OrderStatus.confirmed => context.s.statusConfirmed,
  OrderStatus.preparing => context.s.statusPreparing,
  OrderStatus.shipped => context.s.statusShipped,
  OrderStatus.delivered => context.s.statusDelivered,
  OrderStatus.cancelled => context.s.statusCancelled,
};

String statusBody(BuildContext context, OrderStatus s) => switch (s) {
  OrderStatus.placed => context.s.statusPlacedBody,
  OrderStatus.confirmed => context.s.statusConfirmedBody,
  OrderStatus.preparing => context.s.statusPreparingBody,
  OrderStatus.shipped => context.s.statusShippedBody,
  OrderStatus.delivered => context.s.statusDeliveredBody,
  OrderStatus.cancelled => context.s.statusCancelledBody,
};

IconData statusIcon(OrderStatus s) => switch (s) {
  OrderStatus.placed => Icons.receipt_long_rounded,
  OrderStatus.confirmed => Icons.verified_rounded,
  OrderStatus.preparing => Icons.inventory_2_rounded,
  OrderStatus.shipped => Icons.delivery_dining_rounded,
  OrderStatus.delivered => Icons.home_rounded,
  OrderStatus.cancelled => Icons.cancel_rounded,
};

Color statusColor(BuildContext context, OrderStatus s) => switch (s) {
  OrderStatus.placed => const Color(0xFF8C6D3F),
  OrderStatus.confirmed => const Color(0xFF3F6E8C),
  OrderStatus.preparing => const Color(0xFFB7791F),
  OrderStatus.shipped => const Color(0xFF6B4BA0),
  OrderStatus.delivered => const Color(0xFF2F7D5B),
  OrderStatus.cancelled => const Color(0xFFB3412E),
};

String paymentLabel(BuildContext context, PaymentMethod p) => switch (p) {
  PaymentMethod.mada => context.s.payMada,
  PaymentMethod.applePay => context.s.payApple,
  PaymentMethod.stcPay => context.s.paySTC,
  PaymentMethod.tabby => context.s.payTabby,
  PaymentMethod.cod => context.s.payCod,
};
