import 'package:cupertino_modal_sheet/cupertino_modal_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:kkb/model/statistic.dart';
import 'package:kkb/utils/statistics.dart';
import 'package:provider/provider.dart';

import '../assets/icons.dart';
import '../assets/colors.dart';
import '../controllers/records_controller.dart';
import '../model/app_state_model.dart';
import '../model/spending_record.dart';
import '../model/budget.dart';
import '../services/database_helper.dart';
import '../widgets/budget_status.dart';
import 'new_record_page.dart';
import 'profile_page.dart';
import 'record_info_page.dart';
import 'records_page.dart';
import 'budget_detail.dart';
import 'statistic_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<SpendingRecord> _records;
  late List<Budget> _budgetInfo;
  late List<TrendData> _trends;
  var _isLoading = true;

  void _fetchData() async {
    final DateTime now = DateTime.now();

    // Fetch records
    final recordData = await DatabaseHelper.getRecords();
    // Fetch budget of current month
    final budgetInfo =
        await DatabaseHelper.getBudgetByMonth(now.year, now.month);

    setState(() {
      _records = recordData;
      _budgetInfo = budgetInfo;
      _trends = getTrendData(recordData, now.year, now.month);
      _isLoading = false;
    });
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
      child: Consumer<AppStateModel>(
        builder: (context, model, child) {
          return CustomScrollView(
            slivers: [
              CupertinoSliverNavigationBar(
                largeTitle: const Text('KKB'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CupertinoButton(
                      child: const Icon(iconAdd),
                      onPressed: () => Navigator.of(context)
                          .push(CupertinoModalSheetRoute(
                              builder: (context) => const NewRecordPage()))
                          .then((value) => setState(
                                () {
                                  _fetchData();
                                },
                              )),
                    ),
                    const SizedBox(width: 2),
                    CupertinoButton(
                      child: const Icon(iconProfile),
                      onPressed: () => showCupertinoModalSheet(
                          context: context,
                          builder: (context) => const ProfilePage()).then(
                        (value) => setState(
                          () {
                            _fetchData();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SliverSafeArea(
                top: false,
                minimum: const EdgeInsets.only(top: 0),
                sliver: SliverToBoxAdapter(
                  child: _isLoading
                      ? const Center(
                          child: CupertinoActivityIndicator(),
                        )
                      : Column(
                          children: [
                            CupertinoListSection.insetGrouped(
                                header: Row(
                                  children: [
                                    const Text('Budget Status'),
                                    const Spacer(),
                                    CupertinoButton(
                                      child: Text(
                                        'More Details',
                                        style: CupertinoTheme.of(context)
                                            .textTheme
                                            .actionTextStyle,
                                      ),
                                      onPressed: () {
                                        Navigator.of(context)
                                            .push(CupertinoPageRoute(
                                          builder: (context) {
                                            return const BudgetDetailPage();
                                          },
                                        )).then((value) => setState(() {
                                                  _fetchData();
                                                }));
                                      },
                                    )
                                  ],
                                ),
                                children: [
                                  BudgetStatus(
                                    budgetInfo: _budgetInfo,
                                    records: _records,
                                  )
                                ]),
                            CupertinoListSection.insetGrouped(
                              header: Row(
                                children: [
                                  const Text('Records'),
                                  const Spacer(),
                                  CupertinoButton(
                                    child: Text(
                                      'All Records',
                                      style: CupertinoTheme.of(context)
                                          .textTheme
                                          .actionTextStyle,
                                    ),
                                    onPressed: () {
                                      Navigator.of(context)
                                          .push(CupertinoPageRoute(
                                        builder: (context) {
                                          return const RecordsPage();
                                        },
                                      )).then((value) => setState(
                                                () {
                                                  _fetchData();
                                                },
                                              ));
                                    },
                                  ),
                                ],
                              ),
                              children: RecordsController.sortRecordsBy(
                                      Sort.dateDesc, _records)
                                  .take(3)
                                  .map(
                                    (record) => SafeArea(
                                      top: false,
                                      bottom: false,
                                      child: CupertinoListTile.notched(
                                        padding: const EdgeInsets.all(10),
                                        leading: Icon(record.iconData,
                                            size: 26, color: record.color),
                                        title: Text('¥${record.amountStr}'),
                                        subtitle: Text(record.name),
                                        trailing: const Icon(iconExpand,
                                            size: 20, color: systemGrey2),
                                        onTap: () {
                                          Navigator.of(context)
                                              .push(CupertinoModalSheetRoute(
                                            builder: (context) {
                                              return RecordInfoPage(
                                                  record: record);
                                            },
                                          )).then((value) => _fetchData());
                                        },
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                            CupertinoListSection.insetGrouped(
                              header: Row(
                                children: [
                                  const Text('Trends'),
                                  const Spacer(),
                                  CupertinoButton(
                                    child: Text(
                                      'More Details',
                                      style: CupertinoTheme.of(context)
                                          .textTheme
                                          .actionTextStyle,
                                    ),
                                    onPressed: () {
                                      Navigator.of(context)
                                          .push(CupertinoPageRoute(
                                        builder: (context) {
                                          return const StatisticPage();
                                        },
                                      )).then((value) => setState(
                                                () {
                                                  _fetchData();
                                                },
                                              ));
                                    },
                                  ),
                                ],
                              ),
                              children: _trends
                                  .take(3)
                                  .map((e) => SafeArea(
                                        top: false,
                                        bottom: false,
                                        child: CupertinoListTile.notched(
                                          padding: const EdgeInsets.all(10),
                                          leading: e.category
                                              .getColorIcon(size: 26.0),
                                          title: Row(
                                            children: [
                                              if (e.diff != 0)
                                                e.diff > 0
                                                    ? const Icon(
                                                        iconUpRight,
                                                        size: 22.0,
                                                        color: CupertinoColors
                                                            .systemGreen,
                                                      )
                                                    : const Icon(
                                                        iconDownRight,
                                                        size: 22.0,
                                                        color: CupertinoColors
                                                            .systemRed,
                                                      ),
                                              Text(
                                                getTrendDiffStr(e.diff, false),
                                                style: TextStyle(
                                                  color: e.diff == 0
                                                      ? CupertinoColors.black
                                                      : e.diff > 0
                                                          ? CupertinoColors
                                                              .systemGreen
                                                          : CupertinoColors
                                                              .systemRed,
                                                ),
                                              ),
                                            ],
                                          ),
                                          trailing: Text(
                                            e.isNew
                                                ? 'New'
                                                : getTrendRatioStr(e.ratio),
                                            style: TextStyle(
                                                color: e.isNew
                                                    ? CupertinoColors.black
                                                    : e.ratio > 0
                                                        ? CupertinoColors
                                                            .systemGreen
                                                        : CupertinoColors
                                                            .systemRed),
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            )
                          ],
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
