import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bus_mural.dart';
import 'concrete_scene.dart';
import 'glass_calendar.dart';
import 'graffiti_widgets.dart';
import 'liquid_glass.dart';

void main() => runApp(const VisaRunApp());

class VisaRunApp extends StatelessWidget {
  const VisaRunApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'VISA RUN',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: const Color(0xffbdbbb7),
      colorScheme: ColorScheme.fromSeed(seedColor: graffitiInk),
    ),
    home: const VisaLanding(),
  );
}

/// One concrete wall, one real vector graffiti mural and an immediately
/// available interactive calendar. No initial Book button or modal.
class VisaLanding extends StatefulWidget {
  const VisaLanding({super.key});

  @override
  State<VisaLanding> createState() => _VisaLandingState();
}

class _VisaLandingState extends State<VisaLanding> {
  static const _languageKey = 'visa_run_language';

  String? _language;
  bool _ready = false;
  ui.FragmentShader? _concreteShader;
  bool get _russian => _language == 'ru';

  @override
  void initState() {
    super.initState();
    _restoreLanguage();
    _loadShader();
  }

  Future<void> _loadShader() async {
    try {
      final program =
          await ui.FragmentProgram.fromAsset('shaders/concrete.frag');
      if (mounted) setState(() => _concreteShader = program.fragmentShader());
    } catch (_) {
      // The custom-painter fallback still draws the wall and daylight.
    }
  }

