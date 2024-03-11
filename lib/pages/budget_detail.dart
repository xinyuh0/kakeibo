import 'package:flutter/cupertino.dart';
import 'package:kkb/controllers/category_controller.dart';
import 'package:kkb/model/category.dart';
import 'package:kkb/utils/budget.dart';
import 'package:kkb/model/budget.dart';
import 'package:kkb/model/spending_record.dart';
import 'package:kkb/widgets/category_budget_list_item.dart';
import 'package:kkb/widgets/set_budget_modal.dart';
import 'package:kkb/services/database_helper.dart';
import 'package:kkb/widgets/month_picker.dart';

const TextStyle titleTextStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
  color: CupertinoColors.systemGrey,
);

class BudgetDetailPage extends StatefulWidget {
  const BudgetDetailPage({super.key});

  @override
  State<BudgetDetailPage> createState() => _BudgetDetailPageState();
}

class _BudgetDetailPageState extends State<BudgetDetailPage> {
  late int _totalBudget;
  late int _total;
  late List<Progress> _progressList;
  int _year = DateTime.now().year;
  int _month = DateTime.now().month;
  bool _isLoading = true;

  int _getTotalBudget(List<Budget>? budgetInfo) {
    return getTotalBudget(budgetInfo, _year, _month);
  }

  List<Progress> _getProgressList(
      List<Budget>? budgetInfo, List<SpendingRecord>? records) {
    List<Progress> res = getProgressList(budgetInfo, records, _year, _month);

    // Sort from highest to lowest percentage
    res.sort((a, b) => b.percentage.compareTo(a.percentage));

    return res.toList();
  }

  int _getTotalExpense(List<SpendingRecord>? records) {
    return getTotalExpense(records, _year, _month);
  }

  void _fetchData() async {
    // await Future.delayed(Duration(seconds: 2));

    // Fetch records
    final recordData = await DatabaseHelper.getRecords();
    // Fetch budget of current month
    final budgetInfo = await DatabaseHelper.getBudgetByMonth(_year, _month);

    setState(() {
      _totalBudget = _getTotalBudget(budgetInfo);
      _total = _getTotalExpense(recordData);
      _progressList = _getProgressList(budgetInfo, recordData);
      _isLoading = false;
    });
  }

  void handleChangeMonth(int year, int month) {
    setState(() {
      _year = year;
      _month = month;

      _fetchData();
    });
  }

  void handleChangeBudget(int newBudget, Category category) async {
    await DatabaseHelper.insertBudget(newBudget, category.index, _year, _month);
  }

  Widget renderEmptyItem() {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 4, bottom: 4),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            'Empty',
            style: TextStyle(
              fontSize: 16,
              color: CupertinoColors.systemGrey,
            ),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  List<Progress> get categoryProgressList {
    return _progressList
        .where(
            (element) => element.category.name != "All" && element.budget > 0)
        .toList();
  }

  List<Progress> get unsetProgressList {
    return _progressList
        .where(
            (element) => element.category.name != "All" && element.budget == 0)
        .toList();
  }

  Progress get totalProgress {
    return Progress(
      category: CategoryController.getCategory(
          CategoryController.getCategoryCount() - 1),
      budget: _totalBudget,
      total: _total,
    );
  }

  int get totalBudgetLowerBound {
    return _progressList
        .where((element) => element.category.name != "All")
        .fold(0, (previousValue, element) => previousValue + element.budget);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: CustomScrollView(
        slivers: [
          const CupertinoSliverNavigationBar(
            largeTitle: Text('Budget Detail'),
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
                          ),
                        ),
                        CupertinoListSection.insetGrouped(
                          children: [
                            Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.only(
                                    left: 12,
                                    right: 12,
                                    top: 12,
                                    bottom: 6,
                                  ),
                                  alignment: Alignment.centerLeft,
                                  child: const Text(
                                    'Total Budget',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                CategoryBudgetItem(
                                  data: totalProgress,
                                  onTap: () {
                                    showCupertinoModalPopup(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return SetBudgetDialog(
                                            data: totalProgress,
                                            lowerBound: totalBudgetLowerBound,
                                            handleChangeBudget:
                                                handleChangeBudget,
                                          );
                                        }).then((value) => setState(
                                          () {
                                            _fetchData();
                                          },
                                        ));
                                  },
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  alignment: Alignment.centerLeft,
                                  child: const Text(
                                    'Category Budget',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Column(
                                  children: categoryProgressList.isEmpty
                                      ? [renderEmptyItem()]
                                      : categoryProgressList
                                          .map((data) => CategoryBudgetItem(
                                                data: data,
                                                onTap: () {
                                                  showCupertinoModalPopup(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return SetBudgetDialog(
                                                              data: data,
                                                              lowerBound: 0,
                                                              handleChangeBudget:
                                                                  handleChangeBudget,
                                                            );
                                                          })
                                                      .then((value) => setState(
                                                            () {
                                                              _fetchData();
                                                            },
                                                          ));
                                                },
                                              ))
                                          .toList(),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  alignment: Alignment.centerLeft,
                                  child: const Text(
                                    'Not Set',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Column(
                                  children: unsetProgressList.isEmpty
                                      ? [renderEmptyItem()]
                                      : unsetProgressList
                                          .map((data) => UnsetBudgetItem(
                                                data: data,
                                                onTap: () {
                                                  showCupertinoModalPopup(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return SetBudgetDialog(
                                                              data: data,
                                                              lowerBound: 0,
                                                              handleChangeBudget:
                                                                  handleChangeBudget,
                                                            );
                                                          })
                                                      .then((value) => setState(
                                                            () {
                                                              _fetchData();
                                                            },
                                                          ));
                                                },
                                              ))
                                          .toList(),
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ],
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
