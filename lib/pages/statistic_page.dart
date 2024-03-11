import 'dart:math';

import 'package:cupertino_modal_sheet/cupertino_modal_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:kkb/model/category.dart';
import 'package:kkb/widgets/month_picker.dart';
import 'package:kkb/assets/colors.dart';
import 'package:kkb/services/database_helper.dart';
import 'package:kkb/model/spending_record.dart';
import 'package:kkb/controllers/records_controller.dart';
import 'package:kkb/utils/format.dart';
import 'package:intl/intl.dart';
import 'package:kkb/controllers/category_controller.dart';
import 'package:kkb/model/statistic.dart';
import 'package:kkb/widgets/trend_item.dart';
import 'package:kkb/pages/chatbot_page.dart';
import 'package:kkb/model/budget.dart';
import 'package:kkb/utils/statistics.dart';

class StatisticPage extends StatefulWidget {
  const StatisticPage({super.key});

  @override
  State<StatisticPage> createState() => _StatisticPageState();
}

const subTextStyle = TextStyle(fontSize: 16);
const numberStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

class _StatisticPageState extends State<StatisticPage> {
  late List<SpendingRecord> records;
  late List<Budget> budgets;
  late List<FlSpot> lineChartData;
  late List<PieChartSectionData> pieChartData;
  late List<PieChartIndicatorData> pieChartIndicatorData;
  late List<TrendData> trendData;
  int _year = DateTime.now().year;
  int _month = DateTime.now().month;
  bool _isLoading = true;

  int getDaysInMonth(int year, int month) {
    int nextMonth = month == 12 ? 1 : month + 1;
    int nextYear = month == 12 ? year + 1 : year;

    DateTime nextMonthFirstDay = DateTime(nextYear, nextMonth, 1);
    DateTime lastDayOfMonth = nextMonthFirstDay.subtract(
      const Duration(days: 1),
    );

    return lastDayOfMonth.day;
  }

  List<FlSpot> getLineChartData(List<SpendingRecord>? records) {
    final numsOfDays = getDaysInMonth(_year, _month);

    if (records == null) {
      return [];
    }

    List<SpendingRecord> filteredRecords =
        RecordsController.filterByMonth(records, [DateTime(_year, _month, 1)]);
    RecordsController.sortByDateDesc(filteredRecords);

    List<FlSpot> lineData = [];
    for (int i = 1; i <= numsOfDays; i++) {
      int spending = RecordsController.filterByDay(
              filteredRecords, [DateTime(_year, _month, i)])
          .fold(0, (previousValue, element) => previousValue + element.amount);

      lineData.add(FlSpot(i.toDouble(), spending.toDouble()));
    }

    return lineData;
  }

  Map<String, dynamic> getPieChartData(List<SpendingRecord>? records) {
    if (records == null) {
      return {
        'data': [],
        'indicator': [],
      };
    }

    List<SpendingRecord> filteredRecords =
        RecordsController.filterByMonth(records, [DateTime(_year, _month, 1)]);

    // Compute total spendings of each category, amountByCategory[i] -> amount of category with index 'i'
    int categoryNum = CategoryController.getCategoryCount();
    List<int> amountByCategory = List.generate(categoryNum, (index) => 0);

    for (int i = 0; i < filteredRecords.length; i++) {
      int categoryId = filteredRecords[i].category.index;
      amountByCategory[categoryId] += filteredRecords[i].amount;
    }

    // Generate pie chart data
    List<PieChartSectionData> pieData = [];
    List<PieChartIndicatorData> indicatorData = [];
    List<Category> categories = CategoryController.getCategories();
    int sum = amountByCategory.fold(
        0, (previousValue, element) => previousValue + element);

    for (int i = 0; i < categories.length; i++) {
      if (amountByCategory[i] > 0) {
        double ratio = amountByCategory[i] / sum;

        pieData.add(PieChartSectionData(
          color: categories[i].color.withOpacity(1),
          value: amountByCategory[i].toDouble(),
          // Hide title if ratio < 0.05, because there is no enough space
          showTitle: ratio >= 0.05,
          title: '${(ratio * 100).toStringAsFixed(1)}%',
          titleStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: white,
          ),
          radius: 96,
        ));

        indicatorData.add(PieChartIndicatorData(
          category: categories[i],
          amount: amountByCategory[i],
          ratio: ratio,
        ));
      }
    }

    indicatorData.sort((a, b) => b.ratio.compareTo(a.ratio));

