import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:kkb/utils/format.dart';
import 'package:kkb/utils/budget.dart';

import 'package:kkb/model/budget.dart';
import 'package:kkb/model/spending_record.dart';

const TextStyle _titleTextStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
);

const TextStyle _numTextStyle = TextStyle(fontSize: 16);

class BudgetStatus extends StatelessWidget {
  final int _totalBudget;
  final int _total;
  final List<Progress> _progressList;

  static int _getTotalBudget(List<Budget>? budgetInfo) {
    DateTime now = DateTime.now();

    return getTotalBudget(budgetInfo, now.year, now.month);
  }

  static List<Progress> _getProgressList(
      List<Budget>? budgetInfo, List<SpendingRecord>? records) {
    DateTime now = DateTime.now();

    List<Progress> res =
        getProgressList(budgetInfo, records, now.year, now.month)
            .where((element) => element.budget > 0)
            .toList();

    // Sort from highest to lowest percentage
    res.sort((a, b) => b.percentage.compareTo(a.percentage));

    // res.take(3).toList().forEach((element) {
    //   print(
    //       'cat: ${element.category} percentage: ${element.percentage} budget: ${element.budget}');
    // });
    return res.take(3).toList();
  }

  static int _getTotalExpense(List<SpendingRecord>? records) {
    DateTime now = DateTime.now();

    return getTotalExpense(records, now.year, now.month);
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return formatNumber(number);
    } else {
      return formatNumberWithCommas(number);
    }
  }

  BudgetStatus(
      {Key? key, List<Budget>? budgetInfo, List<SpendingRecord>? records})
      : _totalBudget = _getTotalBudget(budgetInfo),
        _total = _getTotalExpense(records),
        _progressList = _getProgressList(budgetInfo, records),
        super(key: key);

  Widget progressChart() {
    double percent = _totalBudget == 0 ? 0.0 : min(_total / _totalBudget, 1.0);
    Color color;

    if (percent == 0.0) {
      color = const Color(0xFFE2E2E2);
    } else if (percent > 0.0 && percent < 0.5) {
      color = const Color(0xFF4BDF27);
    } else if (percent >= 0.5 && percent < 0.8) {
      color = const Color(0xFFF68908);
    } else {
      color = const Color(0xFFE21E1E);
    }

    return CircularPercentIndicator(
      percent: _totalBudget > 0 ? percent : 0,
      radius: 48,
      lineWidth: 12,
      animateFromLastPercent: true,
      circularStrokeCap: CircularStrokeCap.round,
      backgroundColor: const Color(0xFFF2F2F2),
      progressColor: color,
      center: Text(
        // Display <1% instead of 0% when percent is within (0, 0.01)
        '${percent == 0.0 ? '0' : percent >= 0.01 ? (percent * 100).toInt() : '<1'}%',
        style: TextStyle(
          fontSize: 18,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 12.0,
          bottom: 12.0,
          left: 24.0,
          right: 24.0,
        ),
        child: _progressList.isEmpty
            ? Row(
                children: [
                  progressChart(),
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          'Budget',
                          style: _titleTextStyle,
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        Text(
                          '¥${_formatNumber(_totalBudget)}',
                          style: _numTextStyle,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          'Used',
                          style: _titleTextStyle,
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        Text(
                          '¥${_formatNumber(_total)}',
                          style: _numTextStyle,
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 8),
                      progressChart(),
                      const SizedBox(width: 24),
                      Expanded(
                        child: SizedBox(
                          // 2 times of pie chart radius
                          height: 96,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: _progressList
                                .map((e) => SizedBox(
                                      height: 32,
                                      child: Row(
                                        children: [
                                          e.category.getColorIcon(size: 20.0),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: LinearPercentIndicator(
                                              percent: e.percentage,
                                              progressColor: e.category.color,
                                              backgroundColor:
                                                  const Color(0xFFF2F2F2),
                                              lineHeight: 8,
                                              barRadius:
                                                  const Radius.circular(4),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              'Budget',
                              style: _titleTextStyle,
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Text(
                              '¥${_formatNumber(_totalBudget)}',
                              style: _numTextStyle,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              'Used',
                              style: _titleTextStyle,
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Text(
                              '¥${_formatNumber(_total)}',
                              style: _numTextStyle,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
