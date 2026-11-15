import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const VisaRunApp());

class VisaRunApp extends StatelessWidget {
  const VisaRunApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'VISA RUN — Cross borders. Not fingers.',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xffb7b6ad),
      fontFamily: 'Roboto',
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xffae2d24)),
    ),
    home: const VisaLanding(),
  );
}

const ink = Color(0xff20211e);
const spray = Color(0xffa92c25);
const chalk = Color(0xffede9dd);

class VisaLanding extends StatefulWidget {
  const VisaLanding({super.key});
  @override
  State<VisaLanding> createState() => _VisaLandingState();
}

class _VisaLandingState extends State<VisaLanding> {
  ui.FragmentShader? shader;
  @override
  void initState() {
    super.initState();
    _loadShader();
  }

  Future<void> _loadShader() async {
    try {
      final program = await ui.FragmentProgram.fromAsset('shaders/concrete.frag');
      if (mounted) setState(() => shader = program.fragmentShader());
    } catch (_) {
      // A readable concrete-colored fallback remains available.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final compact = w < 960;
        // One scrolling wall: its pigment, grain and all content share the
        // exact same transform. Nothing is pinned to the viewport.
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: h),
            child: Stack(children: [
              Positioned.fill(
                child: RepaintBoundary(
                  child: CustomPaint(
                    key: const Key('concrete-wall'),
                    painter: ConcretePainter(shader),
                  ),
                ),
              ),
              const Positioned.fill(
                child: IgnorePointer(
                  child: RepaintBoundary(
                    child: CustomPaint(painter: WallMarksPainter()),
                  ),
                ),
              ),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1470),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(compact ? 24 : 62, 27, compact ? 24 : 62, 22),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      _header(compact),
                      SizedBox(height: compact ? 26 : 20),
                      if (compact) _mobileHero() else _desktopHero(),
                      SizedBox(height: compact ? 30 : 38),
                      _footer(compact),
                    ]),
                  ),
                ),
              ),
              // Faint concrete-coloured flecks also cross over the ink.
              // This is a static painter, not a frame-by-frame animation.
              const Positioned.fill(
                child: IgnorePointer(
                  child: RepaintBoundary(
                    child: CustomPaint(painter: PigmentWearPainter()),
                  ),
                ),
              ),
            ]),
          ),
        );
      }),
    );
  }

  Widget _header(bool compact) => Row(children: [
    const Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.public, color: spray, size: 24),
      SizedBox(width: 9),
      Text('VISA RUN', style: TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -1)),
    ]),
    const Spacer(),
    if (!compact) ...[
      _nav('THE ROUTE'), const SizedBox(width: 34),
      _nav('OUR STORY'), const SizedBox(width: 34),
    ],
    DecoratedBox(
      decoration: BoxDecoration(border: Border.all(color: ink, width: 1.6)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Text(compact ? 'DEMO' : 'CONCEPT / 001', style: const TextStyle(fontSize: 10, color: ink, fontWeight: FontWeight.w900, letterSpacing: 2)),
      ),
    )
  ]);

  Widget _nav(String text) => Text(text, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 1.6, color: ink));

  Widget _desktopHero() => SizedBox(
    height: 705,
    child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Expanded(flex: 52, child: _copy(false)),
      Expanded(flex: 48, child: Semantics(label: 'Original graffiti-style silhouette of a traveler carrying a suitcase beside a red spray-painted sun',
        child: const CustomPaint(painter: TravelerPainter()))),
    ]),
  );

  Widget _mobileHero() => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    _copy(true),
    const SizedBox(height: 12),
    SizedBox(height: 340, child: Semantics(label: 'Graffiti of a traveler with a suitcase', child: const CustomPaint(painter: TravelerPainter()))),
  ]);

  Widget _copy(bool compact) => Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
    Text('NO MORE BORING BORDERS    /    EST. 2026', style: TextStyle(color: ink.withValues(alpha: .67), fontSize: compact ? 9 : 11, letterSpacing: 2.1, fontWeight: FontWeight.w900)),
    const SizedBox(height: 16),
    Text('VISA\nRUN', style: TextStyle(height: .79, color: ink.withValues(alpha: .93), fontSize: compact ? 99 : 146, letterSpacing: compact ? -7 : -11, fontWeight: FontWeight.w900)),
    const SizedBox(height: 21),
    Transform.rotate(angle: -.034, alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        color: spray.withValues(alpha: .92),
        child: Text('CROSS BORDERS. NOT FINGERS.', style: TextStyle(color: chalk, fontSize: compact ? 13 : 16, fontWeight: FontWeight.w900, letterSpacing: compact ? .25 : 1.0)),
      ),
    ),
    const SizedBox(height: 28),
    ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Text('LESS PAPERWORK.\nMORE OPEN ROAD.', style: TextStyle(color: ink.withValues(alpha: .81), height: 1.26, fontSize: compact ? 18 : 22, fontWeight: FontWeight.w800, letterSpacing: -.35)),
    ),
    const SizedBox(height: 11),
    ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Text('Your next stamp, minus the drama. Simple border trips. Good people. A little freedom.', style: TextStyle(fontSize: compact ? 14 : 16, height: 1.55, color: ink.withValues(alpha: .68))),
    ),
    const SizedBox(height: 28),
    Wrap(spacing: 11, runSpacing: 12, children: [
      SprayButton(label: 'BORDER RUNS', filled: true),
      SprayButton(label: 'HOW IT WORKS', filled: false),
    ]),
    const SizedBox(height: 22),
    const Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.circle, size: 8, color: spray), SizedBox(width: 8),
      Flexible(
        child: Text('DEMO SITE   /   NOTHING TO BOOK YET',
          softWrap: true,
          style: TextStyle(color: ink, fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: .6)),
      ),
    ]),
  ]);

  Widget _footer(bool compact) {
    final left = Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 28, height: 2, color: spray), const SizedBox(width: 9),
      const Flexible(child: Text('THE WORLD IS BIGGER THAN YOUR VISA.', style: TextStyle(fontSize: 10, color: ink, fontWeight: FontWeight.w900, letterSpacing: 1.15))),
    ]);
    return Column(children: [
      Container(height: 1.5, color: ink.withValues(alpha: .4)),
      const SizedBox(height: 16),
      compact ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        left, const SizedBox(height: 17), const SprayButton(label: 'CONTACT US', filled: false),
      ]) : Row(children: [
        Expanded(child: left),
        const Text('STAMP. GO. REPEAT.', style: TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.3)),
        const SizedBox(width: 44),
        const SprayButton(label: 'CONTACT US', filled: false),
      ]),
    ]);
  }
}

