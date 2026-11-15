import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// A static concrete wall and floor. The GPU shader only adds fine grain;
/// all architecture, seams, daylight and shadow geometry is cached in one
/// scrolling RepaintBoundary alongside the artwork.
class ConcreteScenePainter extends CustomPainter {
  const ConcreteScenePainter(this.shader);
  final ui.FragmentShader? shader;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final w = size.width;
    final h = size.height;
    final floorY = h * (w < 800 ? .965 : .90);
    final wall = Rect.fromLTRB(0, 0, w, floorY);

    canvas.drawRect(wall, Paint()..color = const Color(0xffbdbbb7));
    if (shader != null) {
      canvas.save();
      canvas.clipRect(wall);
      canvas.drawRect(wall, Paint()..shader = shader);
      canvas.restore();
    }

    // Wide directional window daylight and soft, static shade on the wall.
    canvas.save();
    canvas.clipRect(wall);
    canvas.drawRect(
      wall,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, 0),
          Offset(w, floorY * .9),
          const [
            Color(0x28FFFFFF),
            Color(0x050B0C0D),
            Color(0x19090909),
            Color(0x00FFFFFF),
          ],
          const [0, .27, .73, 1],
        ),
    );

    final beam = Path()
      ..moveTo(-w * .11, 0)
      ..lineTo(w * .25, 0)
      ..lineTo(w * .69, floorY)
      ..lineTo(w * .31, floorY)
      ..close();
    canvas.drawPath(beam, Paint()..color = const Color(0x1DFFFFFF));

    final beam2 = Path()
      ..moveTo(w * .30, 0)
      ..lineTo(w * .43, 0)
      ..lineTo(w * .82, floorY)
      ..lineTo(w * .67, floorY)
      ..close();
    canvas.drawPath(beam2, Paint()..color = const Color(0x0DFFFFFF));

    // Slab joints, barely darker than the material, with a catchlight.
    final seamX = w * .44;
    canvas.drawRect(Rect.fromLTWH(seamX, 0, 1.5, floorY),
        Paint()..color = const Color(0x41191b1c));
    canvas.drawRect(Rect.fromLTWH(seamX + 1.8, 0, .8, floorY),
        Paint()..color = const Color(0x40FFFFFF));
    canvas.drawRect(Rect.fromLTWH(0, floorY * .42, w, 1.25),
        Paint()..color = const Color(0x240f1011));

    // Form holes and tiny pinpricks deliberately subtle.
    final random = math.Random(1993);
    final hole = Paint()..color = const Color(0x39252728);
    for (var i = 0; i < 210; i++) {
      final x = random.nextDouble() * w;
      final y = random.nextDouble() * floorY;
      canvas.drawCircle(Offset(x, y), .28 + random.nextDouble() * 1.2, hole);
    }
    for (final x in [w * .13, w * .66]) {
      for (final y in [floorY * .08, floorY * .41, floorY * .73]) {
        canvas.drawCircle(Offset(x, y), 1.8, hole);
      }
    }
    canvas.restore();

    // Architectural floor line, with natural-looking sun and soft shadow.
    if (floorY < h) {
      final floorRect = Rect.fromLTRB(0, floorY, w, h);
      canvas.drawRect(floorRect,
          Paint()..shader = ui.Gradient.linear(
            Offset(0, floorY), Offset(w * .13, h),
            const [Color(0xffceccc8), Color(0xff9d9c99), Color(0xff92918f)],
            const [0, .55, 1],
          ));
      final floorLight = Path()
        ..moveTo(-w * .04, floorY + 2)
        ..lineTo(w * .56, floorY + 2)
        ..lineTo(w * .81, h)
        ..lineTo(w * .08, h)
        ..close();
      canvas.drawPath(floorLight, Paint()..color = const Color(0x69FFFFFF));
      canvas.drawRect(Rect.fromLTWH(0, floorY - 1.5, w, 1.5),
          Paint()..color = const Color(0x720F0F0F));
      canvas.drawRect(Rect.fromLTWH(0, floorY, w, 1),
          Paint()..color = const Color(0xB3FFFFFF));
    }
  }

  @override
  bool shouldRepaint(covariant ConcreteScenePainter old) =>
      old.shader != shader;
}
