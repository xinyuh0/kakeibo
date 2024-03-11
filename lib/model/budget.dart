import 'package:kkb/model/category.dart';
import 'dart:math';

class Budget {
  final int id;
  final int amount;
  final Category category;
  final int year;
  final int month;

  const Budget({
    required this.id,
    required this.amount,
    required this.category,
    required this.year,
    required this.month,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category.index,
      'year': year,
      'month': month,
    };
  }
}

class Progress {
  final Category category;
  final int budget;
  final int total;

  const Progress({
    required this.category,
    required this.budget,
    required this.total,
  });

  double get percentage {
    if (budget == 0 || total <= 0) {
      return 0.0;
    }

    return min(total / budget, 1.0);
  }
}