    return {
      'data': pieData,
      'indicator': indicatorData,
    };
  }

  void _fetchData() async {
    final recordData = await DatabaseHelper.getRecords();
    final budgetData = await DatabaseHelper.getBudgetByMonth(_year, _month);
    final result = getPieChartData(recordData);

    setState(() {
      records = recordData;
      budgets = budgetData;
      lineChartData = getLineChartData(recordData);
      pieChartData = result['data'];
      pieChartIndicatorData = result['indicator'];
      trendData = getTrendData(recordData, _year, _month);
      _isLoading = false;
    });
  }

  Widget renderTitle(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  double get totalSpending {
    if (lineChartData.isEmpty) {
      return 0;
    }

    return lineChartData.fold(
        0, (previousValue, element) => previousValue + element.y);
  }

  double get averageSpending {
    if (lineChartData.isEmpty) {
      return 0;
    }

    final double sum = lineChartData.fold(
        0, (previousValue, element) => previousValue + element.y);

    int numsOfDays = lineChartData.length;

    DateTime now = DateTime.now();
    // For current month
    if (_year == now.year && _month == now.month) {
      numsOfDays = now.day;
    }

    return (sum ~/ numsOfDays).toDouble();
  }

  double get highestSpending {
    if (lineChartData.isEmpty) {
      return 0;
    }

    return lineChartData.fold(0, (highest, data) => max(highest, data.y));
  }

  String get dateStringWithHighestSpending {
    String dateString = '';

    if (highestSpending > 0) {
      List<String> dateStrings = lineChartData
          .where((data) => data.y.toInt() == highestSpending.toInt())
          .map((e) =>
              DateFormat('d MMM').format(DateTime(_year, _month, e.x.toInt())))
          .toList();

      for (int i = 0; i < dateStrings.length; i++) {
        if (i == 0) {
          dateString += dateStrings[i];
        } else {
          dateString += ', ';
          dateString += dateStrings[i];
        }
      }
    }

    return dateString;
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return formatNumber(number);
    } else {
      return formatNumberWithCommas(number);
    }
  }

  void handleChangeMonth(int year, int month) {
    setState(() {
      _year = year;
      _month = month;

      _fetchData();
    });
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 14, color: systemGrey1);

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        meta.formattedValue,
        style: style,
      ),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 14, color: systemGrey1);

    Widget text;
    switch (value.toInt()) {
      case 5:
      case 10:
      case 15:
      case 20:
      case 25:
        text = Text('${value.toInt()}', style: style);
      case 30:
        if (lineChartData.isNotEmpty && lineChartData.length == 30) {
          text = Text('${value.toInt()}', style: style);
        } else {
          text = const Text('', style: style);
        }
      case 31:
        if (lineChartData.isNotEmpty && lineChartData.length == 31) {
          text = Text('${value.toInt()}', style: style);
        } else {
          text = const Text('', style: style);
        }
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget renderEmptyContent() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Text(
        'No records yet',
        style: TextStyle(
          fontSize: 16,
          color: systemGrey1,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: background,
      child: CustomScrollView(
        slivers: [
          const CupertinoSliverNavigationBar(
            largeTitle: Text('Statistics'),
            border: Border(
              top: BorderSide.none,
              bottom: BorderSide.none,
              left: BorderSide.none,
              right: BorderSide.none,
            ),
          ),
          SliverSafeArea(
            top: false,
            minimum: const EdgeInsets.all(0),
            sliver: SliverToBoxAdapter(
              child: _isLoading
                  ? Container(
                      padding: const EdgeInsets.only(top: 24),
                      child: const CupertinoActivityIndicator(),
                    )
                  : Column(
                      children: [
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: MonthPicker(
                            onChange: handleChangeMonth,
                            initYear: _year,
                            initMonth: _month,
                            showFutureMonth: false,
                          ),
                        ),
                        CupertinoListSection.insetGrouped(
                          children: [
                            Column(
                              children: [
                                renderTitle('Daily Spendings'),
                                const SizedBox(height: 6),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        children: [
                                          const Text(
                                            'Average daily spending:',
                                            style: subTextStyle,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '¥${_formatNumber(averageSpending.toInt())}',
                                            style: numberStyle,
                                          ),
                                        ],
                                      ),
                                      Visibility(
                                        visible: highestSpending > 0,
                                        child: Row(children: [
                                          const Text(
                                            'Highest spending on ',
                                            style: subTextStyle,
                                          ),
                                          Text(
                                            dateStringWithHighestSpending,
                                            style: numberStyle,
                                          ),
                                          const Text(':', style: subTextStyle),
                                          const SizedBox(width: 6),
                                          Text(
                                            '¥${_formatNumber(highestSpending.toInt())}',
                                            style: numberStyle,
                                          ),
                                        ]),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                AspectRatio(
                                  aspectRatio: 3 / 2,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      top: 6,
                                      right: 12,
                                      left: 6,
                                      bottom: 6,
                                    ),
                                    child: LineChart(
                                      LineChartData(
                                        lineTouchData: LineTouchData(
                                          touchTooltipData:
                                              LineTouchTooltipData(
                                                  tooltipBgColor:
                                                      black.withOpacity(0.75),
                                                  getTooltipItems:
                                                      (touchedSpots) {
                                                    return touchedSpots
                                                        .map((barSpot) {
                                                      return LineTooltipItem(
                                                          '${DateFormat('MMMM, d').format(DateTime(_year, _month, barSpot.x.toInt()))}\n',
                                                          const TextStyle(
                                                            color: white,
                                                          ),
                                                          children: [
                                                            TextSpan(
                                                              text:
                                                                  '¥${_formatNumber(barSpot.y.toInt())}',
                                                              style:
                                                                  const TextStyle(
                                                                color: white,
                                                              ),
                                                            )
                                                          ]);
                                                    }).toList();
                                                  }),
                                        ),
                                        titlesData: FlTitlesData(
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              interval: 1,
                                              getTitlesWidget:
                                                  bottomTitleWidgets,
                                            ),
                                          ),
                                          rightTitles: const AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false),
                                          ),
                                          topTitles: const AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false),
                                          ),
                                          leftTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 42,
                                              getTitlesWidget: leftTitleWidgets,
                                            ),
                                          ),
                                        ),
                                        borderData: FlBorderData(
                                          show: true,
                                          border: const Border(
                                            bottom:
                                                BorderSide(color: systemGrey4),
                                            left:
                                                BorderSide(color: systemGrey4),
                                            right: BorderSide(color: transp),
                                            top: BorderSide(color: transp),
                                          ),
                                        ),
                                        lineBarsData: [
                                          LineChartBarData(
                                            spots: lineChartData,
                                            dotData: FlDotData(
                                              show: true,
                                              checkToShowDot: (spot, barData) {
                                                // Display dots for the data points of the highest spending
                                                if (highestSpending > 0) {
                                                  return spot.y >=
                                                      highestSpending;
                                                }
                                                return false;
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                renderTitle('Category Percentages'),
                                pieChartData.isEmpty
                                    ? renderEmptyContent()
                                    : AspectRatio(
                                        aspectRatio: 5 / 3,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          child: PieChart(
                                            PieChartData(
                                              sections: pieChartData,
                                              sectionsSpace: 1,
                                              centerSpaceRadius: 0,
                                            ),
                                          ),
                                        ),
                                      ),
                                Visibility(
                                  visible: pieChartIndicatorData.isNotEmpty,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 32,
                                          right: 32,
                                          bottom: 6,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Total',
                                              style: numberStyle,
                                            ),
                                            Text(
                                              '¥${formatNumberWithCommas(totalSpending.toInt())}',
                                              style: numberStyle,
                                            ),
                                          ],
                                        ),
                                      ),
                                      for (PieChartIndicatorData data
                                          in pieChartIndicatorData)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 32,
                                            right: 32,
                                            bottom: 6,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: 18,
                                                    height: 18,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          data.category.color,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    data.category.name,
                                                    style: subTextStyle,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '(¥${formatNumberWithCommas(data.amount)})',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: systemGrey1,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                '${(data.ratio * 100).toStringAsFixed(1)}%',
                                                style: numberStyle,
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                renderTitle('Trends'),
                                trendData.isEmpty
                                    ? renderEmptyContent()
                                    : Column(
                                        children: [
                                          for (TrendData data in trendData)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 32,
                                                vertical: 6,
                                              ),
                                              child: TrendItem(data: data),
                                            )
                                        ],
                                      ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        CupertinoButton.filled(
                          onPressed: () => Navigator.of(context).push(
                            CupertinoModalSheetRoute(
                              builder: (context) => ChatBotPage(
                                budgets: budgets,
                                records: RecordsController.filterByMonth(
                                  records,
                                  [DateTime(_year, _month, 1)],
                                ),
                              ),
                            ),
                          ),
                          // There is no need to refresh the page after closing the chatbot page
                          // In chatbot page, no data would be modified
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: const Text(
                            '✨Chat with Budget Assistant✨',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
            ),
          )
        ],
      ),
    );
  }
}