class SprayButton extends StatefulWidget {
  final String label;
  final bool filled;
  const SprayButton({super.key, required this.label, required this.filled});
  @override
  State<SprayButton> createState() => _SprayButtonState();
}
class _SprayButtonState extends State<SprayButton> {
  bool hovered = false;
  bool pressed = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    onEnter: (_) => setState(() => hovered = true),
    onExit: (_) => setState(() { hovered = false; pressed = false; }),
    child: GestureDetector(
      onTapDown: (_) => setState(() => pressed = true),
      onTapUp: (_) => setState(() => pressed = false),
      onTapCancel: () => setState(() => pressed = false),
      onTap: () => HapticFeedback.selectionClick(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 125),
        padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 16),
        decoration: BoxDecoration(
          // Flat translucent paint: no floating UI or drop shadows.
          color: widget.filled
              ? (hovered ? ink.withValues(alpha: .91) : spray.withValues(alpha: .89))
              : (hovered ? ink.withValues(alpha: .87) : Colors.transparent),
          border: Border.all(
            width: pressed ? 2.7 : 2.1,
            color: ink.withValues(alpha: .9),
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(widget.label, style: TextStyle(color: hovered || widget.filled ? chalk : ink, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.25)),
          const SizedBox(width: 17),
          Icon(Icons.north_east, color: hovered || widget.filled ? chalk : ink, size: 16),
        ]),
      ),
    ),
  );
}

