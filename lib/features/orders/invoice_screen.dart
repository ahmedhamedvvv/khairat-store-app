import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../data/pricing.dart';
import '../../state/providers.dart';
import '../../widgets/common.dart';

const _vatNo = '310123456700003';

class InvoiceScreen extends ConsumerWidget {
  const InvoiceScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = context.s;
    final o = ref.watch(orderProvider(id));
    if (o == null) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyState(icon: Icons.search_off_rounded, title: s.noResults),
      );
    }
    final qr = zatcaQrPayload(seller: 'Khairat Trading Est.', vatNo: _vatNo, at: o.createdAt, total: o.total, vat: o.vat);
    final ink = Palette.ink;
    final muted = Palette.muted;

    // Invoices stay on white paper in dark mode too.
    return Scaffold(
      appBar: AppBar(title: Text(s.viewInvoice)),
      body: ListView(
        padding: const EdgeInsets.all(Tokens.s16),
        children: [
          Container(
            padding: const EdgeInsets.all(Tokens.s24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Tokens.cardRadius),
              boxShadow: [BoxShadow(blurRadius: 24, color: Colors.black.withValues(alpha: 0.08))],
            ),
            child: DefaultTextStyle.merge(
              style: TextStyle(color: ink),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: Palette.oud, borderRadius: BorderRadius.circular(12)),
                        child: const Text(
                          'خ',
                          style: TextStyle(color: Palette.gold, fontSize: 24, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: Tokens.s12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.invoiceTitle, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                            Text(context.isAr ? 'Simplified Tax Invoice' : 'فاتورة ضريبية مبسطة', style: TextStyle(color: muted, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Tokens.s16),
                  _kv(s.seller, s.sellerName, muted),
                  _kv(s.vatNumber, _vatNo, muted),
                  _kv(s.orderNumber, o.id, muted),
                  _kv(s.invoiceDate, formatDate(context, o.createdAt), muted),
                  _kv(s.paidWith, paymentLabel(context, o.payment), muted),
                  const Divider(height: 28, color: Color(0xFFE8E0D4)),
                  for (final l in o.lines)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(child: Text('${l.name.of(context)} (${l.variantLabel.of(context)}) × ${l.qty}')),
                          Text(ref.money(context, l.total), style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  const Divider(height: 28, color: Color(0xFFE8E0D4)),
                  _kv(s.subtotal, ref.money(context, o.subtotal), muted),
                  if (o.discount > 0) _kv(s.discount, '-${ref.money(context, o.discount)}', muted),
                  _kv(s.shipping, o.shipping == 0 ? s.free : ref.money(context, o.shipping), muted),
                  if (o.giftWrap > 0) _kv(s.giftWrapFee, ref.money(context, o.giftWrap), muted),
                  _kv(s.vatAmount('${(o.vatRate * 100).round()}'), ref.money(context, o.vat), muted),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(s.total, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                      ),
                      Text(
                        ref.money(context, o.total),
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Palette.oud),
                      ),
                    ],
                  ),
                  const SizedBox(height: Tokens.s24),
                  Center(
                    child: QrImageView(
                      data: qr,
                      size: 150,
                      eyeStyle: const QrEyeStyle(color: Palette.oudDeep, eyeShape: QrEyeShape.square),
                      dataModuleStyle: const QrDataModuleStyle(color: Palette.oudDeep),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(s.invoiceQrNote, style: TextStyle(color: muted, fontSize: 11)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v, Color muted) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Expanded(
          child: Text(k, style: TextStyle(color: muted, fontSize: 13)),
        ),
        Text(v, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    ),
  );
}
