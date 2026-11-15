import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'graffiti_widgets.dart';

/// Almost nothing between ink and the wall: only distressed outline strokes,
/// painted letters, and a short underline on hover/focus.
class TransparentStencilButton extends StatefulWidget {
  const TransparentStencilButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.compact = false,
    this.width,
  });

  final String label;
  final VoidCallback onPressed;
  final bool compact;
  final double? width;

  @override
  State<TransparentStencilButton> createState() => _TransparentStencilButtonState();
}

class _TransparentStencilButtonState extends State<TransparentStencilButton> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final emphasized = _hovered || _focused;
    return TextButton(
      onPressed: widget.onPressed,
      onHover: (value) {
        if (mounted) setState(() => _hovered = value);
      },
      onFocusChange: (value) {
        if (mounted) setState(() => _focused = value);
      },
      style: TextButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: graffitiInk,
        overlayColor: graffitiInk.withValues(alpha: .055),
        padding: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(),
        minimumSize: Size(widget.width ?? (widget.compact ? 116 : 152), 49),
        tapTargetSize: MaterialTapTargetSize.padded,
      ),
      child: CustomPaint(
        painter: _RoughOutlinePainter(emphasized: emphasized),
        child: SizedBox(
          width: widget.width ?? (widget.compact ? 116 : 152),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Text(widget.label,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: widget.compact ? 11 : 13,
                color: graffitiInk,
                letterSpacing: .85,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoughOutlinePainter extends CustomPainter {
  const _RoughOutlinePainter({required this.emphasized});
  final bool emphasized;

  @override
  void paint(Canvas canvas, Size size) {
    final ink = Paint()
      ..style = PaintingStyle.stroke
      ..color = graffitiInk.withValues(alpha: emphasized ? .94 : .77)
      ..strokeWidth = emphasized ? 2.0 : 1.55
      ..strokeCap = StrokeCap.square;

    final path = Path()
      ..moveTo(3, 3)
      ..lineTo(size.width * .47, 1.2)
      ..lineTo(size.width - 2, 3)
      ..lineTo(size.width - 2.6, size.height - 4)
      ..lineTo(size.width * .61, size.height - 3.1)
      ..lineTo(2, size.height - 4.3)
      ..close();
    canvas.drawPath(path, ink);

    // Small chipped and over-sprayed spots. Deterministic, no ticker.
    final random = math.Random(418);
    final dust = Paint()..color = graffitiInk.withValues(alpha: .11);
    for (var i = 0; i < 13; i++) {
      final x = random.nextBool()
          ? random.nextDouble() * 5
          : size.width - random.nextDouble() * 5;
      canvas.drawCircle(
        Offset(x, random.nextDouble() * size.height),
        .23 + random.nextDouble() * .70,
        dust,
      );
    }
    if (emphasized) {
      canvas.drawLine(
        Offset(13, size.height - 8),
        Offset(size.width - 13, size.height - 8),
        Paint()..color = graffitiInk.withValues(alpha: .65)..strokeWidth = 1.1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RoughOutlinePainter old) =>
      old.emphasized != emphasized;
}