class ConcretePainter extends CustomPainter {
  final ui.FragmentShader? shader;
  ConcretePainter(this.shader);
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xffb9b7ad));
    if (shader == null) return;
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }
  @override
  bool shouldRepaint(covariant ConcretePainter oldDelegate) => shader != oldDelegate.shader;
}

class WallMarksPainter extends CustomPainter {
  const WallMarksPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final r = math.Random(311);
    final p = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < 90; i++) {
      final x = r.nextDouble() * size.width;
      final y = r.nextDouble() * size.height;
      p.color = ink.withValues(alpha: .014 + r.nextDouble() * .025);
      canvas.drawCircle(Offset(x, y), .4 + r.nextDouble() * 1.6, p);
    }
    p.color = ink.withValues(alpha: .08);
    canvas.drawRect(Rect.fromLTWH(0, size.height * .89, size.width, 1), p);
    final text = TextPainter(text: TextSpan(text: '◄  EXIT / ENTRY  ►', style: TextStyle(color: ink.withValues(alpha: .10), fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 4)), textDirection: TextDirection.ltr)..layout();
    text.paint(canvas, Offset(size.width * .54, size.height * .94));
  }
  @override
  bool shouldRepaint(covariant WallMarksPainter oldDelegate) => false;
}


/// Minuscule chips reveal the wall's warm base colour through painted ink.
/// Deterministic and deliberately sparse; scrolled/cached with the wall.
class PigmentWearPainter extends CustomPainter {
  const PigmentWearPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(709);
    final fleck = Paint()..color = const Color(0x35b9b7ad);
    for (var i = 0; i < 440; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      canvas.drawCircle(
        Offset(x, y),
        .3 + random.nextDouble() * .9,
        fleck,
      );
    }
  }

  @override
  bool shouldRepaint(covariant PigmentWearPainter oldDelegate) => false;
}

class TravelerPainter extends CustomPainter {
  const TravelerPainter();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    final scale = math.min(size.width / 570, size.height / 640);
    canvas.translate((size.width - 570 * scale) / 2, (size.height - 640 * scale) / 2);
    canvas.scale(scale);
    final black = Paint()..color = ink..style = PaintingStyle.fill;

    // Loose spray halo, painted as layered broken arcs rather than a perfect circle.
    for (int i = 0; i < 6; i++) {
      canvas.drawArc(Rect.fromCircle(center: const Offset(290, 263), radius: 176.0 + i * 5), -.95 + i * .08, 3.95 - i * .065, false,
        Paint()..color = spray.withValues(alpha: .75 - i * .1)..style = PaintingStyle.stroke..strokeWidth = 17 - i * 2);
    }
    canvas.drawCircle(const Offset(290, 263), 136, Paint()..color = spray.withValues(alpha: .10));
    final random = math.Random(18);
    for (int i = 0; i < 145; i++) {
      final ang = random.nextDouble() * math.pi * 2;
      final rad = 132 + random.nextDouble() * 122;
      final center = Offset(290 + math.cos(ang) * rad, 263 + math.sin(ang) * rad);
      canvas.drawCircle(center, .4 + random.nextDouble() * 2.1,
        Paint()..color = spray.withValues(alpha: random.nextDouble() * .55));
    }

    // A winged paper plane representing freedom of movement.
    final plane = Path()..moveTo(50, 175)..lineTo(173, 135)..lineTo(132, 180)..lineTo(123, 226)..lineTo(101, 187)..close();
    canvas.drawPath(plane, black);
    canvas.drawPath(Path()..moveTo(101, 187)..lineTo(173, 135)..lineTo(114, 196), Paint()..color = chalk.withValues(alpha: .6)..style = PaintingStyle.stroke..strokeWidth = 3);
    canvas.drawPath(Path()..moveTo(49, 225)..quadraticBezierTo(105, 255, 144, 238), Paint()..color = ink.withValues(alpha: .52)..style = PaintingStyle.stroke..strokeWidth = 2..strokeCap = StrokeCap.round);

