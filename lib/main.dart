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
      scaffoldBackgroundColor: const Color(0xffb4b6b7),
      fontFamily: 'Roboto',
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff1c1c1b)),
    ),
    home: const VisaLanding(),
  );
}

// A single monochrome pigment is used everywhere; no red accent paint.
const ink = Color(0xff181919);
const spray = Color(0xff181919);
const chalk = Color(0xffe1e1df);

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
                    child: CustomPaint(
                      key: const Key('architectural-concrete-light'),
                      painter: WallMarksPainter(),
                    ),
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
      Expanded(flex: 48, child: Semantics(label: 'Original black stencil-graffiti silhouette of a traveler with luggage painted onto sunlit concrete',
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
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xffb6b7b8));
    if (shader == null) return;
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }
  @override
  bool shouldRepaint(covariant ConcretePainter oldDelegate) => shader != oldDelegate.shader;
}

/// Architectural concrete cast in a single static pass.
/// Panel joints, oblique daylight and the floor all belong to the same
/// scrollable canvas as the painted lettering. No animation or image fetch.
class WallMarksPainter extends CustomPainter {
  const WallMarksPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final floorY = h * .735;
    final wall = Rect.fromLTWH(0, 0, w, floorY);

    canvas.save();
    canvas.clipRect(wall);

