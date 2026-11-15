import 'package:flutter/material.dart';
import 'liquid_glass.dart';

class GlassBookingCalendar extends StatefulWidget {
  const GlassBookingCalendar({super.key, required this.language,
      required this.onBook, required this.onClose, this.width = 348,
      this.mobile = false});
  final String language;
  final ValueChanged<DateTime?> onBook;
  final VoidCallback onClose;
  final double width;
  final bool mobile;
  @override State<GlassBookingCalendar> createState() => _GlassCalendarState();
}

class _GlassCalendarState extends State<GlassBookingCalendar> {
  late DateTime month;
  DateTime? selected;
  bool get ru => widget.language == 'ru';
  static const en = ['JANUARY','FEBRUARY','MARCH','APRIL','MAY','JUNE',
    'JULY','AUGUST','SEPTEMBER','OCTOBER','NOVEMBER','DECEMBER'];
  static const rus = ['ЯНВАРЬ','ФЕВРАЛЬ','МАРТ','АПРЕЛЬ','МАЙ','ИЮНЬ',
    'ИЮЛЬ','АВГУСТ','СЕНТЯБРЬ','ОКТЯБРЬ','НОЯБРЬ','ДЕКАБРЬ'];

  @override void initState() {
    super.initState();
    final now = DateTime.now();
    month = DateTime(now.year, now.month);
  }

  String labelFor(DateTime d) =>
      '${(ru ? rus : en)[d.month - 1]} ${d.year}';

  void move(int offset) {
    final date = DateTime(month.year, month.month + offset);
    final now = DateTime.now();
    if (date.isBefore(DateTime(now.year, now.month)) ||
        date.isAfter(DateTime(now.year, now.month + 12))) {
      return;
    }
    setState(() {
      month = date;
      if (selected != null &&
          (selected!.month != date.month || selected!.year != date.year)) {
        selected = null;
      }
    });
  }

  @override Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final offset = month.weekday - 1;
    final last = DateTime(month.year, month.month + 1, 0).day;
    final week = ru ? ['П','В','С','Ч','П','С','В'] : ['M','T','W','T','F','S','S'];
    return SizedBox(
      width: widget.width,
      child: LiquidGlass(
        radius: 28, blur: widget.mobile ? 6 : 12, strong: true,
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 19),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              Expanded(child: Text(ru ? 'ВЫБЕРИ ДАТУ' : 'PICK A DATE',
                style: const TextStyle(fontWeight: FontWeight.w900,
                  letterSpacing: 1.2, color: Color(0xff202021),fontSize: 12))),
              IconButton(key: const Key('calendar-close'), onPressed: widget.onClose,
                tooltip: ru ? 'Закрыть' : 'Close calendar',
                constraints: const BoxConstraints(minWidth: 40,minHeight: 40),
                padding: EdgeInsets.zero,icon: const Icon(Icons.close,size: 21)),
            ]),
            const SizedBox(height: 3),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
              IconButton(key: const Key('calendar-prev-month'),onPressed: () => move(-1),
                icon: const Icon(Icons.chevron_left),padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40,minHeight: 40)),
              Expanded(child: Center(child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(labelFor(month),
                  key: const Key('calendar-month-label'),
                  maxLines: 1,
                  style: const TextStyle(fontSize: 12,letterSpacing: .3,
                    color: Color(0xff252525),fontWeight: FontWeight.w800)),
              ))),
              IconButton(key: const Key('calendar-next-month'),onPressed: () => move(1),
                icon: const Icon(Icons.chevron_right),padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40,minHeight: 40)),
            ]),
            const SizedBox(height: 5),
            Row(children: [
              for (final day in week)
                Expanded(child: Center(child: Text(day,
                  style: const TextStyle(color: Color(0xff606164),fontSize: 10,
                    fontWeight: FontWeight.w800)))),
            ]),
            const SizedBox(height: 5),
            GridView.count(
              crossAxisCount: 7,childAspectRatio: 1.05,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,padding: EdgeInsets.zero,
              children: [for (var i = 0; i < 42; i++) cell(i - offset + 1,last,today)],
            ),
            const SizedBox(height: 8),
            SizedBox(height: 48,child: FilledButton(
              key: const Key('calendar-book'),
              onPressed: () => widget.onBook(selected),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xff252526),foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
              child: Text(ru ? 'ПРОДОЛЖИТЬ' : 'CONTINUE',
                style: const TextStyle(fontSize: 12,fontWeight: FontWeight.w900,
                  letterSpacing: .8)),
            )),
          ],
        ),
      ),
    );
  }

  Widget cell(int day,int last,DateTime today) {
    if (day < 1 || day > last) return const SizedBox.shrink();
    final d = DateTime(month.year,month.month,day);
    final available = !d.isBefore(today);
    final chosen = selected != null && d.year == selected!.year &&
        d.month == selected!.month && d.day == selected!.day;
    return Semantics(
      label: '$day ${labelFor(d)}',selected: chosen,button: true,enabled: available,
      child: InkWell(
        key: Key('calendar-day-$day'),onTap: available ? () =>
            setState(() => selected = d) : null,
        borderRadius: BorderRadius.circular(28),
        child: Center(child: Container(
          width: 32,height: 32,alignment: Alignment.center,
          decoration: chosen ? const BoxDecoration(
            color: Color(0xff252526),shape: BoxShape.circle) : null,
          child: Text('$day',style: TextStyle(fontSize: 12,
            fontWeight: chosen ? FontWeight.w900 : FontWeight.w700,
            color: chosen ? Colors.white :
                const Color(0xff202021).withValues(alpha: available ? .95 : .25))),
        )),
      ),
    );
  }
}
