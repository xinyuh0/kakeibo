import 'package:collection/collection.dart';

import '../model/spending_record.dart';

enum Group {
  none,
  category,
  date,
}

enum Filter {
  none,
  name,
  category,
  date,
  amount
}

enum Sort {
  dateDesc,
  dateAsc,
  amountDesc,
  amountAsc,
}

//-----------------------------------------------------------------------------------------------------------------------

extension GroupString on Group {
  String get name {
    switch (this) {
      case Group.none:
        return '';
      case Group.date:
        return 'Month';
      case Group.category:
        return 'Category';
    }
  }
}

extension FilterString on Filter {
  String get name {
    switch (this) {
      case Filter.none:
        return 'No Filter';
      case Filter.name:
        return 'Name';
      case Filter.category:
        return 'Category';
      case Filter.date:
        return 'Date';
      case Filter.amount:
        return 'Amount';
    }
  }
}

extension SortString on Sort {
  String get name {
    switch (this) {
      case Sort.dateDesc:
        return 'new to old';
      case Sort.dateAsc:
        return 'old to new';
      case Sort.amountDesc:
        return 'high to low';
      case Sort.amountAsc:
        return 'low to high';
    }
  }
}

//-----------------------------------------------------------------------------------------------------------------------

class RecordsController {
  // Divides a list of records into smaller lists based on Property p
  static Map<String, List<SpendingRecord>> groupRecordsBy(
      Group g, List<SpendingRecord> records) {
    switch (g) {
      case Group.none:
        return {'': records};
      case Group.category:
        return groupByCategory(records);
      default:
        return groupByDate(records);
    }
  }

  // Divides a list of records into smaller lists by date
  static Map<String, List<SpendingRecord>> groupByDate(
      List<SpendingRecord> records) {
    return groupBy(records, (record) => record.dateStr('MMMM, yyyy'));
  }

  // Divides a list of records into smaller lists by category
  static Map<String, List<SpendingRecord>> groupByCategory(
      List<SpendingRecord> records) {
    return groupBy(records, (record) => record.category.name);
  }

  //-----------------------------------------------------------------------------------------------------------------------

  // Sorts a list of records based on Property p
  static List<SpendingRecord> sortRecordsBy(
      Sort s, List<SpendingRecord> records) {
    switch (s) {
      case Sort.amountAsc:
        return sortByAmountAsc(records);
      case Sort.amountDesc:
        return sortByAmountDesc(records);
      case Sort.dateAsc:
        return sortByDateAsc(records);
      default:
        return sortByDateDesc(records);
    }
  }

  // Sorts a list of records by amount, high to low
  static List<SpendingRecord> sortByAmountDesc(List<SpendingRecord> records) {
    records.sort((r1, r2) => r2.amount.compareTo(r1.amount));
    return records;
  }

  // Sorts a list of records by amount, low to high
  static List<SpendingRecord> sortByAmountAsc(List<SpendingRecord> records) {
    records.sort((r1, r2) => r1.amount.compareTo(r2.amount));
    return records;
  }

  // Sorts a list of records by date, new to old
  static List<SpendingRecord> sortByDateDesc(List<SpendingRecord> records) {
    records.sort((r1, r2) => r2.date.compareTo(r1.date));
    return records;
  }

  // Sorts a list of records by date, old to new
  static List<SpendingRecord> sortByDateAsc(List<SpendingRecord> records) {
    records.sort((r1, r2) => r1.date.compareTo(r2.date));
    return records;
  }

  //-----------------------------------------------------------------------------------------------------------------------

  // Filters a list of records based on Filter f
  static List<SpendingRecord> filterRecordsBy(
    Filter f,
    List<SpendingRecord> records,
    dynamic value,
  ) {
    try {
      switch (f) {
        case Filter.none:
          return records;
        case Filter.name:
          return filterByName(records, value);
        default:
          return [];
      }
    } catch (e) {
      return [];
    }
  }

    // Filters a list of records based on year
  static List<SpendingRecord> filterByYear(
      List<SpendingRecord> records, List<dynamic> dates) {
    List<SpendingRecord> r = [];
    for (DateTime date in dates) {
      r.addAll(records.where((record) => (record.date.year == date.year)));
    }
    return r;
  }

  // Filters a list of records based on month
  static List<SpendingRecord> filterByMonth(
      List<SpendingRecord> records, List<dynamic> dates) {
    List<SpendingRecord> r = [];
    for (DateTime date in dates) {
      r.addAll(records.where((record) =>
          (record.date.year == date.year) &&
          (record.date.month == date.month)));
    }
    return r;
  }

  // Filters a list of records based on day
  static List<SpendingRecord> filterByDay(
      List<SpendingRecord> records, List<dynamic> dates) {
    List<SpendingRecord> r = [];
    for (DateTime date in dates) {
      r.addAll(records.where((record) =>
          (record.date.year == date.year) &&
          (record.date.month == date.month) &&
          (record.date.day == date.day)));
    }
    return r;
  }

  // Filters a list of records based on amounts equal to amounts in amounts
  static List<SpendingRecord> filterByAmount(
      List<SpendingRecord> records, dynamic value, String op) {
    int amount = value;
    switch (op) {
      case '>':
        return records.where((record) => record.amount > amount).toList();
      case '<':
        return records.where((record) => record.amount < amount).toList();
      case '=':
        return records.where((record) => record.amount == amount).toList();
      default:
        return records;
    }
  }

  // Filters a list of records based on name
  static List<SpendingRecord> filterByName(
      List<SpendingRecord> records, String value) {
    return records
        .where(
            (record) => record.name.toLowerCase().contains(value.toLowerCase()))
        .toList();
  }
}
