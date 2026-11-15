import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// A quiet, Kindle-like cast-concrete surface.
///
/// This is ONE wall from top to bottom: no floor, spotlight beams, form-tie
/// holes, perspective, or separate shadow geometry. The fragment shader adds
/// only very fine mineral texture; two hairline joints and a faint top-left
/// daylight falloff are the entire architectural treatment.
///
/// It is static and wrapped in a RepaintBoundary by the landing page.
class ConcreteScenePainter extends CustomPainter {
  const ConcreteScenePainter(this.shader);

  static const baseColor = Color(0xffc9c6c1);
  static const verticalSeamFraction = .62;
  static const horizontalSeamFraction = .68;

  final ui.FragmentShader? shader;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final bounds = Offset.zero & size;
    final w = size.width;
    final h = size.height;

    // Flat fallback is always available before GPU shader compilation.
    canvas.drawRect(bounds, Paint()..color = baseColor);
    if (shader != null) {
      canvas.drawRect(bounds, Paint()..shader = shader);
    }

    // Nearly invisible daylight falloff. A single broad gradient replaces
    // the former directional sunlight, floor perspective and shadow passes.
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(w, h),
          const [
            Color(0x09FFFFFF),
            Color(0x00000000),
            Color(0x080D0E0F),
          ],
          const [0, .52, 1],
        ),
    );

    // Only one vertical and one horizontal formwork joint. Each is a
    // one-pixel depression plus a faint edge highlight.
    final x = w * verticalSeamFraction;
    final y = h * horizontalSeamFraction;

    canvas.drawRect(
      Rect.fromLTWH(x, 0, 1.1, h),
      Paint()..color = const Color(0x18514D48),
    );
    canvas.drawRect(
      Rect.fromLTWH(x + 1.1, 0, .7, h),
      Paint()..color = const Color(0x12FFFFFF),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, y, w, 1.1),
      Paint()..color = const Color(0x14514D48),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, y + 1.1, w, .7),
      Paint()..color = const Color(0x10FFFFFF),
    );
  }

  @override
  bool shouldRepaint(covariant ConcreteScenePainter old) =>
      old.shader != shader;
}
