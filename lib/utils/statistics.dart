import 'package:kkb/model/statistic.dart';
import 'package:kkb/model/spending_record.dart';
import 'package:kkb/controllers/records_controller.dart';
import 'package:kkb/controllers/category_controller.dart';
import 'format.dart';

List<TrendData> getTrendData(
  List<SpendingRecord>? records,
  int year,
  int month,
) {
  if (records == null) {
    return [];
  }

  List<TrendData> trends = [];

  // Records of current month
  List<SpendingRecord> currentRecords =
      RecordsController.filterByMonth(records, [DateTime(year, month, 1)]);

  // Records of last month
  int previousYear = month == 1 ? year - 1 : year;
  int previousMonth = month == 1 ? 12 : month - 1;
  List<SpendingRecord> previousRecords = RecordsController.filterByMonth(
      records, [DateTime(previousYear, previousMonth, 1)]);

  int categoryNum = CategoryController.getCategoryCount();

  // Category spending amount of each month
  List<int> amountByCategory = List.generate(categoryNum, (index) => 0);
  List<int> previousAmountByCategory = List.generate(categoryNum, (index) => 0);

  for (int i = 0; i < currentRecords.length; i++) {
    int categoryId = currentRecords[i].category.index;
    amountByCategory[categoryId] += currentRecords[i].amount;
  }

  for (int i = 0; i < previousRecords.length; i++) {
    int categoryId = previousRecords[i].category.index;
    previousAmountByCategory[categoryId] += previousRecords[i].amount;
  }

  // Compute trends
  for (int i = 0; i < categoryNum; i++) {
    if (CategoryController.getCategory(i).name == 'All' ||
        amountByCategory[i] == 0) {
      continue;
    }

    // change ratio = (curr - prev) / prev
    double ratio = previousAmountByCategory[i] > 0
        ? (amountByCategory[i] - previousAmountByCategory[i]) /
            previousAmountByCategory[i]
        : 0;
    bool isNew = previousAmountByCategory[i] == 0;

    trends.add(TrendData(
      category: CategoryController.getCategory(i),
      ratio: ratio,
      diff: amountByCategory[i] - previousAmountByCategory[i],
      isNew: isNew,
    ));
  }

  // Sort order: new, ratio (absolute value) from high to low
  trends.sort((a, b) {
    if (a.isNew && !b.isNew) return -1;
    if (!a.isNew && b.isNew) return 1;

    return b.ratio.abs().compareTo(a.ratio.abs());
  });

  return trends;
}

String getTrendDiffStr(int diff, bool withFlag) {
  if (diff > 0) {
    return withFlag
        ? '+¥${formatNumberWithCommas(diff)}'
        : '¥${formatNumberWithCommas(diff)}';
  }

  if (diff < 0) {
    return withFlag
        ? '-¥${formatNumberWithCommas(diff.abs())}'
        : '¥${formatNumberWithCommas(diff.abs())}';
  }

  return '--';
}

String getTrendRatioStr(double ratio) {
  if (ratio > 0) return '+${(ratio * 100).toStringAsFixed(1)}%';

  if (ratio < 0) return '${(ratio * 100).toStringAsFixed(1)}%';

  return '--';
}
