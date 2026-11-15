import 'dart:ui';
import 'package:flutter/material.dart';

/// Glass is limited to small interactive surfaces. No full-screen blur or
/// background shader is required.
class LiquidGlass extends StatelessWidget {
  const LiquidGlass({
    super.key,
    required this.child,
    this.radius = 26,
    this.padding = EdgeInsets.zero,
    this.blur = 8,
    this.strong = false,
  });

  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;
  final double blur;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final noBlur = MediaQuery.disableAnimationsOf(context);
    final borderRadius = BorderRadius.circular(radius);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: const Color(0xff242424).withValues(alpha: .09),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          children: [
            Positioned.fill(
              child: noBlur || blur == 0
                  ? const SizedBox.expand()
                  : BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                      child: const SizedBox.expand(),
                    ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: strong
                        ? [
                            const Color(0xfffafaf9).withValues(alpha: .91),
                            const Color(0xfff3f3f1).withValues(alpha: .79),
                          ]
                        : [
                            const Color(0xffffffff).withValues(alpha: .57),
                            const Color(0xffefefed).withValues(alpha: .39),
                          ],
                  ),
                  borderRadius: borderRadius,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: strong ? .9 : .77),
                    width: 1.2,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _GlassEdgePainter(radius: radius),
                ),
              ),
            ),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );
  }
}

/// A small static specular rim is enough to communicate optical glass.
class _GlassEdgePainter extends CustomPainter {
  const _GlassEdgePainter({required this.radius});
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final pen = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xDFFFFFFF);
    final line = Path()
      ..moveTo(radius * .75, 2.2)
      ..lineTo(size.width * .52, 2.2);
    canvas.drawPath(line, pen);
    canvas.drawArc(
      Rect.fromLTWH(1.7, 1.7, radius * 2.0, radius * 2.0),
      3.17, 1.43, false,
      Paint()
        ..color = const Color(0xBFFFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _GlassEdgePainter old) => old.radius != radius;
}

class GlassAction extends StatefulWidget {
  const GlassAction({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.compact = false,
    this.emphasis = false,
    this.blur = 7,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool compact;
  final bool emphasis;
  final double blur;

  @override
  State<GlassAction> createState() => _GlassActionState();
}

class _GlassActionState extends State<GlassAction> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final radius = widget.compact ? 25.0 : 29.0;
    return AnimatedScale(
      scale: hovered && !reduceMotion ? 1.025 : 1,
      duration: Duration(milliseconds: reduceMotion ? 0 : 150),
      curve: Curves.easeOutCubic,
      child: LiquidGlass(
        radius: radius,
        blur: widget.blur,
        strong: widget.emphasis,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            onHover: (value) {
              if (hovered != value && mounted) {
                setState(() => hovered = value);
              }
            },
            borderRadius: BorderRadius.circular(radius),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: widget.compact ? 49 : 58,
                minWidth: widget.compact ? 100 : 169,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.compact ? 12 : 19,
                  vertical: widget.compact ? 12 : 16,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(widget.icon, size: widget.compact ? 17 : 19,
                        color: const Color(0xff222324)),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        widget.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xff202122),
                          fontSize: widget.compact ? 11 : 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: .35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
