import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'graffiti_widgets.dart';

/// Original monochrome stencil mural: an anonymous traveler with a backpack,
/// tilted rolling suitcase, a border-control sign and an airplane. Entirely
/// vector: no image requests, no animation, no raster wallpaper.
class StencilMuralPainter extends CustomPainter {
  const StencilMuralPainter();

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    canvas.save();
    final scale = math.min(size.width / 610, size.height / 590);
    canvas.translate(
      (size.width - 610 * scale) * .50,
      (size.height - 590 * scale) * .50,
    );
    canvas.scale(scale);

    final black = Paint()..color = graffitiInk;
    final gray = Paint()..color = graffitiInk.withValues(alpha: .68);
    final line = Paint()
      ..color = graffitiInk
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.bevel;

    // The sign is a stencil sprayed onto the wall, not a real object.
    // The post is partially hidden behind the traveler.
    final sign = Path()
      ..moveTo(398, 115)
      ..lineTo(568, 97)
      ..quadraticBezierTo(580, 97, 582, 111)
      ..lineTo(590, 175)
      ..lineTo(418, 194)
      ..quadraticBezierTo(400, 192, 399, 177)
      ..close();
    canvas.drawPath(sign, line..strokeWidth = 5.2);
    canvas.drawPath(
      Path()..moveTo(411, 199)..lineTo(418, 205)
        ..moveTo(448, 195)..lineTo(450, 213)
        ..moveTo(564, 177)..lineTo(565, 197),
      Paint()
        ..color = graffitiInk
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.1
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawRect(const Rect.fromLTWH(468, 122, 2, 55), black);
    // Passport control face in peaked cap, torso, open passport.
    canvas.drawPath(Path()
      ..moveTo(417, 148)..lineTo(433, 143)..lineTo(444, 148)
      ..lineTo(438, 153)..lineTo(420, 153)..close(), black);
    canvas.drawOval(const Rect.fromLTWH(422, 152, 18, 21), black);
    canvas.drawPath(Path()
      ..moveTo(416, 175)..lineTo(443, 171)..lineTo(451, 188)
      ..lineTo(416, 191)..close(), black);
    canvas.drawRect(const Rect.fromLTWH(441, 163, 11, 15), black);

    // Airplane with identifiable wings and a simple forward arrow.
    canvas.drawPath(Path()
      ..moveTo(492, 146)..lineTo(510, 144)
      ..lineTo(533, 130)..lineTo(540, 132)
      ..lineTo(528, 147)..lineTo(546, 151)
      ..lineTo(546, 155)..lineTo(522, 154)
      ..lineTo(515, 167)..lineTo(510, 168)
      ..lineTo(514, 152)..lineTo(494, 152)
      ..close(), black);
    canvas.drawPath(Path()
      ..moveTo(551, 150)..lineTo(571, 148)
      ..moveTo(561, 138)..lineTo(573, 148)..lineTo(562, 159),
      Paint()
        ..color = graffitiInk
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.5
        ..strokeCap = StrokeCap.square
        ..strokeJoin = StrokeJoin.miter,
    );
    canvas.drawPath(
      Path()..moveTo(555, 184)..lineTo(553, 420),
      Paint()
        ..color = graffitiInk.withValues(alpha: .77)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9,
    );

    // Ground stencil helps anchor the traveler to the wall.
    canvas.drawPath(
      Path()..moveTo(176, 545)..lineTo(553, 547),
      Paint()
        ..color = graffitiInk.withValues(alpha: .7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    canvas.drawOval(const Rect.fromLTWH(220, 539, 300, 10), gray);

    // A cap, head and neck in side profile. Cutouts below add skin/cloth
    // facets instead of rendering everything as a single black blob.
    canvas.drawPath(Path()
      ..moveTo(359, 178)
      ..quadraticBezierTo(378, 157, 408, 172)
      ..lineTo(421, 183)
      ..lineTo(448, 187)
      ..lineTo(439, 194)
      ..lineTo(414, 196)
      ..quadraticBezierTo(420, 208, 426, 216)
      ..lineTo(417, 223)
      ..lineTo(427, 233)
      ..lineTo(415, 240)
      ..lineTo(393, 231)
      ..lineTo(377, 241)
      ..lineTo(368, 215)
      ..close(), black);
    canvas.drawPath(Path()
      ..moveTo(365, 179)..quadraticBezierTo(395, 154, 431, 184)
      ..lineTo(445, 189)..lineTo(416, 189)
      ..lineTo(398, 185)..lineTo(378, 192)..close(), black);

    // Hooded coat moves diagonally in the direction of the traveler.
    canvas.drawPath(Path()
      ..moveTo(363, 227)
      ..quadraticBezierTo(394, 212, 421, 245)
      ..lineTo(441, 309)
      ..lineTo(454, 387)
      ..lineTo(387, 402)
      ..lineTo(341, 359)
      ..lineTo(325, 286)
      ..close(), black);

    // Heavy backpack, spray-painted straps and side pocket.
    canvas.drawPath(Path()
      ..moveTo(331, 239)
      ..quadraticBezierTo(295, 238, 286, 276)
      ..lineTo(270, 361)
      ..quadraticBezierTo(275, 381, 299, 377)
      ..lineTo(351, 365)
      ..lineTo(363, 270)
      ..close(), black);
    canvas.drawPath(Path()
      ..moveTo(316, 247)
      ..quadraticBezierTo(333, 279, 334, 340)
      ..lineTo(343, 366)
      ..lineTo(357, 366)
      ..quadraticBezierTo(351, 282, 339, 241)
      ..close(), black);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(274, 303, 26, 50),
        const Radius.circular(6),
      ),
      black,
    );

    // Rear arm pulls a suitcase; forward arm swings with the stride.
    canvas.drawPath(Path()
      ..moveTo(351, 270)
      ..lineTo(366, 291)
      ..lineTo(343, 361)
      ..lineTo(309, 430)
      ..lineTo(293, 424)
      ..lineTo(318, 353)
      ..lineTo(329, 293)
      ..close(), black);
    canvas.drawCircle(const Offset(302, 431), 12, black);
    canvas.drawPath(Path()
      ..moveTo(426, 272)
      ..lineTo(451, 300)
      ..lineTo(469, 358)
      ..lineTo(452, 374)
      ..lineTo(433, 333)
      ..lineTo(404, 309)
      ..close(), black);
    canvas.drawCircle(const Offset(461, 370), 13, black);

    // Coat hem under the right hip, then two separated legs in stride.
    canvas.drawPath(Path()
      ..moveTo(367, 372)
      ..lineTo(451, 369)
      ..lineTo(447, 410)
      ..lineTo(395, 433)
      ..lineTo(359, 416)
      ..close(), black);

    // Rear leg bends back to balance the walking figure.
    canvas.drawPath(Path()
      ..moveTo(374, 395)
      ..lineTo(410, 417)
      ..lineTo(369, 491)
      ..lineTo(352, 524)
      ..lineTo(328, 518)
      ..lineTo(337, 476)
      ..close(), black);
    canvas.drawPath(Path()
      ..moveTo(329, 508)
      ..lineTo(359, 519)
      ..lineTo(374, 534)
      ..lineTo(371, 544)
      ..lineTo(311, 546)
      ..lineTo(302, 538)
      ..close(), black);

    // Front leg pushes in the direction of the airport arrow.
    canvas.drawPath(Path()
      ..moveTo(405, 399)
      ..lineTo(448, 387)
      ..lineTo(480, 447)
      ..lineTo(510, 501)
      ..lineTo(488, 522)
      ..lineTo(451, 480)
      ..close(), black);
    canvas.drawPath(Path()
      ..moveTo(485, 511)
      ..lineTo(513, 491)
      ..lineTo(543, 521)
      ..quadraticBezierTo(558, 535, 542, 543)
      ..lineTo(514, 547)
      ..lineTo(490, 535)
      ..close(), black);

    // Suitcase rolls on two wheels and its handle attaches to the hand.
    canvas.drawPath(
      Path()..moveTo(214, 415)..lineTo(290, 433)
        ..lineTo(271, 536)..lineTo(197, 526)..close(),
      black,
    );
    canvas.drawLine(const Offset(263, 435), const Offset(293, 405),
      line..strokeWidth = 5);
    canvas.drawLine(const Offset(289, 405), const Offset(305, 423),
      line..strokeWidth = 5);
    canvas.drawCircle(const Offset(214, 536), 7, black);
    canvas.drawCircle(const Offset(262, 542), 7, black);

    // White stencil gaps: jacket folds, cap, laces and luggage facets.
    canvas.saveLayer(Offset.zero & const Size(610, 590), Paint());
    // Rather than erase the already-painted traveler, draw discreet pale
    // cutout accents. They remain tonal and visually similar to wall chips.
    final cut = Paint()..color = const Color(0xffaaaeb0);
    final highlights = Path()
      ..moveTo(389, 198)..lineTo(401, 195)..lineTo(410, 204)..close()
      ..moveTo(384, 243)..lineTo(404, 263)..lineTo(419, 307)
      ..lineTo(408, 296)..close()
      ..moveTo(403, 329)..lineTo(430, 338)..lineTo(418, 343)..close()
      ..moveTo(326, 264)..lineTo(314, 346)..lineTo(318, 313)..close()
      ..moveTo(286, 284)..lineTo(279, 352)..lineTo(283, 338)..close()
      ..moveTo(384, 433)..lineTo(359, 477)..lineTo(366, 469)..close()
      ..moveTo(467, 460)..lineTo(484, 486)..lineTo(476, 479)..close()
      ..moveTo(224, 435)..lineTo(244, 440)..lineTo(229, 499)..close();
    canvas.drawPath(highlights, cut);
    canvas.restore();

    // Deterministic spray speckle/erosion, over the stencil only locally.
    final r = math.Random(1457);
    for (var i = 0; i < 360; i++) {
      final x = 192 + r.nextDouble() * 374;
      final y = 114 + r.nextDouble() * 432;
      final radius = .25 + r.nextDouble() * 1.3;
      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()..color = graffitiInk.withValues(alpha: .09 + r.nextDouble() * .17),
      );
    }

