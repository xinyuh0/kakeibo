import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:kkb/assets/colors.dart';
import 'package:kkb/assets/icons.dart';
import 'package:kkb/widgets/map_area.dart';
import 'package:provider/provider.dart';

import '../controllers/category_controller.dart';
import '../model/app_state_model.dart';
import '../model/category.dart';
import '../services/database_helper.dart';
import '../widgets/category_picker.dart';
import '../widgets/date_picker.dart';

// TODO: Show error message when invalid input
// TODO: Show that some values are required

class NewRecordPage extends StatefulWidget {
  const NewRecordPage({super.key});

  @override
  State<NewRecordPage> createState() => _NewRecordPageState();
}

class _NewRecordPageState extends State<NewRecordPage> {
  final GlobalKey<MapAreaState> _key = GlobalKey();

  String name = '';
  String store = '';
  String paymentMethod = '';
  String notes = '';
  String location = '';
  int amount = 0;
  Category category = CategoryController.getCategory(0);
  DateTime date = DateTime.now();

  double mapAreaHeight = 150;
  bool editMode = false;

  bool recordable = false;
  bool submitted = false;

  void updateLocation(String s) {
    setState(() {
      location = s;
    });
  }

  _NewRecordPageState();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('New Record'),
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
                          CupertinoListTile(
                            leading: const Icon(
                              iconAccountBalance,
                              size: 28,
                            ),
                            title: CupertinoTextField.borderless(
                              placeholder: 'Name',
                              onChanged: (value) => setState(() {
                                name = value;
                                _setRecordable();
                              }),
                            ),
                            additionalInfo: const Text('Required'),
                          ),
                          CupertinoListTile(
                            leading: const Icon(
                              iconStore,
                              size: 28,
                            ),
                            title: CupertinoTextField.borderless(
                              placeholder: 'Store',
                              onChanged: (value) => setState(() {
                                store = value;
                                _setRecordable();
                              }),
                            ),
                          ),
                          CupertinoListTile(
                            leading: Icon(
                              category.iconData,
                              size: 28,
                            ),
                            title: CupertinoButton(
                              padding: const EdgeInsets.only(left: 6),
                              // Display a CupertinoPicker with list of records.
                              onPressed: () => _showDialog(CategoryPicker(
                                  controller: FixedExtentScrollController(
                                    initialItem: category.index,
                                  ),
                                  onChanged: (int i) {
                                    setState(() {
                                      category =
                                          CategoryController.getCategory(i);
                                    });
                                  })),
                              child: Text(
                                category.name,
                                style: const TextStyle(color: systemGrey2),
                              ),
                            ),
                            additionalInfo: const Text('Required'),
                          ),
                          CupertinoListTile(
                            leading: const Icon(
                              iconMoney,
                              size: 28,
                            ),
                            title: CupertinoTextField.borderless(
                              keyboardType: TextInputType.number,
                              placeholder: 'Amount',
                              onChanged: (value) => setState(() {
                                amount = int.tryParse(value) ?? 0;
                                _setRecordable();
                              }),
                            ),
                            additionalInfo: const Text('Required'),
                          ),
                          CupertinoListTile(
                            leading: const Icon(
                              iconCreditCard,
                              size: 28,
                            ),
                            title: CupertinoTextField.borderless(
                              placeholder: 'Payment Method',
                              onChanged: (value) => setState(() {
                                paymentMethod = value;
                                _setRecordable();
                              }),
                            ),
                          ),
                          CupertinoListTile(
                            leading: const Icon(
                              iconDate,
                              size: 28,
                            ),
                            // Display a CupertinoDatePicker in date picker mode
                            title: CupertinoButton(
                              padding: const EdgeInsets.only(left: 6),
                              onPressed: () => _showDialog(DatePicker(
                                  initialDate: date,
                                  onChanged: (DateTime d) {
                                    setState(() {
                                      date = d;
                                    });
                                  })),
                              child: Text(
                                DateFormat('yyyy-MM-dd').format(date),
                                style: const TextStyle(color: systemGrey2),
                              ),
                            ),
                            additionalInfo: const Text('Required'),
                          ),
                          CupertinoListTile(
                            leading: const Icon(
                              iconNotes,
                              size: 28,
                            ),
                            title: CupertinoTextField.borderless(
                              placeholder: 'Notes',
                              onChanged: (value) => setState(() {
                                notes = value;
                                _setRecordable();
                              }),
                            ),
                          ),
                          const CupertinoListTile(
                            leading: Icon(
                              iconLocation,
                              size: 28,
                            ),
                            title: Text('Location'),
                          ),
                        ],
                      ),
                      MapArea(
                        key: _key,
                        location: location,
                        height: mapAreaHeight,
                        editMode: true,
                        color: systemBlue,
                        notifyChange: updateLocation,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CupertinoButton.filled(
                              onPressed: recordable
                                  ? () {
                                      DatabaseHelper.insertRecord(
                                          name,
                                          amount,
                                          category.index,
                                          date,
                                          store,
                                          paymentMethod,
                                          notes,
                                          location);
                                      submitted = true;
                                      _setRecordable();
                                      Navigator.pop(context);
                                    }
                                  : null,
                              child: const Text('Record')),
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

  void _setRecordable() {
    final newRecordable = name.isNotEmpty && amount > 0 && (!submitted);
    if (recordable != newRecordable) {
      setState(() {
        recordable = newRecordable;
      });
    }
  }

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        // The Bottom margin is provided to align the popup above the system navigation bar.
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        // Provide a background color for the popup.
        color: CupertinoColors.systemBackground.resolveFrom(context),
        // Use a SafeArea widget to avoid system overlaps.
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
  }
}
