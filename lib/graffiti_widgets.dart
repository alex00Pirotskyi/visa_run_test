import 'dart:math' as math;
import 'package:flutter/material.dart';

const graffitiInk = Color(0xff151516);

/// Stencil lettering cut out by tiny chips and spray scuffs. The hidden
/// semantic Text below gives accurate Flutter sizing and selectable semantics
/// without loading a font or baking text into an image.
class StencilText extends StatelessWidget {
  const StencilText(
    this.text, {
    super.key,
    this.fontSize = 44,
    this.height = .94,
    this.letterSpacing = -1,
    this.maxLines,
    this.textAlign = TextAlign.left,
    this.wear = .65,
    this.ink = graffitiInk,
  });

  final String text;
  final double fontSize;
  final double height;
  final double letterSpacing;
  final int? maxLines;
  final TextAlign textAlign;
  final double wear;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontFamily: 'Roboto',
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      height: height,
      letterSpacing: letterSpacing,
      color: Colors.transparent,
    );
    return CustomPaint(
      foregroundPainter: _StencilGlyphPainter(
        text: text,
        style: style.copyWith(color: ink),
        ink: ink,
        wear: wear,
        maxLines: maxLines,
        textAlign: textAlign,
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: fontSize * .075),
        child: Text(
          text,
          maxLines: maxLines,
          textAlign: textAlign,
          softWrap: true,
          style: style,
        ),
      ),
    );
  }
}

class _StencilGlyphPainter extends CustomPainter {
  const _StencilGlyphPainter({
    required this.text,
    required this.style,
    required this.ink,
    required this.wear,
    required this.maxLines,
    required this.textAlign,
  });

  final String text;
  final TextStyle style;
  final Color ink;
  final double wear;
  final int? maxLines;
  final TextAlign textAlign;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textAlign: textAlign,
      textDirection: TextDirection.ltr,
      maxLines: maxLines,
    )..layout(maxWidth: size.width);

    // Keep the erosion inside this layer, so real concrete is revealed
    // through the holes rather than painting flat gray speckles over ink.
    canvas.saveLayer(Offset.zero & size, Paint());
    tp.paint(canvas, Offset.zero);
    final random = math.Random(text.hashCode ^ 0x51e77);
    final clear = Paint()..blendMode = BlendMode.clear;
    final count = (size.width * size.height / 215 * wear).clamp(4, 320).round();
    for (var i = 0; i < count; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * (size.height - 2);
      final radius = .25 + random.nextDouble() * 1.4;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, y),
          width: radius * 3.3,
          height: radius * .7,
        ),
        clear,
      );
    }

    // Small stencil bridges across wide glyphs, like a hand-cut stencil.
    if (style.fontSize! >= 65) {
      final slashCount = math.max(1, text.length ~/ 3);
      for (var i = 0; i < slashCount; i++) {
        final x = size.width * (.13 + .74 * (i + .4) / slashCount);
        final y = size.height * (.20 + (i % 3) * .20);
        canvas.drawLine(Offset(x - 5, y + 3), Offset(x + 6, y - 4),
            clear..strokeWidth = 1.25);
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _StencilGlyphPainter old) =>
      text != old.text ||
      style != old.style ||
      wear != old.wear ||
      ink != old.ink ||
      maxLines != old.maxLines ||
      textAlign != old.textAlign;
}