    // Traveler's shadow and legs.
    canvas.drawOval(const Rect.fromLTWH(200, 552, 310, 18), Paint()..color = ink.withValues(alpha: .42));
    canvas.drawPath(Path()..moveTo(280, 412)..lineTo(350, 418)..lineTo(331, 522)..lineTo(314, 561)..lineTo(269, 561)..lineTo(295, 519)..close(), black);
    canvas.drawPath(Path()..moveTo(350, 412)..lineTo(382, 409)..lineTo(407, 512)..lineTo(431, 553)..lineTo(390, 558)..lineTo(363, 519)..close(), black);
    // Coat with long hem, hood, and wind-swept back.
    final coat = Path()
      ..moveTo(296, 276)..quadraticBezierTo(332, 248, 371, 274)
      ..quadraticBezierTo(391, 294, 407, 350)
      ..lineTo(449, 448)..quadraticBezierTo(385, 479, 254, 455)
      ..lineTo(273, 351)..quadraticBezierTo(252, 323, 296, 276)..close();
    canvas.drawPath(coat, black);
    // Hood, neck and face (anonymous silhouette).
    canvas.drawOval(const Rect.fromLTWH(304, 210, 75, 86), black);
    canvas.drawPath(Path()..moveTo(312, 231)..quadraticBezierTo(320, 196, 362, 206)..quadraticBezierTo(392, 221, 376, 262)..lineTo(356, 252)..lineTo(348, 235)..close(), black);
    canvas.drawPath(Path()..moveTo(361, 245)..lineTo(383, 257)..lineTo(365, 269)..close(), black);
    canvas.drawPath(Path()..moveTo(313, 309)..quadraticBezierTo(362, 321, 382, 291), Paint()..color = chalk.withValues(alpha: .28)..style = PaintingStyle.stroke..strokeWidth = 5);
    // One trailing arm reaches suitcase handle.
    canvas.drawPath(Path()..moveTo(400, 315)..quadraticBezierTo(431, 341, 448, 385)..lineTo(456, 437)..lineTo(437, 442)..lineTo(424, 393)..lineTo(385, 350)..close(), black);
    canvas.drawCircle(const Offset(448, 443), 12, black);
    // Roller suitcase.
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(430, 446, 87, 99), const Radius.circular(9)), black);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(444, 457, 61, 72), const Radius.circular(4)),
      Paint()..color = chalk.withValues(alpha: .20)..style = PaintingStyle.stroke..strokeWidth = 2);
    canvas.drawLine(const Offset(460, 444), const Offset(460, 411), Paint()..color = ink..strokeWidth = 6);
    canvas.drawLine(const Offset(460, 411), const Offset(479, 411), Paint()..color = ink..strokeWidth = 6);
    canvas.drawCircle(const Offset(450, 552), 9, black);
    canvas.drawCircle(const Offset(496, 552), 9, black);
    // Graffiti exclamation and destination marks.
    canvas.save(); canvas.translate(115, 393); canvas.rotate(-.19);
    final tp = TextPainter(text: const TextSpan(text: 'GO!', style: TextStyle(color: spray, fontSize: 91, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, letterSpacing: -8)), textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, Offset.zero); canvas.restore();
    canvas.drawPath(Path()..moveTo(105, 491)..lineTo(248, 479), Paint()..color = spray..style = PaintingStyle.stroke..strokeWidth = 8..strokeCap = StrokeCap.square);
    for (int i = 0; i < 9; i++) {
      final x = 140 + random.nextDouble() * 110;
      canvas.drawLine(Offset(x, 483), Offset(x, 489 + random.nextDouble() * 44), Paint()..color = spray.withValues(alpha: .7)..strokeWidth = 2 + random.nextDouble() * 4);
    }
    canvas.restore();
  }
  @override
  bool shouldRepaint(covariant TravelerPainter oldDelegate) => false;
}
