import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'graffiti_calendar.dart';
import 'graffiti_widgets.dart';
import 'transparent_stencil_button.dart';

void main() => runApp(const VisaRunApp());

/// Minimal Flutter Web landing page. A single compressed photograph is the
/// wall; all controls sit on it with transparent, stencil-painted outlines.
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

class VisaLanding extends StatefulWidget {
  const VisaLanding({super.key});

  @override
  State<VisaLanding> createState() => _VisaLandingState();
}

class _VisaLandingState extends State<VisaLanding> {
  static const _languageKey = 'visa_run_language';
  static const _backgroundAsset = 'assets/images/banksy_wall.webp';
  static const _concrete = Color(0xffedebea);

  String? _language;
  bool _ready = false;

  bool get _ru => _language == 'ru';

  @override
  void initState() {
    super.initState();
    _restoreLanguage();
  }

  Future<void> _restoreLanguage() async {
    String? language;
    try {
      final preferences = await SharedPreferences.getInstance();
      final stored = preferences.getString(_languageKey);
      if (stored == 'en' || stored == 'ru') language = stored;
    } catch (_) {
      // Private browsing can deny storage; the choice still works in memory.
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
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_languageKey, language);
    } catch (_) {
      // Preserve this tab's choice when persistent storage is blocked.
    }
  }

  void _notice(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: graffitiInk,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ));
  }

  void _book(DateTime? date) {
    if (date == null) {
      _notice(_ru
          ? 'Сначала выберите дату поездки.'
          : 'Select a travel date first.');
      return;
    }
    final chosen = [
      date.day.toString().padLeft(2, '0'),
      date.month.toString().padLeft(2, '0'),
      date.year.toString(),
    ].join('/');
    _notice(_ru
        ? 'Дата $chosen выбрана. Это демо — бронирование ещё не подключено.'
        : '$chosen selected. Demo only — booking is not connected.');
  }

  void _contact(String channel) => _notice(_ru
      ? 'Ссылка $channel ещё не настроена.'
      : '$channel contact link is not configured yet.');

  @override
  Widget build(BuildContext context) => Scaffold(
        body: LayoutBuilder(builder: (context, constraints) {
          final width = constraints.maxWidth;
          final viewportHeight = constraints.maxHeight;
          final mobile = width < 780;
          final height = mobile
              ? math.max(viewportHeight, 1090.0)
              : math.max(viewportHeight, 700.0);

          // The wall and every painted control belong to one scrollable
          // surface. The reference image never moves independently.
          return SingleChildScrollView(
            child: SizedBox(
              width: width,
              height: height,
              child: Stack(children: [
                Positioned.fill(
                  child: ColoredBox(
                    color: _concrete,
                    child: mobile
                        ? _mobileImage()
                        : _wallImage(),
                  ),
                ),
                if (!_ready)
                  const SizedBox.expand()
                else if (_language == null)
                  _languageGate(mobile, height, width)
                else if (mobile)
                  _mobileUi(width)
                else
                  _desktopUi(width, height),
              ]),
            ),
          );
        }),
      );

  /// The exact reference photograph; no shader, parallax or animation.
  Widget _wallImage() => RepaintBoundary(
        child: Image.asset(
          _backgroundAsset,
          key: const Key('concrete-wall-image'),
          fit: BoxFit.cover,
          alignment: Alignment.center,
          gaplessPlayback: true,
          filterQuality: FilterQuality.medium,
          errorBuilder: (_, _, _) => const ColoredBox(color: _concrete),
        ),
      );

  /// The portrait image is cropped thoughtfully on phones so the girl and
  /// balloon remain together below the calendar, without distorting either.
  Widget _mobileImage() => Stack(children: [
        const Positioned.fill(child: ColoredBox(color: _concrete)),
        Positioned(
          left: 0,
          right: 0,
          top: 465,
          height: 430,
          child: ClipRect(
            child: Image.asset(
              _backgroundAsset,
              key: const Key('concrete-wall-image'),
              fit: BoxFit.cover,
              alignment: Alignment.center,
              filterQuality: FilterQuality.medium,
              gaplessPlayback: true,
              errorBuilder: (_, _, _) => const ColoredBox(color: _concrete),
            ),
          ),
        ),
        // A small feathered edge merges the original concrete into a
        // matching pale area behind the calendar. No extra image needed.
        Positioned(
          top: 465,
          left: 0,
          right: 0,
          height: 70,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_concrete, _concrete.withValues(alpha: 0)],
                ),
              ),
            ),
          ),
        ),
      ]);

  Widget _languageGate(bool mobile, double height, double width) => Positioned(
        top: mobile ? 86 : height * .36,
        left: mobile ? 22 : math.max(46.0, width * .06),
        right: mobile ? 20 : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StencilText(
              'LANGUAGE / ЯЗЫК',
              fontSize: mobile ? 19 : 29,
              letterSpacing: .3,
              wear: .42,
            ),
            const SizedBox(height: 22),
            _languageChoice('ENGLISH', 'en', mobile),
            const SizedBox(height: 9),
            _languageChoice('РУССКИЙ', 'ru', mobile),
          ],
        ),
      );

  Widget _languageChoice(String label, String code, bool mobile) => TextButton(
        key: Key('choose-$code'),
        onPressed: () => _chooseLanguage(code),
        style: TextButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: graffitiInk,
          overlayColor: graffitiInk.withValues(alpha: .05),
          shape: const RoundedRectangleBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
        ),
        child: StencilText(
          label,
          fontSize: mobile ? 45 : 78,
          height: 1,
          letterSpacing: -1.5,
          wear: .5,
        ),
      );

  Widget _languageSwitch() => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _languageToggle('EN', 'en'),
          const Text('/', style: TextStyle(
            color: graffitiInk, fontWeight: FontWeight.w900)),
          _languageToggle('RU', 'ru'),
        ],
      );

  Widget _languageToggle(String label, String code) => TextButton(
        key: Key('switch-$code'),
        onPressed: () => _chooseLanguage(code),
        style: TextButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: graffitiInk,
          padding: const EdgeInsets.symmetric(horizontal: 5),
          minimumSize: const Size(36, 44),
          shape: const RoundedRectangleBorder(),
        ),
        child: Text(label, style: TextStyle(
          color: graffitiInk,
          fontSize: 13,
          fontWeight: _language == code ? FontWeight.w900 : FontWeight.w600,
          decoration: _language == code ? TextDecoration.underline : null,
          decorationThickness: 2,
        )),
      );

  Widget _calendar(double width) => Transform.rotate(
        angle: -.052,
        alignment: Alignment.center,
        child: GraffitiBookingCalendar(
          width: width,
          language: _language!,
          onBook: _book,
        ),
      );

  Widget _socialButtons({required bool mobile}) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TransparentStencilButton(
            key: const Key('contact-whatsapp'),
            label: 'WHATSAPP',
            compact: mobile,
            width: mobile ? 150 : 177,
            onPressed: () => _contact('WhatsApp'),
          ),
          const SizedBox(height: 9),
          TransparentStencilButton(
            key: const Key('contact-telegram'),
            label: 'TELEGRAM',
            compact: mobile,
            width: mobile ? 150 : 177,
            onPressed: () => _contact('Telegram'),
          ),
        ],
      );

  Widget _desktopUi(double width, double height) {
    final left = math.max(32.0, width * .056);
    final calendarWidth = math.min(340.0, math.max(275.0, width * .275));
    return Stack(children: [
      Positioned(top: 16, right: 32, child: _languageSwitch()),
      Positioned(top: 48, left: left, child: _calendar(calendarWidth)),
      Positioned(
        left: left + 7,
        top: math.max(485.0, height * .58),
        child: _socialButtons(mobile: false),
      ),
    ]);
  }

  Widget _mobileUi(double width) {
    final calendarWidth = math.min(292.0, width - 34);
    return Stack(children: [
      Positioned(top: 8, right: 14, child: _languageSwitch()),
      Positioned(
        top: 66,
        left: (width - calendarWidth) / 2,
        child: _calendar(calendarWidth),
      ),
      Positioned(
        top: 930,
        left: 20,
        child: _socialButtons(mobile: true),
      ),
    ]);
  }
}
