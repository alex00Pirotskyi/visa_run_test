import 'dart:math' as math;
import 'package:flutter/material.dart';

const graffitiInk = Color(0xff151516);
const graffitiChalk = Color(0xffeeeeeb);

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

/// A rough, painted black slab with a few controlled overspray spots and
/// gravity drips. All marks are deterministic and only painted on change.
class GraffitiPlatePainter extends CustomPainter {
  const GraffitiPlatePainter({this.active = false, this.seed = 19});
  final bool active;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final r = math.Random(seed);
    final p = Paint()..color = active ? const Color(0xff343436) : graffitiInk;

    // Soft irregular edges mimic a stencil/spray edge, not a rounded card.
    final plate = Path()
      ..moveTo(1, 3)
      ..lineTo(size.width * .18, 1)
      ..lineTo(size.width * .43, 3)
      ..lineTo(size.width * .67, .6)
      ..lineTo(size.width - 2, 2)
      ..lineTo(size.width - .7, size.height - 11)
      ..lineTo(size.width * .72, size.height - 8)
      ..lineTo(size.width * .29, size.height - 9.5)
      ..lineTo(2, size.height - 10)
      ..close();

    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawPath(plate, p);

    // A few small drips below the plate itself.
    for (final dx in [.09, .47, .87]) {
      final x = size.width * dx;
      final length = dx == .47 ? 7.0 : 4.0;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, size.height - 10, 2, length),
          const Radius.circular(1),
        ),
        p,
      );
      canvas.drawCircle(Offset(x + 1, size.height - 10 + length), 1.05, p);
    }

    // Tiny chipped paint on the slab.
    final scratch = Paint()..blendMode = BlendMode.clear;
    for (var i = 0; i < math.min(80, size.width ~/ 3); i++) {
      final x = r.nextDouble() * size.width;
      final y = 4 + r.nextDouble() * math.max(1, size.height - 20);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, y),
          width: .45 + r.nextDouble() * 2.0,
          height: .3 + r.nextDouble() * .7,
        ),
        scratch,
      );
    }
    canvas.restore();

    final mist = Paint()..color = graffitiInk.withValues(alpha: .12);
    for (var i = 0; i < 15; i++) {
      final x = r.nextBool() ? r.nextDouble() * 3 : size.width - r.nextDouble() * 3;
      final y = 4 + r.nextDouble() * (size.height - 14);
      canvas.drawCircle(Offset(x, y), .2 + r.nextDouble() * .65, mist);
    }
  }

  @override
  bool shouldRepaint(covariant GraffitiPlatePainter old) =>
      old.active != active || old.seed != seed;
}

class GraffitiButton extends StatefulWidget {
  const GraffitiButton({
    super.key,
    required this.label,
    this.onPressed,
    this.compact = false,
    this.width,
    this.showArrow = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool compact;
  final double? width;
  final bool showArrow;

  @override
  State<GraffitiButton> createState() => _GraffitiButtonState();
}

class _GraffitiButtonState extends State<GraffitiButton> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: widget.onPressed ?? () {}, // Design demo: no booking yet.
      onHover: (value) {
        if (_hovered != value) setState(() => _hovered = value);
      },
      style: TextButton.styleFrom(
        foregroundColor: graffitiChalk,
        backgroundColor: Colors.transparent,
        overlayColor: graffitiChalk.withValues(alpha: .08),
        padding: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(),
        minimumSize: Size(widget.width ?? (widget.compact ? 150 : 172), 60),
      ),
      child: CustomPaint(
        painter: GraffitiPlatePainter(
          active: _hovered,
          seed: widget.label.hashCode,
        ),
        child: SizedBox(
          width: widget.width ?? (widget.compact ? 204 : 230),
          child: Padding(
            padding: EdgeInsets.fromLTRB(widget.compact ? 15 : 20, 13,
                widget.compact ? 15 : 20, 22),
            child: Row(children: [
              Expanded(child: Text(widget.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(
                  color: graffitiChalk,
                  fontSize: widget.compact ? 11 : 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .7,
                ),
              )),
              if (widget.showArrow) ...[
                const SizedBox(width: 9),
                const Icon(Icons.arrow_forward, color: graffitiChalk, size: 20),
              ],
            ]),
          ),
        ),
      ),
    );
  }
}

/// Live editable field in a stencil-painted frame, not a normal Material
/// input card. No request is sent anywhere: this is a visual prototype.
class GraffitiTextField extends StatelessWidget {
  const GraffitiTextField({
    super.key,
    required this.hint,
    this.controller,
  });

  final String hint;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GraffitiInputFramePainter(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 15, 18, 21),
        child: TextField(
          key: const Key('graffiti-message-field'),
          controller: controller,
          maxLines: 3,
          minLines: 2,
          maxLength: 160,
          cursorColor: graffitiInk,
          style: const TextStyle(
            color: graffitiInk,
            fontWeight: FontWeight.w800,
            fontSize: 16,
            letterSpacing: .5,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: graffitiInk.withValues(alpha: .55),
              fontWeight: FontWeight.w800,
              letterSpacing: .6,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            counterStyle: TextStyle(
              color: graffitiInk.withValues(alpha: .55),
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
      ),
    );
  }
}

class _GraffitiInputFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final frame = Paint()
      ..color = graffitiInk.withValues(alpha: .87)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.square;
    final path = Path()
      ..moveTo(1, 1)
      ..lineTo(size.width * .39, 2.7)
      ..lineTo(size.width - 1, 1)
      ..lineTo(size.width - 1.5, size.height - 7)
      ..lineTo(size.width * .68, size.height - 5.5)
      ..lineTo(1, size.height - 7)
      ..close();
    canvas.drawPath(path, frame);
    final drip = Paint()
      ..color = graffitiInk.withValues(alpha: .75)
      ..strokeWidth = 2;
    canvas.drawLine(Offset(size.width * .09, size.height - 7),
      Offset(size.width * .09, size.height - 1), drip);
    canvas.drawLine(Offset(size.width * .82, size.height - 7),
      Offset(size.width * .82, size.height - 3), drip);
    final r = math.Random(401);
    for (var i = 0; i < 22; i++) {
      final x = r.nextDouble() * size.width;
      final y = i.isEven ? r.nextDouble() * 3.5
          : size.height - 8 + r.nextDouble() * 4;
      canvas.drawCircle(Offset(x, y), .3 + r.nextDouble() * .75,
        Paint()..color = graffitiInk.withValues(alpha: .21));
    }
  }
  @override
  bool shouldRepaint(covariant _GraffitiInputFramePainter old) => false;
}
