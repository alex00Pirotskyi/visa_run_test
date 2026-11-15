import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'graffiti_widgets.dart';
import 'transparent_stencil_button.dart';

/// A locally interactive booking calendar, painted on the same wall.
class GraffitiBookingCalendar extends StatefulWidget {
  const GraffitiBookingCalendar({
    super.key,
    required this.language,
    required this.onBook,
    this.width = 306,
  });
  final String language;
  final ValueChanged<DateTime?> onBook;
  final double width;

  @override
  State<GraffitiBookingCalendar> createState() => _GraffitiBookingCalendarState();
}

class _GraffitiBookingCalendarState extends State<GraffitiBookingCalendar> {
  late DateTime _page;
  DateTime? _selected;
  bool get _ru => widget.language == 'ru';

  static const _enMonths = [
    'JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'
  ];
  static const _ruMonths = [
    'ЯНВ','ФЕВ','МАР','АПР','МАЙ','ИЮН','ИЮЛ','АВГ','СЕН','ОКТ','НОЯ','ДЕК'
  ];
  static const _enDays = ['M','T','W','T','F','S','S'];
  static const _ruDays = ['П','В','С','Ч','П','С','В'];

  String _monthLabel(DateTime d) =>
      '${(_ru ? _ruMonths : _enMonths)[d.month - 1]} ${d.year}';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _page = DateTime(now.year, now.month);
  }

  void _changeMonth(int delta) {
    final next = DateTime(_page.year, _page.month + delta);
    final now = DateTime.now();
    final first = DateTime(now.year, now.month);
    final last = DateTime(now.year, now.month + 12);
    if (next.isBefore(first) || next.isAfter(last)) return;
    setState(() {
      _page = next;
      if (_selected != null &&
          (_selected!.month != _page.month || _selected!.year != _page.year)) {
        _selected = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final startDay = _page.weekday - 1;
    final count = DateTime(_page.year, _page.month + 1, 0).day;
    final dateFloor = DateTime(today.year, today.month, today.day);
    return SizedBox(
      width: widget.width,
      child: CustomPaint(
        painter: const _CalendarSprayFrame(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 14, 15, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StencilText(
                'VISA RUN',
                fontSize: widget.width < 300 ? 30 : 34,
                height: .97,
                letterSpacing: -1.4,
                wear: .58,
              ),
              const SizedBox(height: 4),
              Text(
                _ru ? 'ВЫБЕРИ ДАТУ ПОЕЗДКИ' : 'PICK YOUR RUN DATE',
                style: const TextStyle(
                  color: graffitiInk,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _arrow('calendar-prev-month', Icons.chevron_left, -1),
                  Text(
                    _monthLabel(_page),
                    key: const Key('calendar-month-label'),
                    style: const TextStyle(
                      color: graffitiInk,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  _arrow('calendar-next-month', Icons.chevron_right, 1),
                ],
              ),
              const SizedBox(height: 4),
              Row(children: [
                for (final name in (_ru ? _ruDays : _enDays))
                  Expanded(child: Center(
                    child: Text(name,
                      style: const TextStyle(
                        color: graffitiInk,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  )),
              ]),
              const SizedBox(height: 3),
              GridView.count(
                crossAxisCount: 7,
                childAspectRatio: 1.12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [
                  for (var index = 0; index < 42; index++)
                    _day(index, startDay, count, dateFloor),
                ],
              ),
              const SizedBox(height: 4),
              Align(
                child: TransparentStencilButton(
                  key: const Key('calendar-book'),
                  label: _ru ? 'ЗАБРОНИРОВАТЬ' : 'BOOK VISA RUN',
                  compact: true,
                  width: math.min(220, widget.width - 42),
                  onPressed: () => widget.onBook(_selected),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _arrow(String key, IconData icon, int delta) => IconButton(
    key: Key(key),
    onPressed: () => _changeMonth(delta),
    constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
    padding: EdgeInsets.zero,
    icon: Icon(icon, color: graffitiInk),
  );

  Widget _day(int index, int start, int total, DateTime floor) {
    final day = index - start + 1;
    if (day < 1 || day > total) return const SizedBox.shrink();
    final date = DateTime(_page.year, _page.month, day);
    final available = !date.isBefore(floor);
    final selected = _selected != null &&
        _selected!.year == date.year &&
        _selected!.month == date.month &&
        _selected!.day == date.day;
    return Semantics(
      label: '$day ${_monthLabel(date)}',
      selected: selected,
      enabled: available,
      button: true,
      child: InkWell(
        key: Key('calendar-day-$day'),
        onTap: available ? () => setState(() => _selected = date) : null,
        child: Center(
          child: Container(
            width: 29, height: 27,
            alignment: Alignment.center,
            decoration: selected
                ? BoxDecoration(
                    border: Border.all(color: graffitiInk, width: 1.7),
                  )
                : null,
            child: Text('$day', style: TextStyle(
              color: graffitiInk.withValues(
                alpha: available ? .96 : .24,
              ),
              fontSize: 12,
              fontWeight: FontWeight.w900,
            )),
          ),
        ),
      ),
    );
  }
}

/// The center stays transparent; it is a stenciled frame, not a floating card.
class _CalendarSprayFrame extends CustomPainter {
  const _CalendarSprayFrame();

  @override
  void paint(Canvas canvas, Size size) {
    final border = Paint()
      ..color = graffitiInk.withValues(alpha: .70)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7;
    final path = Path()
      ..moveTo(3, 2)
      ..lineTo(size.width * .4, 2.6)
      ..lineTo(size.width - 2, 2)
      ..lineTo(size.width - 3, size.height - 8)
      ..lineTo(size.width * .68, size.height - 6)
      ..lineTo(2, size.height - 9)
      ..close();
    canvas.drawPath(path, border);
    final drip = Paint()
      ..color = graffitiInk.withValues(alpha: .72)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (final x in [size.width * .16, size.width * .87]) {
      canvas.drawLine(Offset(x, size.height - 8),
          Offset(x, size.height - 3), drip);
    }
    final rng = math.Random(111);
    final aerosol = Paint()..color = graffitiInk.withValues(alpha: .17);
    for (var i = 0; i < 25; i++) {
      final x = rng.nextBool() ? rng.nextDouble() * 5 :
          size.width - rng.nextDouble() * 5;
      final y = rng.nextDouble() * size.height;
      canvas.drawCircle(
          Offset(x, y), .35 + rng.nextDouble() * .75, aerosol);
    }
  }

  @override
  bool shouldRepaint(covariant _CalendarSprayFrame old) => false;
}