  Future<void> _restoreLanguage() async {
    String? saved;
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString(_languageKey);
      if (value == 'ru' || value == 'en') saved = value;
    } catch (_) {
      // A blocked browser preference store simply shows the first-visit gate.
    }
    if (!mounted) return;
    setState(() {
      _language = saved;
      _ready = true;
    });
  }

  Future<void> _chooseLanguage(String code) async {
    if (code != 'en' && code != 'ru') return;
    setState(() => _language = code);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, code);
    } catch (_) {
      // Keep the tab functional even in restricted browsing mode.
    }
  }

  void _notice(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        backgroundColor: const Color(0xff222324),
      ));
  }

  void _continueWithDate(DateTime? date) {
    if (date == null) {
      _notice(_russian
          ? 'Сначала выберите дату поездки.'
          : 'Please choose your travel date first.');
      return;
    }
    final stamp = [
      date.day.toString().padLeft(2, '0'),
      date.month.toString().padLeft(2, '0'),
      date.year.toString(),
    ].join('/');
    _notice(_russian
        ? 'Дата $stamp выбрана. Это демо: бронирование ещё не подключено.'
        : '$stamp selected. Demo only — booking is not connected yet.');
  }

  void _contact(String channel) => _notice(_russian
      ? 'Ссылка $channel ещё не настроена.'
      : '$channel contact is not configured yet.');

  @override
  Widget build(BuildContext context) => Scaffold(
    body: LayoutBuilder(builder: (context, limits) {
      final width = limits.maxWidth;
      final viewportHeight = limits.maxHeight;
      final mobile = width < 950;
      final height = math.max(720.0, viewportHeight);

      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: viewportHeight),
          child: Stack(children: [
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(
                  key: const Key('concrete-wall'),
                  painter: ConcreteScenePainter(_concreteShader),
                ),
              ),
            ),
            if (!_ready)
              SizedBox(width: width, height: math.max(720.0, viewportHeight))
            else if (_language == null)
              SizedBox(
                width: width,
                height: math.max(720.0, viewportHeight),
                child: Stack(children: [
                  _firstVisit(mobile, width, height),
                ]),
              )
            else if (mobile)
              _mobileLayout(width)
            else
              SizedBox(
                width: width,
                height: height,
                child: _desktopLayout(width, height),
              ),
          ]),
        ),
      );
    }),
  );

  Widget _firstVisit(bool mobile, double width, double height) => Positioned(
    left: mobile ? 26 : math.max(56.0, width * .08),
    right: mobile ? 18 : null,
    top: mobile ? 135 : height * .32,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      StencilText('LANGUAGE  /  ЯЗЫК',
        fontSize: mobile ? 22 : 29,
        height: 1, letterSpacing: 1,
        wear: .38),
      const SizedBox(height: 29),
      _choice('ENGLISH', 'en', mobile),
      const SizedBox(height: 14),
      _choice('РУССКИЙ', 'ru', mobile),
    ]),
  );

  Widget _choice(String text, String code, bool mobile) => TextButton(
    key: Key('choose-$code'),
    onPressed: () => _chooseLanguage(code),
    style: TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 5),
      overlayColor: graffitiInk.withValues(alpha: .045),
      foregroundColor: graffitiInk,
      shape: const RoundedRectangleBorder(),
    ),
    child: StencilText(text,
      fontSize: mobile ? 49 : 83,
      height: 1,
      letterSpacing: mobile ? -2.0 : -4,
      wear: .75),
  );

  Widget _languageSwitch({required bool mobile}) => LiquidGlass(
    radius: 27,
    blur: mobile ? 4 : 6,
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      _toggle('EN', 'en'),
      Container(width: 1, height: 21,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        color: const Color(0x663F4142)),
      _toggle('RU', 'ru'),
    ]),
  );

  Widget _toggle(String label, String code) {
    final selected = code == _language;
    return TextButton(
      key: Key('switch-$code'),
      onPressed: () => _chooseLanguage(code),
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xff222324),
        minimumSize: const Size(38, 44),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        overlayColor: const Color(0x08000000),
        shape: const RoundedRectangleBorder(),
      ),
      child: Text(label,
        style: TextStyle(
          color: const Color(0xff232424)
              .withValues(alpha: selected ? 1 : .45),
          fontSize: 12,
          fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
        ),
      ),
    );
  }

  Widget _socialButton(String label, IconData icon,
      {required bool mobile}) => GlassAction(
    key: Key('contact-${label.toLowerCase()}'),
    label: label,
    icon: icon,
    compact: true,
    blur: mobile ? 3 : 6,
    groupedBackdrop: true,
    onPressed: () => _contact(label),
  );

  Widget _socialActions({required bool mobile}) => BackdropGroup(
    // These capsules never overlap and use the same sigma at each
    // breakpoint. The calendar stays OUTSIDE this group to preserve the
    // bus painted behind its glass.
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _socialButton('WhatsApp', Icons.chat_bubble_outline, mobile: mobile),
        SizedBox(width: mobile ? 8 : 15),
        _socialButton('Telegram', Icons.send_outlined, mobile: mobile),
      ],
    ),
  );

  Widget _graffitiTitle(double size) => RepaintBoundary(
    child: CustomPaint(
      foregroundPainter: const _PaintDripsPainter(),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 25),
        child: StencilText(
          'VISA RUN',
          fontSize: size,
          height: .95,
          letterSpacing: -size * .049,
          wear: .83,
        ),
      ),
    ),
  );

  Widget _busImage(double width) => Semantics(
    label: _russian
        ? 'Чёрное граффити с автобусом на бетонной стене'
        : 'Black vector-stencil bus graffiti painted on concrete',
    child: SizedBox(
      width: width,
      height: width * (505 / 1179),
      child: const RepaintBoundary(
        child: CustomPaint(
          key: Key('vector-bus-mural'),
          painter: BusMuralPainter(),
        ),
      ),
    ),
  );

  Widget _desktopLayout(double width, double height) {
    final margin = math.max(46.0, width * .055);
    final calendarWidth = (width * .27).clamp(340.0, 410.0);
    // The bus now spans the calendar's footprint instead of stopping at
    // the right-hand column. Paint it BEFORE the glass so it shows through.
    final muralWidth = math.min(width - margin * 1.6, width * .93);
    final titleSize = (width * .093).clamp(82.0, 148.0);
    return Stack(children: [
      Positioned(
        top: 27,
        right: margin,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _socialActions(mobile: false),
          const SizedBox(width: 18),
          _languageSwitch(mobile: false),
        ]),
      ),
      Positioned(
        left: margin * .55,
        top: math.max(270.0, height * .365),
        child: IgnorePointer(
          child: _busImage(muralWidth),
        ),
      ),
      Positioned(
        left: margin,
        top: math.max(104.0, height * .145),
        child: _graffitiTitle(titleSize),
      ),
      Positioned(
        // The calendar is the foreground layer above the bus vector.
        top: math.max(155.0, height * .20),
        right: margin,
        child: GlassBookingCalendar(
          key: const Key('booking-calendar'),
          language: _language!,
          width: calendarWidth,
          onBook: _continueWithDate,
        ),
      ),
    ]);
  }

  Widget _mobileLayout(double width) {
    final titleSize = (width * .145).clamp(46.0, 78.0);
    final padding = width < 400 ? 12.0 : 22.0;
    final contentWidth = width - 2 * padding;
    final calendarWidth = math.min(contentWidth, 460.0);
    // Scale the entire vector bus to available screen width, never larger
    // than the padded viewport. Keep it centered behind the calendar.
    final muralWidth = math.min(contentWidth, 680.0);

    // Calendar sets this stack's height; the bus stays behind it but
    // always fits within the mobile viewport, including 320px screens.
    return SizedBox(
      width: width,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            Align(
              alignment: Alignment.centerRight,
              child: _languageSwitch(mobile: true),
            ),
            const SizedBox(height: 11),
            Center(child: _socialActions(mobile: true)),
            const SizedBox(height: 28),
            _graffitiTitle(titleSize),
            const SizedBox(height: 16),
            Center(
              child: SizedBox(
                width: calendarWidth,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: 145,
                      left: (calendarWidth - muralWidth) / 2,
                      child: IgnorePointer(
                        child: _busImage(muralWidth),
                      ),
                    ),
                    GlassBookingCalendar(
                      key: const Key('booking-calendar'),
                      language: _language!,
                      mobile: true,
                      width: calendarWidth,
                      onBook: _continueWithDate,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 72),
          ],
        ),
      ),
    );
  }
}

class _PaintDripsPainter extends CustomPainter {
  const _PaintDripsPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xff171819).withValues(alpha: .91)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    for (final pair in [
      [size.width * .045, size.height * .80, size.height * .93],
      [size.width * .27, size.height * .80, size.height * .87],
      [size.width * .72, size.height * .81, size.height * .92],
      [size.width * .94, size.height * .82, size.height * .88],
    ]) {
      canvas.drawLine(Offset(pair[0], pair[1]),
          Offset(pair[0], pair[2]), p);
      canvas.drawCircle(Offset(pair[0], pair[2]), 1.5, p);
    }
  }
  @override
  bool shouldRepaint(covariant _PaintDripsPainter old) => false;
}
