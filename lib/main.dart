import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'concrete_wall.dart';
import 'graffiti_widgets.dart';
import 'stencil_mural.dart';
import 'visa_i18n.dart';

void main() => runApp(const VisaRunApp());

class VisaRunApp extends StatelessWidget {
  const VisaRunApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'VISA RUN — Stencil on concrete',
    theme: ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: const Color(0xffb5b7b8),
      colorScheme: ColorScheme.fromSeed(seedColor: graffitiInk),
    ),
    home: const VisaLanding(),
  );
}

class VisaLanding extends StatefulWidget {
  const VisaLanding({super.key});

  @override
  State<VisaLanding> createState() => _VisaLandingState();
}

class _VisaLandingState extends State<VisaLanding> {
  static const languageKey = 'visa_run_language';

  ui.FragmentShader? _wallShader;
  String? _language;
  bool _languageReady = false;
  final TextEditingController _message = TextEditingController();

  String t(String key) => visaStrings[_language]![key]!;

  @override
  void initState() {
    super.initState();
    _readLanguage();
    _readShader();
  }

  Future<void> _readLanguage() async {
    String? saved;
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString(languageKey);
      if (value == 'en' || value == 'ru') saved = value;
    } catch (_) {
      // No storage permission: the initial wall picker still works.
    }
    if (!mounted) return;
    setState(() {
      _language = saved;
      _languageReady = true;
    });
  }

  Future<void> _chooseLanguage(String value) async {
    if (value != 'ru' && value != 'en') return;
    setState(() => _language = value);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(languageKey, value);
    } catch (_) {
      // Session-only selection remains usable without storage.
    }
  }

  Future<void> _readShader() async {
    try {
      final program =
          await ui.FragmentProgram.fromAsset('shaders/concrete.frag');
      if (mounted) {
        setState(() => _wallShader = program.fragmentShader());
      }
    } catch (_) {
      // The painted architecture remains visible with its color fallback.
    }
  }

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(builder: (context, limits) {
        final width = limits.maxWidth;
        final height = limits.maxHeight;
        final mobile = width < 970;
        final inset = mobile ? 23.0 : 54.0;

        // Crucial: architectural light, mineral shader, graffiti and
        // editable content all belong to ONE vertically scrolling wall.
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: height),
            child: Stack(children: [
              Positioned.fill(
                child: RepaintBoundary(
                  child: CustomPaint(
                    key: const Key('concrete-wall'),
                    painter: ConcreteWallPainter(_wallShader),
                  ),
                ),
              ),
              const Positioned.fill(
                child: IgnorePointer(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      key: Key('architectural-concrete-light'),
                      painter: ArchitecturalLightPainter(),
                    ),
                  ),
                ),
              ),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1510),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(inset, 20, inset, 33),
                    child: !_languageReady
                        ? SizedBox(height: math.max(540.0, height - 53))
                        : _language == null
                            ? _languageGate(mobile, height)
                            : _site(mobile, width, height),
                  ),
                ),
              ),
              const Positioned.fill(
                child: IgnorePointer(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: PaintWeatheringPainter(),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        );
      }),
    );
  }

  /// First-time visitor sees ONLY the language choices on the wall.
  Widget _languageGate(bool mobile, double height) => SizedBox(
        height: math.max(570.0, height - 53),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StencilText('LANGUAGE  /  ЯЗЫК',
                  fontSize: mobile ? 19 : 27,
                  height: 1.1,
                  letterSpacing: 1.5,
                  wear: .20),
              SizedBox(height: mobile ? 30 : 45),
              _languageChoice('ENGLISH', 'en', mobile),
              SizedBox(height: mobile ? 18 : 25),
              _languageChoice('РУССКИЙ', 'ru', mobile),
              const SizedBox(height: 19),
              const CustomPaint(
                painter: _PaintSwipePainter(),
                child: SizedBox(width: 210, height: 20),
              ),
            ],
          ),
        ),
      );

  Widget _languageChoice(String label, String language, bool mobile) {
    return TextButton(
      key: Key('choose-$language'),
      onPressed: () => _chooseLanguage(language),
      style: TextButton.styleFrom(
        foregroundColor: graffitiInk,
        padding: const EdgeInsets.symmetric(vertical: 4),
        overlayColor: graffitiInk.withValues(alpha: .05),
        shape: const RoundedRectangleBorder(),
      ),
      child: StencilText(
        label,
        fontSize: mobile ? 47 : 86,
        height: 1,
        letterSpacing: mobile ? -2 : -4,
      ),
    );
  }

  Widget _site(bool mobile, double width, double viewportHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _header(mobile),
        SizedBox(height: mobile ? 43 : 21),
        mobile ? _mobileHero(width) : _desktopHero(width, viewportHeight),
        SizedBox(height: mobile ? 32 : 34),
        _contactSection(mobile),
        const SizedBox(height: 35),
        _footer(mobile),
      ],
    );
  }

  Widget _header(bool mobile) => Row(
        children: [
          const Text(
            'VISA RUN',
            style: TextStyle(
              color: graffitiInk,
              fontSize: 19,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.4,
            ),
          ),
          const SizedBox(width: 6),
          const SizedBox(
            width: 44,
            height: 26,
            child: CustomPaint(painter: GraffitiPlaneMarkPainter()),
          ),
          const Spacer(),
          if (!mobile) ...[
            _nav(t('runs')),
            _nav(t('how')),
            _nav(t('faq')),
            _nav(t('contact')),
            const SizedBox(width: 24),
          ],
          _languageSwitch(),
        ],
      );

  Widget _nav(String label) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13),
        child: TextButton(
          onPressed: () {}, // Intentionally a design-only demo.
          style: TextButton.styleFrom(
            foregroundColor: graffitiInk,
            overlayColor: graffitiInk.withValues(alpha: .05),
            padding: EdgeInsets.zero,
            minimumSize: const Size(15, 46),
            shape: const RoundedRectangleBorder(),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: graffitiInk,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: .5,
            ),
          ),
        ),
      );

  Widget _languageSwitch() => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _languageToggle('EN', 'en'),
          const Text('/', style: TextStyle(fontSize: 14, color: graffitiInk)),
          _languageToggle('RU', 'ru'),
        ],
      );

  Widget _languageToggle(String label, String value) {
    final selected = value == _language;
    return TextButton(
      key: Key('switch-$value'),
      onPressed: () => _chooseLanguage(value),
      style: TextButton.styleFrom(
        foregroundColor: selected ? graffitiChalk : graffitiInk,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        minimumSize: const Size(36, 42),
        overlayColor: graffitiInk.withValues(alpha: .05),
        shape: const RoundedRectangleBorder(),
      ),
      child: selected
          ? CustomPaint(
              painter: const GraffitiPlatePainter(seed: 66),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(7, 7, 7, 11),
                child: Text(label,
                    style: const TextStyle(
                      color: graffitiChalk,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    )),
              ),
            )
          : Text(label,
              style: const TextStyle(
                color: graffitiInk,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              )),
    );
  }

  Widget _desktopHero(double screenWidth, double viewportHeight) {
    final titleSize = math.min(172.0, math.max(106.0, screenWidth * .115));
    return SizedBox(
      height: math.max(620.0, math.min(730.0, viewportHeight * .82)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 50, child: _heroCopy(titleSize, false)),
          Expanded(
            flex: 50,
            child: Semantics(
              label: t('illustration'),
              child: const RepaintBoundary(
                child: CustomPaint(painter: StencilMuralPainter()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mobileHero(double screenWidth) {
    final titleSize = math.min(112.0, math.max(72.0, screenWidth * .235));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _heroCopy(titleSize, true),
      const SizedBox(height: 9),
      SizedBox(
        height: screenWidth < 400 ? 345 : 410,
        child: Semantics(
          label: t('illustration'),
          child: const RepaintBoundary(
            child: CustomPaint(painter: StencilMuralPainter()),
          ),
        ),
      ),
    ]);
  }

  Widget _heroCopy(double titleSize, bool mobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment:
          mobile ? MainAxisAlignment.start : MainAxisAlignment.center,
      children: [
        StencilText(
          'VISA\nRUN',
          fontSize: titleSize,
          height: .82,
          letterSpacing: -titleSize * .045,
          wear: .94,
        ),
        SizedBox(height: mobile ? 12 : 26),
        StencilText(
          t('headline'),
          fontSize: mobile ? 21 : 29,
          height: 1.05,
          letterSpacing: -.6,
          wear: .58,
        ),
        const CustomPaint(
          painter: _PaintSwipePainter(),
          child: SizedBox(width: 280, height: 22),
        ),
        SizedBox(height: mobile ? 12 : 27),
        Text(
          t('intro'),
          style: TextStyle(
            color: graffitiInk.withValues(alpha: .84),
            fontSize: mobile ? 13 : 16,
            fontWeight: FontWeight.w700,
            height: 1.45,
          ),
        ),
        SizedBox(height: mobile ? 19 : 32),
        Wrap(
          spacing: 12,
          runSpacing: 7,
          children: [
            GraffitiButton(label: t('runs'), compact: mobile),
            GraffitiButton(label: t('how'), compact: mobile),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          t('demo'),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: graffitiInk.withValues(alpha: .68),
            letterSpacing: .8,
          ),
        ),
      ],
    );
  }

  Widget _contactSection(bool mobile) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: mobile ? 570 : 850),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          StencilText(
            t('fieldTitle'),
            fontSize: mobile ? 28 : 43,
            height: 1.07,
            letterSpacing: -.8,
            wear: .45,
          ),
          const SizedBox(height: 16),
          GraffitiTextField(
            hint: t('fieldHint'),
            controller: _message,
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 18,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              GraffitiButton(label: t('sendDemo'), compact: true),
              Text(
                t('fieldNote'),
                style: TextStyle(
                  color: graffitiInk.withValues(alpha: .75),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .7,
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  Widget _footer(bool mobile) {
    return Column(children: [
      Container(height: 1.5, color: graffitiInk.withValues(alpha: .65)),
      const SizedBox(height: 16),
      if (mobile)
        Align(
          alignment: Alignment.centerLeft,
          child: Text(t('quote'),
              style: const TextStyle(
                color: graffitiInk,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: .7,
              )),
        )
      else
        Row(children: [
          Expanded(
            child: Text(t('quote'),
                style: const TextStyle(
                  color: graffitiInk,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                )),
          ),
          Text(t('closing'),
              style: const TextStyle(
                color: graffitiInk,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              )),
        ]),
    ]);
  }
}

/// A sprayed underline with drips, not a perfectly straight Material divider.
class _PaintSwipePainter extends CustomPainter {
  const _PaintSwipePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final ink = Paint()..color = graffitiInk.withValues(alpha: .93);
    final path = Path()
      ..moveTo(0, 6)
      ..lineTo(size.width * .94, 1)
      ..lineTo(size.width, 4)
      ..lineTo(size.width * .76, 8)
      ..lineTo(size.width * .21, 12)
      ..lineTo(0, 8)
      ..close();
    canvas.drawPath(path, ink);
    for (final x in [.08, .46, .83]) {
      final dx = size.width * x;
      final end = x == .46 ? 20.0 : 15.0;
      canvas.drawLine(Offset(dx, 8), Offset(dx, end),
          ink..strokeWidth = 2.3..strokeCap = StrokeCap.round);
    }
  }

  @override
  bool shouldRepaint(covariant _PaintSwipePainter oldDelegate) => false;
}