    // Small paint drips from the signage to sell the wall mural effect.
    final drops = Paint()
      ..color = graffitiInk.withValues(alpha: .81)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    for (final drop in const [
      [432.0, 194.0, 207.0],
      [565.0, 182.0, 211.0],
      [413.0, 195.0, 201.0],
    ]) {
      canvas.drawLine(Offset(drop[0], drop[1]),
          Offset(drop[0], drop[2]), drops);
      canvas.drawCircle(Offset(drop[0], drop[2]), 1.1, drops);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant StencilMuralPainter oldDelegate) => false;
}

/// Little spray-plane marking next to the top-left VISA RUN logo.
class GraffitiPlaneMarkPainter extends CustomPainter {
  const GraffitiPlaneMarkPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = graffitiInk;
    canvas.save();
    canvas.scale(size.width / 60, size.height / 35);
    canvas.drawPath(Path()
      ..moveTo(35, 12)..lineTo(54, 2)..lineTo(59, 4)
      ..lineTo(48, 20)..lineTo(53, 27)..lineTo(48, 29)
      ..lineTo(40, 22)..lineTo(29, 26)..lineTo(30, 20)
      ..lineTo(40, 15)..close(), p);
    canvas.drawPath(Path()
      ..moveTo(29, 22)..quadraticBezierTo(14, 38, 1, 29),
      Paint()
        ..color = graffitiInk
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();
  }
  @override
  bool shouldRepaint(covariant GraffitiPlaneMarkPainter oldDelegate) => false;
}