    // Gentle upper-left occlusion, pale grey towards the sunlight.
    canvas.drawRect(
      wall,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, 0),
          Offset(w * .86, h * .72),
          const [
            Color(0x64131617),
            Color(0x1C333637),
            Color(0x00FFFFFF),
            Color(0x18FFFFFF),
          ],
          const [0, .38, .7, 1],
        ),
    );

    // Large sunlit region, like a shaft coming from a high right window.
    // Deliberately geometric and static: architecture, not a filter effect.
    final wash = Path()
      ..moveTo(w * 1.12, h * .23)
      ..lineTo(w * 1.12, floorY)
      ..lineTo(w * .22, floorY)
      ..close();
    canvas.drawPath(wash, Paint()..color = const Color(0x43FFFFFF));

    // Soft outer penumbra around the window beam.
    final fringe = Path()
      ..moveTo(w * 1.17, h * .105)
      ..lineTo(w * 1.24, h * .24)
      ..lineTo(w * .39, floorY)
      ..lineTo(-w * .035, floorY)
      ..close();
    canvas.drawPath(fringe, Paint()..color = const Color(0x22FFFFFF));

    // Distinct sun stripe seen in the reference; polygon edges are crisp.
    final sunBeam = Path()
      ..moveTo(w * 1.11, h * .122)
      ..lineTo(w * 1.19, h * .206)
      ..lineTo(w * .32, floorY)
      ..lineTo(w * .115, floorY)
      ..close();
    canvas.drawPath(sunBeam, Paint()..color = const Color(0x9CFFFFFF));

    // A second quiet edge of light, as cast by adjacent glazing.
    final secondBeam = Path()
      ..moveTo(w * 1.21, h * .45)
      ..lineTo(w * 1.21, h * .54)
      ..lineTo(w * .87, floorY)
      ..lineTo(w * .70, floorY)
      ..close();
    canvas.drawPath(secondBeam, Paint()..color = const Color(0x39FFFFFF));

    // Large, realistically recessed prefabricated concrete panel joints.
    void verticalJoint(double x) {
      canvas.drawRect(
        Rect.fromLTWH(x - 1.8, 0, 3, floorY),
        Paint()..color = const Color(0x41090A0A),
      );
      canvas.drawRect(
        Rect.fromLTWH(x + 1.2, 0, .9, floorY),
        Paint()..color = const Color(0x65FFFFFF),
      );
    }

    void horizontalJoint(double y) {
      canvas.drawRect(
        Rect.fromLTWH(0, y - 1.5, w, 2.4),
        Paint()..color = const Color(0x460A0B0C),
      );
      canvas.drawRect(
        Rect.fromLTWH(0, y + .9, w, .9),
        Paint()..color = const Color(0x55FFFFFF),
      );
    }

    final panelW = w < 700 ? w * .60 : w * .345;
    for (var x = panelW; x < w; x += panelW) {
      verticalJoint(x);
    }
    horizontalJoint(h * .045);
    horizontalJoint(h * .475);

    // Small form-tie holes and mineral pinholes, fixed to the wall.
    final random = math.Random(419);
    for (var i = 0; i < 96; i++) {
      final x = random.nextDouble() * w;
      final y = random.nextDouble() * floorY;
      final radius = .45 + random.nextDouble() * 1.45;
      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()..color = const Color(0x42161919),
      );
      if (i % 4 == 0) {
        canvas.drawCircle(
          Offset(x + radius * .55, y + radius * .7),
          radius * .60,
          Paint()..color = const Color(0x52FFFFFF),
        );
      }
    }
    for (var x = panelW * .13; x < w; x += panelW) {
      for (final y in [h * .060, h * .448]) {
        canvas.drawCircle(
          Offset(x, y), 2.2,
          Paint()..color = const Color(0x7A252626),
        );
        canvas.drawCircle(
          Offset(x + .6, y + .7), .8,
          Paint()..color = const Color(0x43FFFFFF),
        );
      }
    }
    canvas.restore();

    // Floor plane below the wall. Lighting is also static and scrolls
    // with the entire composition (no parallax or GPU redraw loop).
    final floor = Rect.fromLTRB(0, floorY, w, h);
    canvas.drawRect(
      floor,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, floorY),
          Offset(w * .13, h),
          const [
            Color(0xffc9cbca),
            Color(0xff969998),
            Color(0xff707373),
          ],
          const [0, .48, 1],
        ),
    );

    // A broad near-white patch where the sun hits the floor.
    final floorLight = Path()
      ..moveTo(0, floorY + 2)
      ..lineTo(w * .95, floorY + 2)
      ..lineTo(w * 1.12, h * .87)
      ..lineTo(-w * .12, h * .84)
      ..close();
    canvas.drawPath(floorLight, Paint()..color = const Color(0xDDF6F7F5));

    // Window mullion shadows on the illuminated ground.
    final sillShadow = Path()
      ..moveTo(0, floorY + 20)
      ..lineTo(w, floorY + 44)
      ..lineTo(w, floorY + 49)
      ..lineTo(0, floorY + 25)
      ..close();
    canvas.drawPath(sillShadow, Paint()..color = const Color(0x5B525758));

    final floorBar = Path()
      ..moveTo(0, h * .806)
      ..lineTo(w, h * .842)
      ..lineTo(w, h * .854)
      ..lineTo(0, h * .818)
      ..close();
    canvas.drawPath(floorBar, Paint()..color = const Color(0x60535959));

    // The wall / floor transition is a real architectural edge.
    canvas.drawRect(
      Rect.fromLTWH(0, floorY - 2.5, w, 2.5),
      Paint()..color = const Color(0x72070707),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, floorY, w, 2),
      Paint()..color = const Color(0x8FFFFFFF),
    );
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
    final fleck = Paint()..color = const Color(0x23b5b6b7);
    for (var i = 0; i < 320; i++) {
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

    // Original monochrome stencil halo: old red paint is removed.
    // Broken black overspray stays subordinate to the photographic wall.
    for (int i = 0; i < 5; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: const Offset(290, 263), radius: 176.0 + i * 5),
        -.95 + i * .08,
        3.95 - i * .065,
        false,
        Paint()
          ..color = ink.withValues(alpha: .24 - i * .035)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 11 - i,
      );
    }
    canvas.drawCircle(
      const Offset(290, 263), 136,
      Paint()..color = ink.withValues(alpha: .035),
    );
    final random = math.Random(18);
    for (int i = 0; i < 145; i++) {
      final ang = random.nextDouble() * math.pi * 2;
      final rad = 132 + random.nextDouble() * 122;
      final center = Offset(290 + math.cos(ang) * rad, 263 + math.sin(ang) * rad);
      canvas.drawCircle(center, .4 + random.nextDouble() * 2.1,
        Paint()..color = spray.withValues(alpha: random.nextDouble() * .30));
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
