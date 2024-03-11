import 'package:flutter/cupertino.dart';
import 'package:kkb/assets/icons.dart';
import 'package:kkb/model/budget.dart';
import 'package:provider/provider.dart';
import '../services/database_helper.dart';

import '../model/app_state_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<Budget> budgets = [];
  var inputBudget = 0;

  final TextEditingController _controller = TextEditingController();

  void getBudgetData() async {
    final DateTime now = DateTime.now();

    final budgetInfo =
        await DatabaseHelper.getBudgetByMonth(now.year, now.month);

    setState(() {
      budgets = budgetInfo;
    });
  }

  @override
  void initState() {
    super.initState();
    getBudgetData();
  }

  int get totalBudget {
    if (budgets.isEmpty) {
      return 0;
    }

    return budgets
        .firstWhere((element) => element.category.name == "All")
        .amount;
  }

  void onChangeTotalBudget() async {
    // Invalid or same value
    if (inputBudget <= 0 || inputBudget == totalBudget) {
      return;
    }

    final DateTime now = DateTime.now();
    // TODO: change this part
    await DatabaseHelper.insertBudget(inputBudget, 5, now.year, now.month);

    getBudgetData();
    setState(() {
      inputBudget = 0;
    });
    _resetInput();
  }

  void _resetInput() {
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Profile'),
      ),
      child: Consumer<AppStateModel>(
        builder: (context, model, child) {
          return CustomScrollView(
            slivers: [
              SliverSafeArea(
                top: false,
                minimum: const EdgeInsets.only(top: 50),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      CupertinoListSection.insetGrouped(
                        children: [
                          SafeArea(
                            top: false,
                            bottom: false,
                            minimum: const EdgeInsets.only(
                              left: 0,
                              top: 8,
                              bottom: 8,
                              right: 8,
                            ),
                            child: Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(15.0),
                                  child: Icon(
                                    iconProfile,
                                    size: 40,
                                  ),
                                ),
                                Text(
                                  'John Doe',
                                  style: CupertinoTheme.of(context)
                                      .textTheme
                                      .navTitleTextStyle,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      CupertinoListSection.insetGrouped(
                        header: const Text('My Budget'),
                        children: [
                          SafeArea(
                            top: false,
                            bottom: false,
                            minimum: const EdgeInsets.only(
                              left: 0,
                              top: 8,
                              bottom: 8,
                              right: 8,
                            ),
                            child: CupertinoTextField.borderless(
                              prefix: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 13),
                                child: Icon(
                                  iconEdit,
                                  size: 28,
                                ),
                              ),
                              clearButtonMode: OverlayVisibilityMode.editing,
                              placeholder: '$totalBudget',
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  inputBudget = int.tryParse(value) ?? 0;
                                });
                              },
                              controller: _controller,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CupertinoButton.filled(
                              onPressed: onChangeTotalBudget,
                              child: const Text('Set Budget')),
                        ],
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
