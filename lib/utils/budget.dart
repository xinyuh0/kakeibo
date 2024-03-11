import 'package:kkb/controllers/category_controller.dart';
import 'package:kkb/model/category.dart';

import '../model/budget.dart';
import '../model/spending_record.dart';

// Get total budget of given month
// Return 0 when budget is not set
int getTotalBudget(List<Budget>? budgetInfo, int year, int month) {
  if (budgetInfo == null || budgetInfo.isEmpty) {
    return 0;
  }

  int res;
  try {
    res = budgetInfo
        .firstWhere((element) =>
            element.year == year &&
            element.month == month &&
            element.category.name == 'All')
        .amount;
  } catch (e) {
    // When there is no match, `firstWhere` will raise an exception
    res = 0;
  }

  return res;
}

// Generate progress list of given month, doesn't contain "All" category
List<Progress> getProgressList(List<Budget>? budgetInfo,
    List<SpendingRecord>? records, int year, int month) {
  final bool hasBudget = !(budgetInfo == null || budgetInfo.isEmpty);
  final bool hasRecord = !(records == null || records.isEmpty);

  List<Progress> res = [];
  for (int i = 0; i < CategoryController.getCategoryCount(); i++) {
    Category category = CategoryController.getCategory(i);

    // Skip the 'All' category
    if (category.name == 'All') {
      continue;
    }

    // Get budget of current category
    int budget;
    try {
      budget = hasBudget
          ? budgetInfo
              .firstWhere((element) =>
                  element.year == year &&
                  element.month == month &&
                  element.category.index == category.index)
              .amount
          : 0;
    } catch (e) {
      // When there is no match, `firstWhere` will raise an exception
      budget = 0;
    }

    // Get total expense of current category
    int total;
    total = hasRecord
        ? records
            .where((element) =>
                element.date.year == year &&
                element.date.month == month &&
                element.category.index == category.index)
            .fold(
              0,
              (previousValue, element) => previousValue + element.amount,
            )
        : 0;

    res.add(Progress(
      budget: budget,
      total: total,
      category: category,
    ));
  }

  return res.toList();
}

// Compute total expense of given month
int getTotalExpense(List<SpendingRecord>? records, int year, int month) {
  if (records == null) {
    return 0;
  }

  return records
      .where(
          (element) => element.date.year == year && element.date.month == month)
      .fold(0, (sum, element) => sum + element.amount);
}
