import 'package:flutter/cupertino.dart';

class DatePicker extends StatelessWidget {
  const DatePicker({
    required this.initialDate,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  final DateTime initialDate;
  final void Function(DateTime) onChanged;

  @override
  Widget build(BuildContext context) {
    return CupertinoDatePicker(
      initialDateTime: initialDate,
      mode: CupertinoDatePickerMode.date,
      use24hFormat: true,
      // This shows day of week alongside day of month
      showDayOfWeek: true,
      // This is called when the user changes the date.
      onDateTimeChanged: onChanged,
    );
  }
}
