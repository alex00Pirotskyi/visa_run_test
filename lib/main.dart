import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      scaffoldBackgroundColor: const Color(0xffedebea),
      colorScheme: ColorScheme.fromSeed(seedColor: graffitiInk),
    ),
    home: const VisaLanding(),
  );
}

/// Art-gallery first: one still mural and three small optical glass controls.
/// The calendar appears only after booking is tapped, never on first view.
class VisaLanding extends StatefulWidget {
  const VisaLanding({super.key});
  @override State<VisaLanding> createState() => _VisaLandingState();
}

class _VisaLandingState extends State<VisaLanding> {
  static const _languageKey = 'visa_run_language';
  static const _wallAsset = 'assets/images/banksy_wall.webp';
  static const _wallColor = Color(0xffedebea);

  String? _language;
  bool _ready = false;
  bool _calendarOpen = false;
  bool get ru => _language == 'ru';

  @override void initState() {
    super.initState();
    _restoreLanguage();
  }

  Future<void> _restoreLanguage() async {
    String? language;
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_languageKey);
      if (saved == 'en' || saved == 'ru') language = saved;
    } catch (_) {
      // No persistent storage: still offer the language choice.
    }
    if (!mounted) return;
    setState(() {
      _language = language;
      _ready = true;
    });
  }

  Future<void> _chooseLanguage(String language) async {
    if (language != 'en' && language != 'ru') return;
    setState(() => _language = language);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, language);
    } catch (_) {
      // Keep working in the current session.
    }
  }

  void _notice(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xff252526),
      ));
  }

  void _book(DateTime? date) {
    if (date == null) {
      _notice(ru ? 'Сначала выберите дату поездки.' :
          'Please select a travel date first.');
      return;
    }
    final dateText = [
      date.day.toString().padLeft(2, '0'),
      date.month.toString().padLeft(2, '0'),
      date.year.toString(),
    ].join('/');
    setState(() => _calendarOpen = false);
    _notice(ru
        ? 'Дата $dateText выбрана. Это демо: бронирование пока недоступно.'
        : '$dateText selected. This is a demo; booking is not connected.');
  }

  void _contact(String service) => _notice(ru
      ? 'Контакт $service ещё не подключён.'
      : '$service contact is not configured yet.');

  @override Widget build(BuildContext context) => Scaffold(
    body: LayoutBuilder(builder: (context, limits) {
      final width = limits.maxWidth;
      final height = limits.maxHeight;
      final mobile = width < 800;
      final stageHeight = mobile ? math.max(690.0, height) : math.max(700.0, height);
      final bottomInset = MediaQuery.paddingOf(context).bottom;

      // Painting, controls and calendar share a single scroll coordinate.
      // There is no full-screen BackdropFilter or continuous animation.
      return SingleChildScrollView(
        child: SizedBox(
          width: width,
          height: stageHeight,
          child: Stack(children: [
            Positioned.fill(
              child: ColoredBox(color: _wallColor,
                child: mobile ? _mobileMural(width) : _desktopMural(),
              ),
            ),
            if (!_ready)
              const SizedBox.expand()
            else if (_language == null)
              _languageGate(mobile, width, stageHeight)
            else ...[
              _identityAndSwitch(mobile),
              _actions(mobile, bottomInset),
              if (_calendarOpen) ...[
                Positioned.fill(
                  child: GestureDetector(
                    key: const Key('calendar-dismiss-area'),
                    onTap: () => setState(() => _calendarOpen = false),
                    behavior: HitTestBehavior.opaque,
                    child: const SizedBox.expand(),
                  ),
                ),
                _calendarOverlay(mobile, width, bottomInset),
              ],
            ],
          ]),
        ),
      );
    }),
  );

  Widget _desktopMural() => RepaintBoundary(
    child: Image.asset(
      _wallAsset,
      key: const Key('concrete-wall-image'),
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      alignment: Alignment.center,
      filterQuality: FilterQuality.high,
      gaplessPlayback: true,
      errorBuilder: (_, _, _) => const ColoredBox(color: _wallColor),
    ),
  );

  /// A square crop contains the girl's silhouette AND the red balloon.
  /// Faded edges merge it into the natural concrete-coloured mobile canvas.
  Widget _mobileMural(double width) {
    final artHeight = math.min(500.0, width * 1.18);
    return Stack(children: [
      const Positioned.fill(child: ColoredBox(color: _wallColor)),
      Positioned(
        left: 0, right: 0,
        top: 87,
        height: artHeight,
        child: RepaintBoundary(
          child: ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (rect) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black,
                Colors.black,
                Colors.transparent,
              ],
              stops: [0, .11, .86, 1],
            ).createShader(rect),
            child: Image.asset(
              _wallAsset,
              key: const Key('concrete-wall-image'),
              width: width,
              height: artHeight,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              filterQuality: FilterQuality.high,
              gaplessPlayback: true,
              errorBuilder: (_, _, _) => const ColoredBox(color: _wallColor),
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _languageGate(bool mobile, double width, double height) => Positioned(
    top: mobile ? 38 : height * .31,
    left: mobile ? 22 : math.max(42.0, width * .06),
    right: mobile ? 16 : null,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      StencilText('LANGUAGE / ЯЗЫК',
        fontSize: mobile ? 20 : 28, wear: .5, letterSpacing: -.4),
      const SizedBox(height: 22),
      _languageChoice('ENGLISH','en',mobile),
      const SizedBox(height: 10),
      _languageChoice('РУССКИЙ','ru',mobile),
    ]),
  );

  Widget _languageChoice(String label, String lang, bool mobile) => TextButton(
    key: Key('choose-$lang'),
    onPressed: () => _chooseLanguage(lang),
    style: TextButton.styleFrom(
      foregroundColor: graffitiInk,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
    ),
    child: StencilText(label,
      fontSize: mobile ? 44 : 78,
      height: 1,
      wear: .62,
      letterSpacing: -1.7),
  );

  Widget _identityAndSwitch(bool mobile) => Stack(children: [
    Positioned(
      top: mobile ? 28 : 37,
      left: mobile ? 19 : 56,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        StencilText('VISA RUN',
          fontSize: mobile ? 24 : 37,
          letterSpacing: -1.4, height: 1, wear: .68),
        if (!mobile) Padding(
          padding: const EdgeInsets.only(top: 7),
          child: Text(ru ? 'БЕЗ ГРАНИЦ. БОЛЬШЕ СВОБОДЫ.' :
              'CROSS BORDERS. FIND FREEDOM.',
            style: const TextStyle(fontSize: 10, letterSpacing: 1.3,
              color: Color(0xff424244), fontWeight: FontWeight.w800)),
        ),
      ]),
    ),
    Positioned(
      top: mobile ? 16 : 30,
      right: mobile ? 16 : 48,
      child: LiquidGlass(
        radius: 25,
        blur: mobile ? 4 : 7,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _langButton('EN','en'),
          const Text('/', style: TextStyle(color: Color(0xff48494a))),
          _langButton('RU','ru'),
        ]),
      ),
    ),
  ]);

  Widget _langButton(String label,String language) => TextButton(
    key: Key('switch-$language'),
    onPressed: () => _chooseLanguage(language),
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xff242526),
      minimumSize: const Size(39, 44),
      padding: const EdgeInsets.symmetric(horizontal: 3),
      shape: const RoundedRectangleBorder(),
    ),
    child: Text(label,
      style: TextStyle(
        color: const Color(0xff242526),
        fontSize: 12,
        fontWeight: _language == language ? FontWeight.w900 : FontWeight.w600,
        decoration: _language == language ? TextDecoration.underline : null,
        decorationThickness: 2.1,
      ),
    ),
  );

  Widget _actions(bool mobile,double bottomInset) {
    final buttonLabel = ru ? 'ЗАБРОНИРОВАТЬ' : 'BOOK VISA RUN';
    if (mobile) {
      return Stack(children: [
        Positioned(
          left: 12,right: 12,bottom: 100 + bottomInset,
          child: Row(mainAxisAlignment: MainAxisAlignment.center,children: [
            GlassAction(
              key: const Key('contact-whatsapp'),
              label: 'WhatsApp',
              compact: true,blur: 4,
              icon: Icons.chat_bubble_outline,
              onPressed: () => _contact('WhatsApp'),
            ),
            const SizedBox(width: 9),
            GlassAction(
              key: const Key('contact-telegram'),
              label: 'Telegram',
              compact: true,blur: 4,
              icon: Icons.send_outlined,
              onPressed: () => _contact('Telegram'),
            ),
          ]),
        ),
        Positioned(
          left: 32,right: 32,bottom: 28 + bottomInset,
          child: Center(
            child: GlassAction(
              key: const Key('open-booking'),
              label: buttonLabel,
              icon: Icons.calendar_month_outlined,
              emphasis: true,blur: 6,
              onPressed: () => setState(() => _calendarOpen = !_calendarOpen),
            ),
          ),
        ),
      ]);
    }
    return Stack(children: [
      Positioned(
        left: 53,bottom: 57,
        child: Row(mainAxisSize: MainAxisSize.min,children: [
          GlassAction(
            key: const Key('contact-whatsapp'),
            label: 'WhatsApp',
            compact: true,icon: Icons.chat_bubble_outline,
            onPressed: () => _contact('WhatsApp'),
          ),
          const SizedBox(width: 12),
          GlassAction(
            key: const Key('contact-telegram'),
            label: 'Telegram',
            compact: true,icon: Icons.send_outlined,
            onPressed: () => _contact('Telegram'),
          ),
        ]),
      ),
      Positioned(
        right: 56,bottom: 53,
        child: GlassAction(
          key: const Key('open-booking'),
          label: buttonLabel,
          emphasis: true,icon: Icons.calendar_month_outlined,
          onPressed: () => setState(() => _calendarOpen = !_calendarOpen),
        ),
      ),
    ]);
  }

  Widget _calendarOverlay(bool mobile,double width,double bottomInset) {
    if (mobile) {
      final panelWidth = math.min(width - 24, 370.0);
      return Positioned(
        bottom: 163 + bottomInset,
        left: (width - panelWidth) / 2,
        child: GlassBookingCalendar(
          key: const Key('booking-calendar'),
          language: _language!,
          mobile: true,
          width: panelWidth,
          onClose: () => setState(() => _calendarOpen = false),
          onBook: _book,
        ),
      );
    }
    return Positioned(
      right: 51,bottom: 123,
      child: GlassBookingCalendar(
        key: const Key('booking-calendar'),
        language: _language!,
        width: 352,
        onClose: () => setState(() => _calendarOpen = false),
        onBook: _book,
      ),
    );
  }
}
