import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/models.dart';

/// Vector illustration of a product, so the demo ships without photos and
/// stays crisp at any size. A real store swaps this for network images.
class ProductArt extends StatelessWidget {
  const ProductArt({super.key, required this.kind, required this.color, required this.accent, this.background = true, this.radius = 20});

  ProductArt.of(Product p, {super.key, this.background = true, this.radius = 20}) : kind = p.art, color = p.color, accent = p.accent;

  final ArtKind kind;
  final Color color;
  final Color accent;
  final bool background;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: CustomPaint(
        painter: _ArtPainter(kind, color, accent, background: background, dark: dark),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _ArtPainter extends CustomPainter {
  _ArtPainter(this.kind, this.color, this.accent, {required this.background, required this.dark});
  final ArtKind kind;
  final Color color;
  final Color accent;
  final bool background;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    if (background) _paintBackground(canvas, size);
    // Draw in a 100x100 box centered in the available space.
    final side = math.min(size.width, size.height);
    canvas.save();
    canvas.translate((size.width - side) / 2, (size.height - side) / 2);
    canvas.scale(side / 100);
    _shadow(canvas);
    switch (kind) {
      case ArtKind.bottle:
        _bottle(canvas);
      case ArtKind.roundBottle:
        _roundBottle(canvas);
      case ArtKind.tallBottle:
        _tallBottle(canvas);
      case ArtKind.burner:
        _burner(canvas);
      case ArtKind.abaya:
        _abaya(canvas, wide: false);
      case ArtKind.kaftan:
        _abaya(canvas, wide: true);
      case ArtKind.datesBox:
        _datesBox(canvas);
      case ArtKind.datesBowl:
        _datesBowl(canvas);
      case ArtKind.dallah:
        _dallah(canvas);
      case ArtKind.gift:
        _gift(canvas);
    }
    canvas.restore();
  }

  Color get _tint => Color.lerp(color, dark ? const Color(0xFF1A1411) : Colors.white, dark ? 0.72 : 0.86)!;

  void _paintBackground(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.2),
          radius: 0.9,
          colors: [Color.lerp(_tint, Colors.white, dark ? 0.04 : 0.5)!, _tint],
        ).createShader(rect),
    );
    // Faint eight-point star lattice, a nod to Arabic geometric patterns.
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = color.withValues(alpha: dark ? 0.12 : 0.07);
    const step = 34.0;
    for (var y = -step / 2; y < size.height + step; y += step) {
      for (var x = -step / 2; x < size.width + step; x += step) {
        _star(canvas, Offset(x, y), 9, p);
      }
    }
  }

  void _star(Canvas c, Offset o, double r, Paint p) {
    c.drawRect(Rect.fromCenter(center: o, width: r * 1.4, height: r * 1.4), p);
    c.save();
    c.translate(o.dx, o.dy);
    c.rotate(math.pi / 4);
    c.drawRect(Rect.fromCenter(center: Offset.zero, width: r * 1.4, height: r * 1.4), p);
    c.restore();
  }

  void _shadow(Canvas c) {
    c.drawOval(
      Rect.fromCenter(center: const Offset(50, 88), width: 54, height: 7),
      Paint()
        ..color = Colors.black.withValues(alpha: dark ? 0.35 : 0.13)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
  }

  Paint _glass(Rect r) => Paint()
    ..shader = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Color.lerp(color, Colors.black, 0.25)!, Color.lerp(color, Colors.white, 0.18)!, color, Color.lerp(color, Colors.black, 0.35)!],
      stops: const [0, 0.35, 0.6, 1],
    ).createShader(r);

  Paint _gold(Rect r) => Paint()
    ..shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color.lerp(accent, Colors.white, 0.35)!, accent, Color.lerp(accent, Colors.black, 0.35)!],
    ).createShader(r);

  void _highlight(Canvas c, Rect r) {
    c.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(r.left + r.width * 0.18, r.top + r.height * 0.12, r.width * 0.09, r.height * 0.7), const Radius.circular(3)),
      Paint()..color = Colors.white.withValues(alpha: 0.28),
    );
  }

  void _bottle(Canvas c) {
    final body = Rect.fromLTWH(28, 38, 44, 50);
    final rr = RRect.fromRectAndCorners(
      body,
      topLeft: const Radius.circular(10),
      topRight: const Radius.circular(10),
      bottomLeft: const Radius.circular(6),
      bottomRight: const Radius.circular(6),
    );
    c.drawRRect(rr, _glass(body));
    _highlight(c, body);
    // Neck and cap.
    final neck = Rect.fromLTWH(44, 31, 12, 8);
    c.drawRect(neck, _gold(neck));
    final cap = Rect.fromLTWH(38, 12, 24, 20);
    c.drawRRect(RRect.fromRectAndRadius(cap, const Radius.circular(4)), _gold(cap));
    for (var i = 0; i < 4; i++) {
      c.drawLine(
        Offset(42 + i * 5.5, 14),
        Offset(42 + i * 5.5, 30),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.12)
          ..strokeWidth = 0.8,
      );
    }
    // Label.
    final label = Rect.fromLTWH(36, 58, 28, 14);
    c.drawRRect(RRect.fromRectAndRadius(label, const Radius.circular(2)), Paint()..color = accent.withValues(alpha: 0.9));
    c.drawRRect(
      RRect.fromRectAndRadius(label.deflate(1.6), const Radius.circular(1.5)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6
        ..color = color.withValues(alpha: 0.7),
    );
  }

  void _roundBottle(Canvas c) {
    final body = Rect.fromCircle(center: const Offset(50, 63), radius: 25);
    c.drawOval(body, _glass(body));
    c.drawOval(Rect.fromLTWH(34, 46, 10, 22), Paint()..color = Colors.white.withValues(alpha: 0.25));
    final neck = Rect.fromLTWH(45, 32, 10, 8);
    c.drawRect(neck, _gold(neck));
    final cap = Rect.fromCircle(center: const Offset(50, 25), radius: 10);
    c.drawOval(cap, _gold(cap));
    c.drawCircle(const Offset(47, 22), 2.5, Paint()..color = Colors.white.withValues(alpha: 0.5));
    final band = Path()
      ..moveTo(28, 66)
      ..quadraticBezierTo(50, 74, 72, 66);
    c.drawPath(
      band,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = accent.withValues(alpha: 0.85),
    );
  }

  void _tallBottle(Canvas c) {
    final body = Path()
      ..moveTo(40, 40)
      ..quadraticBezierTo(34, 50, 36, 86)
      ..lineTo(64, 86)
      ..quadraticBezierTo(66, 50, 60, 40)
      ..close();
    final r = body.getBounds();
    c.drawPath(body, _glass(r));
    _highlight(c, r);
    final neck = Rect.fromLTWH(45, 32, 10, 9);
    c.drawRect(neck, _gold(neck));
    // Ornate pointed cap.
    final cap = Path()
      ..moveTo(42, 33)
      ..quadraticBezierTo(42, 22, 50, 8)
      ..quadraticBezierTo(58, 22, 58, 33)
      ..close();
    c.drawPath(cap, _gold(cap.getBounds()));
    c.drawCircle(const Offset(50, 24), 2.4, Paint()..color = color.withValues(alpha: 0.8));
    c.drawLine(
      const Offset(37, 76),
      const Offset(63, 76),
      Paint()
        ..strokeWidth = 2
        ..color = accent,
    );
  }

  void _burner(Canvas c) {
    // Smoke.
    final smoke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..color = (dark ? Colors.white : Colors.black).withValues(alpha: 0.16);
    for (final dx in [-6.0, 0.0, 6.0]) {
      final s = Path()
        ..moveTo(50 + dx, 34)
        ..cubicTo(44 + dx, 26, 56 + dx, 20, 50 + dx, 10);
      c.drawPath(s, smoke);
    }
    final bowl = Path()
      ..moveTo(30, 36)
      ..lineTo(70, 36)
      ..quadraticBezierTo(68, 52, 56, 56)
      ..lineTo(44, 56)
      ..quadraticBezierTo(32, 52, 30, 36)
      ..close();
    c.drawPath(bowl, _gold(bowl.getBounds()));
    c.drawRect(const Rect.fromLTWH(30, 34, 40, 4), Paint()..color = Color.lerp(accent, Colors.black, 0.2)!);
    final stem = Rect.fromLTWH(45, 56, 10, 12);
    c.drawRect(stem, _gold(stem));
    final base = Path()
      ..moveTo(36, 86)
      ..lineTo(64, 86)
      ..lineTo(58, 68)
      ..lineTo(42, 68)
      ..close();
    c.drawPath(base, _gold(base.getBounds()));
    final deco = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..color = color.withValues(alpha: 0.6);
    for (var i = 0; i < 5; i++) {
      c.drawCircle(Offset(38 + i * 6, 45), 1.6, deco);
    }
    c.drawLine(const Offset(40, 78), const Offset(60, 78), deco);
  }

  void _abaya(Canvas c, {required bool wide}) {
    final hanger = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = dark ? const Color(0xFFBFAF9F) : const Color(0xFF8A7A70);
    c.drawPath(
      Path()
        ..moveTo(50, 14)
        ..arcToPoint(const Offset(54, 10), radius: const Radius.circular(3))
        ..moveTo(50, 14)
        ..lineTo(50, 18)
        ..moveTo(36, 24)
        ..lineTo(50, 18)
        ..lineTo(64, 24),
      hanger,
    );
    final w = wide ? 40.0 : 30.0;
    final dress = Path()
      ..moveTo(42, 20)
      ..quadraticBezierTo(50, 24, 58, 20)
      ..lineTo(64, 23)
      ..lineTo(50 + w, wide ? 50 : 56)
      ..lineTo(50 + w - 6, wide ? 54 : 60)
      ..lineTo(62, 38)
      ..lineTo(50 + (wide ? 22 : 18), 88)
      ..lineTo(50 - (wide ? 22 : 18), 88)
      ..lineTo(38, 38)
      ..lineTo(50 - w + 6, wide ? 54 : 60)
      ..lineTo(50 - w, wide ? 50 : 56)
      ..lineTo(36, 23)
      ..close();
    final b = dress.getBounds();
    c.drawPath(
      dress,
      Paint()
        ..shader = LinearGradient(
          colors: [Color.lerp(color, Colors.black, 0.2)!, Color.lerp(color, Colors.white, 0.12)!, Color.lerp(color, Colors.black, 0.25)!],
        ).createShader(b),
    );
    // Folds.
    final fold = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7
      ..color = Colors.black.withValues(alpha: 0.25);
    c.drawLine(const Offset(45, 42), const Offset(41, 86), fold);
    c.drawLine(const Offset(55, 42), const Offset(59, 86), fold);
    // Embroidery along the opening and cuffs.
    final emb = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = accent;
    c.drawLine(const Offset(50, 23), const Offset(50, 88), emb);
    for (var y = 30.0; y < 86; y += 7) {
      c.drawCircle(Offset(50, y), 1.3, Paint()..color = accent);
    }
    c.drawLine(Offset(50 + w, wide ? 50 : 56), Offset(50 + w - 6, wide ? 54 : 60), emb..strokeWidth = 2.4);
    c.drawLine(Offset(50 - w, wide ? 50 : 56), Offset(50 - w + 6, wide ? 54 : 60), emb);
    if (wide) {
      c.drawLine(const Offset(28, 88), const Offset(72, 88), emb..strokeWidth = 2);
    }
  }

  void _date(Canvas c, Offset o, double rot, double t) {
    final col = Color.lerp(color, accent, t)!;
    c.save();
    c.translate(o.dx, o.dy);
    c.rotate(rot);
    final r = Rect.fromCenter(center: Offset.zero, width: 13, height: 8);
    c.drawOval(
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.4),
          colors: [Color.lerp(col, Colors.white, 0.3)!, col, Color.lerp(col, Colors.black, 0.35)!],
        ).createShader(r),
    );
    c.drawLine(
      const Offset(-3, -1),
      const Offset(3, 0),
      Paint()
        ..strokeWidth = 0.6
        ..color = Colors.black.withValues(alpha: 0.25),
    );
    c.restore();
  }

  void _datesBox(Canvas c) {
    final box = RRect.fromRectAndRadius(const Rect.fromLTWH(18, 30, 64, 54), const Radius.circular(5));
    c.drawRRect(box, Paint()..color = dark ? const Color(0xFF3B2E25) : const Color(0xFFF7EFE2));
    c.drawRRect(
      box,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = Color.lerp(accent, Colors.black, 0.1)!,
    );
    final rnd = math.Random(color.toARGB32());
    for (var row = 0; row < 4; row++) {
      for (var col = 0; col < 4; col++) {
        final o = Offset(28 + col * 14.5, 39 + row * 12);
        c.drawRRect(
          RRect.fromRectAndRadius(Rect.fromCenter(center: o, width: 13, height: 10.5), const Radius.circular(2)),
          Paint()..color = const Color(0xFFD9C4A6).withValues(alpha: 0.5),
        );
        _date(c, o, (rnd.nextDouble() - 0.5) * 0.5, rnd.nextDouble() * 0.3);
      }
    }
    // Lid leaning behind.
    final lid = Path()
      ..moveTo(22, 30)
      ..lineTo(30, 14)
      ..lineTo(86, 18)
      ..lineTo(78, 30)
      ..close();
    c.drawPath(lid, _gold(lid.getBounds()));
    c.drawCircle(const Offset(54, 22), 4, Paint()..color = color.withValues(alpha: 0.7));
  }

  void _datesBowl(Canvas c) {
    final rnd = math.Random(color.toARGB32() + 7);
    final pts = <Offset>[];
    for (var row = 0; row < 3; row++) {
      final n = 5 - row;
      for (var i = 0; i < n; i++) {
        pts.add(Offset(50 - (n - 1) * 6.5 + i * 13, 56 - row * 8));
      }
    }
    for (final p in pts.reversed) {
      _date(c, p, (rnd.nextDouble() - 0.5) * 1.2, rnd.nextDouble() * 0.35);
    }
    final bowl = Path()
      ..moveTo(18, 58)
      ..lineTo(82, 58)
      ..quadraticBezierTo(80, 82, 50, 84)
      ..quadraticBezierTo(20, 82, 18, 58)
      ..close();
    c.drawPath(bowl, _gold(bowl.getBounds()));
    c.drawOval(const Rect.fromLTWH(18, 55, 64, 6), Paint()..color = Color.lerp(accent, Colors.black, 0.25)!);
    final deco = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..color = Colors.white.withValues(alpha: 0.45);
    for (var i = 0; i < 6; i++) {
      final x = 26.0 + i * 9.5;
      c.drawPath(
        Path()
          ..moveTo(x, 66)
          ..lineTo(x + 4, 71)
          ..lineTo(x, 76),
        deco,
      );
    }
  }

  void _dallah(Canvas c) {
    final body = Path()
      ..moveTo(40, 40)
      ..quadraticBezierTo(30, 60, 34, 84)
      ..lineTo(66, 84)
      ..quadraticBezierTo(70, 60, 60, 40)
      ..close();
    final spout = Path()
      ..moveTo(36, 62)
      ..quadraticBezierTo(22, 50, 16, 30)
      ..lineTo(20, 28)
      ..quadraticBezierTo(28, 46, 40, 54)
      ..close();
    final handle = Path()
      ..moveTo(62, 46)
      ..quadraticBezierTo(80, 50, 72, 76)
      ..lineTo(68, 74)
      ..quadraticBezierTo(74, 54, 62, 52);
    c.drawPath(spout, _gold(spout.getBounds()));
    c.drawPath(handle, _gold(handle.getBounds()));
    c.drawPath(
      body,
      Paint()
        ..shader = LinearGradient(
          colors: [Color.lerp(color, Colors.black, 0.2)!, Color.lerp(color, Colors.white, 0.35)!, Color.lerp(color, Colors.black, 0.3)!],
        ).createShader(body.getBounds()),
    );
    final neck = Rect.fromLTWH(42, 32, 16, 9);
    c.drawRect(neck, _gold(neck));
    final lid = Path()
      ..moveTo(40, 33)
      ..quadraticBezierTo(50, 14, 60, 33)
      ..close();
    c.drawPath(lid, _gold(lid.getBounds()));
    c.drawCircle(const Offset(50, 16), 3, _gold(const Rect.fromLTWH(47, 13, 6, 6)));
    c.drawLine(
      const Offset(35, 70),
      const Offset(65, 70),
      Paint()
        ..strokeWidth = 1.4
        ..color = accent.withValues(alpha: 0.9),
    );
  }

  void _gift(Canvas c) {
    final box = Rect.fromLTWH(24, 44, 52, 42);
    c.drawRRect(
      RRect.fromRectAndRadius(box, const Radius.circular(4)),
      Paint()..shader = LinearGradient(colors: [Color.lerp(color, Colors.white, 0.12)!, Color.lerp(color, Colors.black, 0.2)!]).createShader(box),
    );
    final lid = Rect.fromLTWH(20, 34, 60, 12);
    c.drawRRect(RRect.fromRectAndRadius(lid, const Radius.circular(3)), Paint()..color = Color.lerp(color, Colors.white, 0.08)!);
    final ribbon = _gold(const Rect.fromLTWH(20, 20, 60, 66));
    c.drawRect(const Rect.fromLTWH(46, 34, 8, 52), ribbon);
    c.drawRect(const Rect.fromLTWH(20, 38, 60, 5), ribbon);
    final bow = Path()
      ..moveTo(50, 34)
      ..cubicTo(36, 16, 28, 30, 50, 34)
      ..moveTo(50, 34)
      ..cubicTo(64, 16, 72, 30, 50, 34);
    c.drawPath(bow, ribbon);
    c.drawCircle(const Offset(50, 34), 3.4, ribbon);
  }

  @override
  bool shouldRepaint(_ArtPainter old) => old.kind != kind || old.color != color || old.accent != accent || old.dark != dark || old.background != background;
}
