import 'package:flutter/material.dart';
import 'liquid_glass.dart';

/// Always visible: choose a date directly, then Continue within the card.
/// No initial booking CTA, route picker or hidden modal.
class GlassBookingCalendar extends StatefulWidget {
  const GlassBookingCalendar({
    super.key,
    required this.language,
    required this.onBook,
    required this.width,
    this.mobile = false,
  });

  final String language;
  final ValueChanged<DateTime?> onBook;
  final double width;
  final bool mobile;

  @override
  State<GlassBookingCalendar> createState() => _GlassBookingCalendarState();
}

class _GlassBookingCalendarState extends State<GlassBookingCalendar> {
  late DateTime shownMonth;
  DateTime? chosen;

  bool get ru => widget.language == 'ru';

  static const _english = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  static const _russian = [
    'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
    'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь',
  ];

  String monthName(DateTime d) =>
      (ru ? _russian : _english)[d.month - 1];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    shownMonth = DateTime(now.year, now.month);
  }

  void _move(int offset) {
    final next = DateTime(shownMonth.year, shownMonth.month + offset);
    final now = DateTime.now();
    final minimum = DateTime(now.year, now.month);
    final maximum = DateTime(now.year, now.month + 12);
    if (next.isBefore(minimum) || next.isAfter(maximum)) return;
    setState(() {
      shownMonth = next;
      if (chosen != null &&
          (chosen!.year != next.year || chosen!.month != next.month)) {
        chosen = null;
      }
    });
  }

  String _selectedLabel() {
    if (chosen == null) return ru ? 'Выберите дату' : 'Select your date';
    final d = chosen!;
    return ru
        ? '${d.day} ${monthName(d).toLowerCase()} ${d.year}'
        : '${monthName(d)} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final midnight = DateTime(today.year, today.month, today.day);
    final offset = shownMonth.weekday - 1;
    final lastDay = DateTime(shownMonth.year, shownMonth.month + 1, 0).day;
    final weekdays = ru
        ? ['ПН', 'ВТ', 'СР', 'ЧТ', 'ПТ', 'СБ', 'ВС']
        : ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

    return SizedBox(
      width: widget.width,
      child: LiquidGlass(
        radius: widget.mobile ? 26 : 39,
        // Let the black bus graffiti show through the panel.
        blur: widget.mobile ? 2.5 : 4.5,
        strong: true,
        tintOpacity: .75,
        padding: EdgeInsets.fromLTRB(
          widget.mobile ? 15 : 29,
          widget.mobile ? 16 : 28,
          widget.mobile ? 15 : 29,
          widget.mobile ? 18 : 27,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              _monthArrow('calendar-prev-month', Icons.chevron_left, -1),
              Expanded(child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${monthName(shownMonth)} ${shownMonth.year}',
                  key: const Key('calendar-month-label'),
                  style: TextStyle(
                    fontSize: widget.mobile ? 18 : 21,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.7,
                    color: const Color(0xff1b1c1d),
                  ),
                ),
              )),
              _monthArrow('calendar-next-month', Icons.chevron_right, 1),
            ]),
            SizedBox(height: widget.mobile ? 14 : 21),
            Row(children: [
              for (final day in weekdays)
                Expanded(child: Center(
                  child: Text(day, style: TextStyle(
                    color: const Color(0xff565759),
                    fontSize: widget.mobile ? 8 : 10,
                    fontWeight: FontWeight.w700,
                  )),
                )),
            ]),
            SizedBox(height: widget.mobile ? 8 : 13),
            GridView.count(
              crossAxisCount: 7,
              childAspectRatio: widget.mobile ? 1.07 : 1.11,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                for (var i = 0; i < 42; i++)
                  _dayTile(i - offset + 1, lastDay, midnight),
              ],
            ),
            SizedBox(height: widget.mobile ? 8 : 17),
            Divider(
              height: 1,
              color: const Color(0xff757575).withValues(alpha: .22),
            ),
            SizedBox(height: widget.mobile ? 12 : 16),
            Row(children: [
              Icon(Icons.calendar_month_outlined,
                size: widget.mobile ? 16 : 20,
                color: const Color(0xff242526)),
              const SizedBox(width: 7),
              Expanded(child: Text(
                _selectedLabel(),
                key: const Key('selected-date-label'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: widget.mobile ? 10 : 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xff222324),
                ),
              )),
              const SizedBox(width: 8),
              _continueButton(),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _monthArrow(String key, IconData icon, int direction) => Material(
    color: const Color(0x35FFFFFF),
    shape: const CircleBorder(side: BorderSide(color: Color(0x80FFFFFF))),
    child: InkWell(
      key: Key(key),
      onTap: () => _move(direction),
      customBorder: const CircleBorder(),
      child: SizedBox(
        width: widget.mobile ? 39 : 45,
        height: widget.mobile ? 39 : 45,
        child: Icon(icon, color: const Color(0xff252526), size: 22),
      ),
    ),
  );

  Widget _dayTile(int day, int maxDay, DateTime today) {
    if (day < 1 || day > maxDay) return const SizedBox.shrink();

    final date = DateTime(shownMonth.year, shownMonth.month, day);
    final available = !date.isBefore(today);
    final selected = chosen != null &&
        chosen!.year == date.year &&
        chosen!.month == date.month &&
        chosen!.day == date.day;

    return Semantics(
      label: '${date.day} ${monthName(date)} ${date.year}',
      button: true,
      enabled: available,
      selected: selected,
      child: InkWell(
        key: Key('calendar-day-$day'),
        onTap: available ? () => setState(() => chosen = date) : null,
        customBorder: const CircleBorder(),
        child: Center(
          child: Container(
            width: widget.mobile ? 32 : 38,
            height: widget.mobile ? 31 : 37,
            alignment: Alignment.center,
            decoration: selected ? BoxDecoration(
              color: const Color(0xA3FFFFFF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xEEFFFFFF), width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x26000000), blurRadius: 7,
                  offset: Offset(0, 2)),
                BoxShadow(
                  color: Color(0x99FFFFFF), blurRadius: 4,
                  offset: Offset(-2, -2)),
              ],
            ) : null,
            child: Text('$day',
              style: TextStyle(
                fontSize: widget.mobile ? 11 : 13,
                fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                color: const Color(0xff242526).withValues(
                  alpha: available ? 1 : .27,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _continueButton() => Material(
    color: Colors.transparent,
    child: InkWell(
      key: const Key('calendar-book'),
      onTap: () => widget.onBook(chosen),
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xDEFFFFFF), Color(0x7EF1F1F0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xF0FFFFFF), width: 1),
          boxShadow: const [
            BoxShadow(color: Color(0x1D000000),
              blurRadius: 9, offset: Offset(0, 3)),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: widget.mobile ? 10 : 15,
            vertical: widget.mobile ? 10 : 13,
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(ru ? 'ДАЛЕЕ' : 'Continue',
              style: TextStyle(
                color: const Color(0xff242526),
                fontSize: widget.mobile ? 10 : 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward, size: 16,
              color: Color(0xff242526)),
          ]),
        ),
      ),
    ),
  );
}
