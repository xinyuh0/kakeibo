import 'package:cupertino_modal_sheet/cupertino_modal_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../model/app_state_model.dart';
import '../model/spending_record.dart';
import '../services/database_helper.dart';
import '../controllers/records_controller.dart';
import '../assets/icons.dart';
import '../assets/colors.dart';
import '../pages/record_info_page.dart';
import 'new_record_page.dart';

const _kItemExtent = 32.0;

class RecordsPage extends StatefulWidget {
  const RecordsPage({super.key});

  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  late List<SpendingRecord> _records;
  var _isLoading = true;

  Group _group = Group.date;
  Sort _sort = Sort.dateDesc;
  Filter _filter = Filter.none;
  dynamic _filterValue;

  _RecordsPageState();

  // Gets records from the database through DatabaseHelper
  void _refreshRecords() async {
    final data = await DatabaseHelper.getRecords();
    setState(() {
      _records = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshRecords();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: Consumer<AppStateModel>(
        builder: (context, model, child) {
          return CustomScrollView(
            slivers: [
              CupertinoSliverNavigationBar(
                largeTitle: const Text('Records'),
                border: const Border(
                  top: BorderSide.none,
                  bottom: BorderSide.none,
                  left: BorderSide.none,
                  right: BorderSide.none,
                ),
                trailing: CupertinoButton(
                  child: const Icon(iconAdd),
                  onPressed: () => Navigator.of(context)
                      .push(CupertinoModalSheetRoute(
                          builder: (context) => const NewRecordPage()))
                      .then((value) => setState(
                            () {
                              _refreshRecords();
                            },
                          )),
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
                      : Column(children: [
                          _buildGroupSelector(),
                          _buildSearchBar(),
                          ..._buildRecordList(_records)
                        ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildRecordList(List<SpendingRecord> records) {
    List<CupertinoListSection> recordList = [];
    Map<String, List<SpendingRecord>> sortedMap;

    records = RecordsController.filterRecordsBy(_filter, records, _filterValue);

    if (records.isEmpty) {
      return [];
    }

    if (_group == Group.date) {
      sortedMap = Map.fromEntries(
          RecordsController.groupRecordsBy(_group, records).entries.toList()
            ..sort((e1, e2) => e2.value[0].date.compareTo(e1.value[0].date)));
    } else if (_group == Group.category) {
      sortedMap = Map.fromEntries(
          RecordsController.groupRecordsBy(_group, records).entries.toList()
            ..sort((e1, e2) => e2.value.length.compareTo(e1.value.length)));
    } else {
      sortedMap = RecordsController.groupRecordsBy(_group, records);
    }

    // Divides the records into smaller lists and creates a RecordList for every list in map and adds to widgets
    sortedMap.forEach(
      (k, v) => recordList.add(
        CupertinoListSection.insetGrouped(
          header: k == '' ? null : Text(k),
          children: RecordsController.sortRecordsBy(_sort, v)
              .map(
                (record) => SafeArea(
                  top: false,
                  bottom: false,
                  child: CupertinoListTile.notched(
                      padding: const EdgeInsets.all(10),
                      leading:
                          Icon(record.iconData, size: 26, color: record.color),
                      title: Text('¥${record.amountStr}'),
                      subtitle: Text(record.name),
                      trailing:
                          const Icon(iconExpand, size: 20, color: systemGrey2),
                      onTap: () {
                        Navigator.of(context).push(CupertinoModalSheetRoute(
                          builder: (context) {
                            return RecordInfoPage(record: record);
                          },
                        )).then(
                          (value) => _refreshRecords(),
                        );
                      }),
                ),
              )
              .toList(),
        ),
      ),
    );

    return recordList;
  }

  Widget _buildGroupSelector() => Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, top: 10, bottom: 5),
              child: CupertinoSlidingSegmentedControl<Group>(
                backgroundColor: backgroundDark,
                groupValue: _group,
                onValueChanged: (Group? value) {
                  if (value != null) {
                    setState(() {
                      _group = value;
                    });
                  }
                },
                children: <Group, Widget>{
                  Group.none: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(Group.none.name),
                  ),
                  Group.date: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(Group.date.name),
                  ),
                  Group.category: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(Group.category.name),
                  ),
                },
              ),
            ),
          )
        ],
      );

  Widget _buildSearchBar() => Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 20, right: 10, top: 5, bottom: 10),
              child: CupertinoSearchTextField(
                suffixMode: OverlayVisibilityMode.never,
                onChanged: (value) {
                  if (value == '') {
                    setState(() {
                      _filter = Filter.none;
                      _filterValue = null;
                    });
                  } else {
                    setState(() {
                      _filter = Filter.name;
                      _filterValue = value;
                    });
                  }
                },
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 10, right: 20, top: 5, bottom: 10),
            child: CupertinoButton(
                child: const Icon(iconSort, color: systemGrey2),
                onPressed: () async {
                  await showCupertinoModalPopup(
                      context: context, builder: _showSortPicker);
                  setState(() {});
                }),
          ),
        ],
      );

  Widget _showSortPicker(BuildContext context) => StatefulBuilder(
      builder: (context, setState) => Container(
          height: 216,
          padding: const EdgeInsets.only(top: 6.0),
          // The Bottom margin is provided to align the popup above the system
          // navigation bar.
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          // Provide a background color for the popup.
          color: CupertinoColors.systemBackground.resolveFrom(context),
          // Use a SafeArea widget to avoid system overlaps.
          child: SafeArea(
            top: false,
            child: CupertinoPicker(
                magnification: 1.22,
                squeeze: 1.2,
                useMagnifier: true,
                itemExtent: _kItemExtent,
                scrollController:
                    FixedExtentScrollController(initialItem: _sort.index),
                onSelectedItemChanged: (int i) {
                  setState(() {
                    _sort = Sort.values[i];
                  });
                },
                children: List<Widget>.generate(Sort.values.length, (int i) {
                  Sort s = Sort.values[i];
                  return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(s == Sort.dateAsc || s == Sort.dateDesc
                            ? iconDate
                            : iconMoney),
                        const SizedBox(width: 10),
                        Text(s.name)
                      ]);
                })),
          )));
}
