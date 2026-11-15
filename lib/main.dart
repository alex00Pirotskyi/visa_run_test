import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'balloon_mural.dart';
import 'concrete_wall.dart';
import 'graffiti_calendar.dart';
import 'graffiti_widgets.dart';

void main() => runApp(const VisaRunApp());

class VisaRunApp extends StatelessWidget {
  const VisaRunApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'VISA RUN — Graffiti Calendar',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xffe8e6e3),
      fontFamily: 'Roboto',
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
  static const _languageKey = 'visa_run_language';
  String? _language;
  bool _loaded = false;
  ui.FragmentShader? _shader;
  bool get _ru => _language == 'ru';

  @override
  void initState() {
    super.initState();
    _restoreLanguage();
    _loadShader();
  }

  Future<void> _restoreLanguage() async {
    String? language;
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_languageKey);
      if (stored == 'en' || stored == 'ru') language = stored;
    } catch (_) {
      // A browser without storage still supports session-only selection.
    }
    if (!mounted) return;
    setState(() {
      _language = language;
      _loaded = true;
    });
  }

  Future<void> _selectLanguage(String language) async {
    if (language != 'en' && language != 'ru') return;
    setState(() => _language = language);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, language);
    } catch (_) {
      // The current page can still use the selection.
    }
  }

  Future<void> _loadShader() async {
    try {
      final program =
          await ui.FragmentProgram.fromAsset('shaders/concrete.frag');
      if (mounted) setState(() => _shader = program.fragmentShader());
    } catch (_) {
      // Pale concrete fallback is always drawn.
    }
  }

  void _notice(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: graffitiInk,
      ));
  }

  void _book(DateTime? date) {
    if (date == null) {
      _notice(_ru ? 'Сначала выберите дату поездки.'
          : 'Select a travel date first.');
      return;
    }
    final chosen = [
      date.day.toString().padLeft(2, '0'),
      date.month.toString().padLeft(2, '0'),
      date.year.toString(),
    ].join('/');
    _notice(_ru
        ? 'Дата $chosen выбрана. Это демо — бронирование не подключено.'
        : '$chosen selected. Demo only — booking is not connected.');
  }

  void _contact(String service) {
    _notice(_ru
        ? 'Ссылка на $service пока не настроена.'
        : '$service contact link is not configured yet.');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: LayoutBuilder(builder: (context, limits) {
      final width = limits.maxWidth;
      final viewportHeight = limits.maxHeight;
      final mobile = width < 1000;
      final stageHeight = mobile
          ? math.max(1000.0, viewportHeight)
          : math.max(760.0, viewportHeight);

      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: viewportHeight),
          child: Stack(children: [
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(
                  key: const Key('concrete-wall'),
                  painter: ConcreteWallPainter(_shader),
                ),
              ),
            ),
            const Positioned.fill(
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: CustomPaint(
                    key: Key('concrete-surface-detail'),
                    painter: PaleConcreteDetailsPainter(),
                  ),
                ),
              ),
            ),
            if (!_loaded)
              SizedBox(height: stageHeight)
            else if (_language == null)
              _languageGate(mobile, stageHeight)
            else if (mobile)
              _mobileStage(width, stageHeight)
            else
              _desktopStage(width, stageHeight),
          ]),
        ),
      );
    }),
  );

  Widget _languageGate(bool mobile, double height) => SizedBox(
    height: height,
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StencilText(
            'LANGUAGE / ЯЗЫК',
            fontSize: mobile ? 20 : 30,
            letterSpacing: 1,
          ),
          const SizedBox(height: 28),
          _choose('ENGLISH', 'en', mobile),
          const SizedBox(height: 15),
          _choose('РУССКИЙ', 'ru', mobile),
        ],
      ),
    ),
  );

  Widget _choose(String label, String code, bool mobile) => TextButton(
    key: Key('choose-$code'),
    style: TextButton.styleFrom(
      foregroundColor: graffitiInk,
      overlayColor: graffitiInk.withValues(alpha: .05),
      shape: const RoundedRectangleBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
    ),
    onPressed: () => _selectLanguage(code),
    child: StencilText(
      label,
      fontSize: mobile ? 43 : 78,
      height: 1,
      letterSpacing: -2.1,
      wear: .53,
    ),
  );

  Widget _langSwitch() => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      _switch('EN', 'en'),
      const Text('/', style: TextStyle(
        color: graffitiInk, fontSize: 14, fontWeight: FontWeight.w900)),
      _switch('RU', 'ru'),
    ],
  );

  Widget _switch(String label, String code) => TextButton(
    key: Key('switch-$code'),
    onPressed: () => _selectLanguage(code),
    style: TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      minimumSize: const Size(38, 44),
      foregroundColor: graffitiInk,
      shape: const RoundedRectangleBorder(),
    ),
    child: Text(label, style: TextStyle(
      color: graffitiInk,
      fontSize: 13,
      fontWeight: _language == code ? FontWeight.w900 : FontWeight.w600,
      decoration: _language == code ? TextDecoration.underline : null,
      decorationThickness: 2.2,
    )),
  );

  Widget _calendar(double width) => Transform.rotate(
    angle: -.048,
    alignment: Alignment.center,
    child: RepaintBoundary(
      child: GraffitiBookingCalendar(
        width: width,
        language: _language!,
        onBook: _book,
      ),
    ),
  );

  Widget _contacts(bool mobile) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      GraffitiButton(
        key: const Key('contact-whatsapp'),
        label: 'WHATSAPP',
        compact: true,
        width: mobile ? 114 : 168,
        showArrow: false,
        onPressed: () => _contact('WhatsApp'),
      ),
      const SizedBox(height: 8),
      GraffitiButton(
        key: const Key('contact-telegram'),
        label: 'TELEGRAM',
        compact: true,
        width: mobile ? 114 : 168,
        showArrow: false,
        onPressed: () => _contact('Telegram'),
      ),
    ],
  );

  Widget _desktopStage(double width, double height) {
    final left = math.max(35.0, width * .056);
    final cardWidth = math.min(315.0, math.max(260.0, width * .275));
    return SizedBox(
      height: height,
      child: Stack(children: [
        const Positioned.fill(
          child: IgnorePointer(
            child: RepaintBoundary(
              child: CustomPaint(
                key: Key('balloon-girl-art'),
                painter: BalloonGirlPainter(),
              ),
            ),
          ),
        ),
        Positioned(top: 17, right: 37, child: _langSwitch()),
        Positioned(top: 72, left: left, child: _calendar(cardWidth)),
        Positioned(left: left + 7, bottom: 72, child: _contacts(false)),
      ]),
    );
  }

  Widget _mobileStage(double width, double height) {
    final cardWidth = math.min(290.0, width - 36);
    return SizedBox(
      height: height,
      child: Stack(children: [
        Positioned(right: 18, top: 10, child: _langSwitch()),
        Positioned(top: 60, left: (width - cardWidth) / 2,
          child: _calendar(cardWidth)),
        const Positioned(
          top: 435,
          left: 0,
          right: 0,
          height: 510,
          child: IgnorePointer(
            child: RepaintBoundary(
              child: CustomPaint(
                key: Key('balloon-girl-art'),
                painter: BalloonGirlPainter(mobile: true),
              ),
            ),
          ),
        ),
        Positioned(left: 8, top: 715, child: _contacts(true)),
      ]),
    );
  }
}
