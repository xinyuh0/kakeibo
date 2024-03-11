import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

typedef VoidFunction = void Function(int, int);

class MonthPicker extends StatefulWidget {
  final VoidFunction onChange;
  final int initYear;
  final int initMonth;
  final bool showFutureMonth;

  const MonthPicker({
    super.key,
    required this.onChange,
    required this.initYear,
    required this.initMonth,
    this.showFutureMonth = true,
  });

  @override
  State<MonthPicker> createState() => _MonthPickerState();
}

class _MonthPickerState extends State<MonthPicker> {
  int _year = 1970;
  int _month = 1;

  void handleIncrease() {
    if (widget.showFutureMonth == false && isCurrentMonth) {
      return;
    }

    int newYear = (_month == 12 ? (_year + 1) : _year);
    int newMonth = (_month == 12 ? 1 : (_month + 1));

    widget.onChange(newYear, newMonth);

    setState(() {
      _year = newYear;
      _month = newMonth;
    });
  }

  void handleDecrease() {
    int newYear = (_month == 1 ? (_year - 1) : _year);
    int newMonth = (_month == 1 ? 12 : (_month - 1));

    widget.onChange(newYear, newMonth);

    setState(() {
      _year = newYear;
      _month = newMonth;
    });
  }

  bool get isCurrentMonth {
    DateTime now = DateTime.now();

    return (now.year == _year && now.month == _month);
  }

  String getFormattedDate() {
    DateTime date = DateTime(_year, _month, 1);

    return DateFormat('MMMM yyyy').format(date);
  }

  @override
  void initState() {
    super.initState();

    _year = widget.initYear;
    _month = widget.initMonth;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CupertinoButton(
          minSize: 0,
          padding: const EdgeInsets.all(0),
          onPressed: () {
            handleDecrease();
          },
          child: const Icon(CupertinoIcons.left_chevron),
        ),
        Text(
          getFormattedDate(),
          style: const TextStyle(fontSize: 18),
        ),
        CupertinoButton(
          minSize: 0,
          padding: const EdgeInsets.all(0),
          onPressed: () {
            handleIncrease();
          },
          child: Icon(
            CupertinoIcons.right_chevron,
            color: (isCurrentMonth && widget.showFutureMonth == false)
                ? CupertinoColors.systemGrey3
                : CupertinoColors.activeBlue,
          ),
        ),
      ],
    );
  }
}
