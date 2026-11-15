import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// A single static fragment shader provides the pale, fine-grained wall.
/// No animation uniforms, timers, blur filters or scrolling parallax.
class ConcreteWallPainter extends CustomPainter {
  const ConcreteWallPainter(this.shader);
  final ui.FragmentShader? shader;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size,
        Paint()..color = const Color(0xffe8e6e3));
    if (shader != null) {
      canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
    }
  }

  @override
  bool shouldRepaint(covariant ConcreteWallPainter old) =>
      shader != old.shader;
}

/// Gentle real-wall weathering, not architectural floor/seam effects.
/// The mural and controls share the same stationary concrete coordinates.
class PaleConcreteDetailsPainter extends CustomPainter {
  const PaleConcreteDetailsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(4410);
    // Slight dust staining / mineral clouds, quiet enough to remain a wall.
    for (var i = 0; i < 54; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final width = 14.0 + rng.nextDouble() * 120.0;
      final height = 12.0 + rng.nextDouble() * 75.0;
      canvas.drawOval(
        Rect.fromLTWH(x, y, width, height),
        Paint()
          ..color = const Color(0x090E0F10),
      );
    }

    // Original photo has tiny marks and faint vertical concrete scratches.
    final grain = Paint()..color = const Color(0x3D191A1B);
    final lighter = Paint()..color = const Color(0x3CFFFFFF);
    for (var i = 0; i < 280; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      canvas.drawCircle(
        Offset(x, y),
        .22 + rng.nextDouble() * .75,
        (i % 5 == 0) ? lighter : grain,
      );
    }
    final scratch = Paint()
      ..color = const Color(0x15191A1B)
      ..strokeWidth = .75;
    for (var i = 0; i < 8; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      canvas.drawLine(
        Offset(x, y),
        Offset(x - rng.nextDouble() * 3, y + 20 + rng.nextDouble() * 105),
        scratch,
      );
    }

    // Subtle vignette only at corners; no dramatic geometric sunlight.
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(size.width * .53, size.height * .47),
          math.max(size.width, size.height) * .80,
          const [Color(0x00FFFFFF), Color(0x090D0E0F)],
        ),
    );
  }

  @override
  bool shouldRepaint(covariant PaleConcreteDetailsPainter old) => false;
}
