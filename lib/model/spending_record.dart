import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utils/format.dart';
import 'category.dart';

class SpendingRecord {
  const SpendingRecord({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
    required this.date,
    this.store = '',
    this.paymentMethod = '',
    this.notes = '',
    this.location = '',
  });

  final int id;
  final String name;
  final int amount;
  final Category category;
  final DateTime date;
  final String store;
  final String paymentMethod;
  final String notes;
  final String location;

  Color get color => category.color;

  Icon get icon => category.getIcon();

  IconData get iconData => category.iconData;

  String get amountStr => formatNumberWithCommas(amount);

  String dateStr(String format) => DateFormat(format).format(date);

  @override
  String toString() => '$name (id=$id)';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'category': category.index,
      'date': date.millisecondsSinceEpoch,
      'store': store,
      'payment_method': paymentMethod,
      'notes': notes,
      'location': location,
    };
  }
}
