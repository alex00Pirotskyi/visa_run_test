import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Canvas + shader form one architectural surface and share the scroll
/// transform of the child content. RepaintBoundary caches the static scene.
class ConcreteWallPainter extends CustomPainter {
  const ConcreteWallPainter(this.shader);
  final ui.FragmentShader? shader;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xffb3b5b7),
    );
    if (shader != null) {
      canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
    }
  }

  @override
  bool shouldRepaint(covariant ConcreteWallPainter oldDelegate) =>
      shader != oldDelegate.shader;
}

/// Grit, panel joints, form ties and geometric sun rays based on the reference
/// architecture. No animation and no expensive blur filters.
class ArchitecturalLightPainter extends CustomPainter {
  const ArchitecturalLightPainter();

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final w = size.width;
    final h = size.height;
    final floorY = h * .855;
    final wall = Rect.fromLTWH(0, 0, w, floorY);

    canvas.save();
    canvas.clipRect(wall);

    // Subtle light falloff, not a full-screen filter or parallax layer.
    canvas.drawRect(
      wall,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(-w * .15, h * .06),
          Offset(w, h * .75),
          const [
            Color(0x90101214),
            Color(0x44101214),
            Color(0x0BFFFFFF),
            Color(0x3EFFFFFF),
          ],
          const [0, .31, .66, 1],
        ),
    );

    // Photographic-looking, broad sunlit patch across right-hand concrete.
    final bigDaylight = Path()
      ..moveTo(w * 1.08, h * .105)
      ..lineTo(w * 1.13, h * .18)
      ..lineTo(w * .26, floorY)
      ..lineTo(-w * .04, floorY)
      ..close();
    canvas.drawPath(bigDaylight, Paint()..color = const Color(0x70FFFFFF));

    // Hard-edged bright diagonal beam crosses the panels and graffiti.
    final sunlight = Path()
      ..moveTo(w * 1.08, h * .045)
      ..lineTo(w * 1.24, h * .13)
      ..lineTo(w * .38, floorY)
      ..lineTo(w * .16, floorY)
      ..close();
    canvas.drawPath(sunlight, Paint()..color = const Color(0x7EFFFFFF));

    final crossing = Path()
      ..moveTo(w * 1.16, h * .36)
      ..lineTo(w * 1.19, h * .47)
      ..lineTo(w * .72, floorY)
      ..lineTo(w * .62, floorY)
      ..close();
    canvas.drawPath(crossing, Paint()..color = const Color(0x2EFFFFFF));

    // Faint vertical stains in the cast concrete.
    final smudges = Paint()..color = const Color(0x0B161819);
    final sr = math.Random(3307);
    for (var i = 0; i < 34; i++) {
      final x = sr.nextDouble() * w;
      final y = sr.nextDouble() * floorY;
      canvas.drawOval(
        Rect.fromLTWH(
          x, y, 8 + sr.nextDouble() * 40, 30 + sr.nextDouble() * 90),
        smudges,
      );
    }

    // Vertical formwork grid: darker inner seam and thin catchlight.
    final panelWidth = w < 700 ? w * .80 : w * .335;
    void verticalJoint(double x) {
      canvas.drawRect(
        Rect.fromLTWH(x - 1.2, 0, 2.5, floorY),
        Paint()..color = const Color(0x840C0D0E),
      );
      canvas.drawRect(
        Rect.fromLTWH(x + 1.5, 0, 1.2, floorY),
        Paint()..color = const Color(0x9CFFFFFF),
      );
    }

    void horizontalJoint(double y) {
      canvas.drawRect(Rect.fromLTWH(0, y - 1.3, w, 2.2),
        Paint()..color = const Color(0x770B0D0E));
      canvas.drawRect(Rect.fromLTWH(0, y + .9, w, .8),
        Paint()..color = const Color(0x79FFFFFF));
    }

    for (var x = panelWidth; x < w; x += panelWidth) {
      verticalJoint(x);
    }
    horizontalJoint(floorY * .22);
    horizontalJoint(floorY * .67);

    // Fixed panel form-tie holes, with little pale concrete edges.
    final holes = Paint()..color = const Color(0xAE272B2C);
    final edge = Paint()..color = const Color(0x8FFFFFFF);
    for (var x = panelWidth * .10; x < w; x += panelWidth) {
      for (final y in [floorY * .19, floorY * .65]) {
        canvas.drawCircle(Offset(x, y), 2.8, holes);
        canvas.drawCircle(Offset(x + .65, y + .8), 1.2, edge);
      }
    }

    // Fine aggregate pinholes, random but stable. No draw loop per frame.
    final sand = math.Random(8831);
    for (var i = 0; i < 300; i++) {
      final x = sand.nextDouble() * w;
      final y = sand.nextDouble() * floorY;
      final rad = .18 + sand.nextDouble() * 1.25;
      canvas.drawCircle(
        Offset(x, y),
        rad,
        Paint()..color = const Color(0x44212627),
      );
    }
    canvas.restore();

    // Floor starts near the bottom of the content, preserving readable wall
    // area on desktop and allowing tall mobile content.
    final floor = Rect.fromLTRB(0, floorY, w, h);
    canvas.drawRect(
      floor,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, floorY),
          Offset(w * .18, h),
          const [
            Color(0xffc4c6c6),
            Color(0xff9a9d9f),
            Color(0xff777a7c),
          ],
          const [0, .5, 1],
        ),
    );

    final floorSun = Path()
      ..moveTo(0, floorY)
      ..lineTo(w * .95, floorY)
      ..lineTo(w * 1.11, h * .89)
      ..lineTo(0, h * .905)
      ..close();
    canvas.drawPath(floorSun, Paint()..color = const Color(0xBFF9FAF7));

    final windowShadow = Path()
      ..moveTo(0, floorY + 17)
      ..lineTo(w, floorY + 40)
      ..lineTo(w, floorY + 48)
      ..lineTo(0, floorY + 25)
      ..close();
    canvas.drawPath(windowShadow, Paint()..color = const Color(0x66595D5F));

    final mullion = Path()
      ..moveTo(0, floorY + (h - floorY) * .55)
      ..lineTo(w, floorY + (h - floorY) * .77)
      ..lineTo(w, floorY + (h - floorY) * .85)
      ..lineTo(0, floorY + (h - floorY) * .63)
      ..close();
    canvas.drawPath(mullion, Paint()..color = const Color(0x60545759));

    canvas.drawRect(Rect.fromLTWH(0, floorY - 2, w, 2),
      Paint()..color = const Color(0x8018191A));
    canvas.drawRect(Rect.fromLTWH(0, floorY, w, 2),
      Paint()..color = const Color(0x81FFFFFF));
  }

  @override
  bool shouldRepaint(covariant ArchitecturalLightPainter oldDelegate) => false;
}

/// A few scratches over the final ink unify the artwork with the substrate.
class PaintWeatheringPainter extends CustomPainter {
  const PaintWeatheringPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rand = math.Random(4903);
    final dust = Paint()..color = const Color(0x24B7B8B9);
    for (var i = 0; i < 130; i++) {
      canvas.drawOval(
        Rect.fromLTWH(
          rand.nextDouble() * size.width,
          rand.nextDouble() * size.height,
          .35 + rand.nextDouble() * 1.8,
          .3 + rand.nextDouble() * .65,
        ),
        dust,
      );
    }
  }
  @override
  bool shouldRepaint(covariant PaintWeatheringPainter oldDelegate) => false;
}
