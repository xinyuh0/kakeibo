import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:kkb/assets/colors.dart';
import 'package:kkb/widgets/map_area.dart';
import 'package:provider/provider.dart';

import '../assets/icons.dart';
import '../controllers/category_controller.dart';
import '../model/app_state_model.dart';
import '../model/spending_record.dart';
import '../model/category.dart';
import '../services/database_helper.dart';
import '../utils/format.dart';
import '../widgets/category_picker.dart';
import '../widgets/date_picker.dart';
import '../widgets/dialog_action.dart';

// TODO: Show error message when invalid input

class RecordInfoPage extends StatefulWidget {
  const RecordInfoPage({super.key, required this.record});

  final SpendingRecord record;

  @override
  State<RecordInfoPage> createState() => _RecordInfoPageState();
}

class _RecordInfoPageState extends State<RecordInfoPage> {
  final GlobalKey<MapAreaState> _key = GlobalKey();

  late String name = widget.record.name;
  late String store = widget.record.store;
  late String paymentMethod = widget.record.paymentMethod;
  late String notes = widget.record.notes;
  late String location = widget.record.location;
  late int amount = widget.record.amount;
  late Category category = widget.record.category;
  late DateTime date = widget.record.date;

  double mapAreaHeight = 150;
  bool editMode = false;

  _RecordInfoPageState();

  // Deletes a record from the database through DatabaseHelper
  Future<void> _deleteRecord() async {
    await DatabaseHelper.deleteRecord(widget.record.id);
  }

  // Updates a record in the database through DatabaseHelper
  Future<void> _updateRecord() async {
    SpendingRecord newRecord = SpendingRecord(
        id: widget.record.id,
        name: name,
        amount: amount,
        category: category,
        date: date,
        store: store,
        paymentMethod: paymentMethod,
        notes: notes,
        location: location);

    await DatabaseHelper.updateRecord(newRecord);
  }

  void updateLocation(String s) {
    setState(() {
      location = s;
    });
  }

  // Closes the current window
  void _close() async {
    Navigator.pop(context);
  }

  // Checks if the data the user has entered is valid
  bool _validInput() {
    return (name != '' && amount > 0);
  }

  // Checks if the user has made any changes
  bool _valuesChanged() => (name != widget.record.name ||
      amount != widget.record.amount ||
      category != widget.record.category ||
      date != widget.record.date ||
      store != widget.record.store ||
      paymentMethod != widget.record.paymentMethod ||
      notes != widget.record.notes ||
      location != widget.record.location);

  // Resets all values to the attributes of record
  void _resetValues() {
    setState(() {
      name = widget.record.name;
      store = widget.record.store;
      paymentMethod = widget.record.paymentMethod;
      notes = widget.record.notes;
      location = widget.record.location;
      amount = widget.record.amount;
      category = widget.record.category;
      date = widget.record.date;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: background,
      navigationBar: CupertinoNavigationBar(
          leading: editMode ? _buildCloseButton() : null,
          trailing: editMode ? _buildSaveButton() : _buildEditButton(),
          border: const Border(
            top: BorderSide.none,
            bottom: BorderSide.none,
            left: BorderSide.none,
            right: BorderSide.none,
          ),
          middle: editMode ? const Text('Edit') : const Text('Record Info')),
      child: Consumer<AppStateModel>(
        builder: (context, model, child) {
          return CustomScrollView(
            slivers: [
              SliverSafeArea(
                  top: false,
                  minimum: const EdgeInsets.only(top: 40),
                  sliver: SliverToBoxAdapter(
                      child: Column(children: [
                    _buildInfoList(),
                    editMode || location != ''
                        ? MapArea(
                            key: _key,
                            location: location,
                            height: mapAreaHeight,
                            editMode: editMode,
                            color: category.color,
                            notifyChange: updateLocation,
                          )
                        : SizedBox(height: mapAreaHeight),
                    _buildDeleteButton(),
                  ]))),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoList() {
    double textFieldSize = 14;
    double iconSize = 28;

    var titlePadding = const EdgeInsets.only(left: 5, top: 5);
    var textPadding =
        const EdgeInsets.only(top: 0, bottom: 5, left: 5, right: 5);

    Icon icon(IconData icon) => Icon(icon,
        size: iconSize, color: editMode ? systemBlue : category.color);

    TextStyle textStyle =
        TextStyle(fontSize: textFieldSize, color: systemGrey2);

    TextStyle titleStyle() => TextStyle(color: editMode ? systemBlue : black);

    Text errorText = const Text('Invalid input',
        style: TextStyle(color: systemRed, fontSize: 14));

    return CupertinoListSection.insetGrouped(
      children: [
        CupertinoListTile(
          leading: icon(iconAccountBalance),
          title: Padding(
              padding: titlePadding, child: Text('Name', style: titleStyle())),
          subtitle: CupertinoTextField.borderless(
              enabled: editMode,
              padding: textPadding,
              controller: editMode ? null : TextEditingController(text: name),
              style: textStyle,
              onChanged: (value) => setState(() {
                    name = value;
                  })),
          additionalInfo: name != '' ? null : errorText,
        ),
        CupertinoListTile(
          leading: icon(iconStore),
          title: Padding(
              padding: titlePadding, child: Text('Store', style: titleStyle())),
          subtitle: CupertinoTextField.borderless(
              enabled: editMode,
              padding: textPadding,
              controller: editMode
                  ? null
                  : TextEditingController(text: store == '' ? '-' : store),
              style: textStyle,
              onChanged: (value) => setState(() {
                    store = value;
                  })),
        ),
        CupertinoListTile(
            leading: icon(category.iconData),
            title: Padding(
                padding: titlePadding,
                child: Text('Category', style: titleStyle())),
            subtitle: Padding(
                padding: textPadding,
                child: Text(category.name, style: textStyle)),
            onTap: editMode ? () => _showCategoryDialog() : null),
        CupertinoListTile(
          leading: icon(iconMoney),
          title: Padding(
              padding: titlePadding,
              child: Text('Amount', style: titleStyle())),
          subtitle: CupertinoTextField.borderless(
              enabled: editMode,
              keyboardType: TextInputType.number,
              padding: textPadding,
              controller: editMode
                  ? null
                  : TextEditingController(text: formatNumberWithCommas(amount)),
              style: textStyle,
              onChanged: (value) => setState(() {
                    amount = int.tryParse(value.replaceAll(',', '')) ?? 0;
                  })),
          additionalInfo: amount > 0 ? null : errorText,
        ),
        CupertinoListTile(
          leading: icon(iconCreditCard),
          title: Padding(
              padding: titlePadding,
              child: Text('Payment Method', style: titleStyle())),
          subtitle: CupertinoTextField.borderless(
              enabled: editMode,
              padding: textPadding,
              controller: editMode
                  ? null
                  : TextEditingController(
                      text: paymentMethod == '' ? '-' : paymentMethod),
              style: textStyle,
              onChanged: (value) => setState(() {
                    paymentMethod = value;
                  })),
        ),
        CupertinoListTile(
            leading: icon(iconDate),
            title: Padding(
                padding: titlePadding,
                child: Text('Date', style: titleStyle())),
            subtitle: Padding(
                padding: textPadding,
                child: Text(DateFormat('EE, MMM d, yyyy').format(date),
                    style: textStyle)),
            onTap: editMode ? () => _showDateDialog() : null),
        CupertinoListTile(
          leading: icon(iconNotes),
          title: Padding(
              padding: titlePadding, child: Text('Notes', style: titleStyle())),
          subtitle: CupertinoTextField.borderless(
              enabled: editMode,
              padding: textPadding,
              controller: editMode
                  ? null
                  : TextEditingController(text: notes == '' ? '-' : notes),
              style: textStyle,
              onChanged: (value) => setState(() {
                    notes = value;
                  })),
        ),
        CupertinoListTile(
          leading: icon(iconLocation),
          title: Padding(
              padding: titlePadding,
              child: Text('Location', style: titleStyle())),
        ),
      ],
    );
  }

  void _showCategoryDialog() => _showDialog(
        CategoryPicker(
            controller: FixedExtentScrollController(
              initialItem: category.index,
            ),
            onChanged: (int i) {
              setState(() {
                category = CategoryController.getCategory(i);
              });
            }),
      );

  void _showDateDialog() => _showDialog(DatePicker(
      initialDate: date,
      onChanged: (DateTime d) {
        setState(() {
          date = d;
        });
      }));

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

  Widget _buildDeleteMenu(BuildContext context) => StatefulBuilder(
        builder: (context, setState) => CupertinoAlertDialog(
          title: const Text('Delete Record'),
          content: const Text('Are you sure you want to delete this record?'),
          actions: [
            DialogAction(
              text: 'Delete',
              isDefault: false,
              isDestructive: true,
              onPressed: () {
                Navigator.pop(context, 'delete');
              },
            ),
            DialogAction(
              text: 'Cancel',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );

  Future<void> _showPopupMsg(String action) async {
    await showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('Record $action'),
        content: Text('The record was successfully $action'),
        actions: [
          DialogAction(
            text: 'Ok',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton() =>
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Visibility(
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            visible: editMode,
            child: CupertinoButton(
              child: const Text(
                'Delete Record',
                style: TextStyle(color: systemRed),
              ),
              onPressed: () async {
                String s = await showCupertinoModalPopup(
                    context: context, builder: _buildDeleteMenu);
                if (s == 'delete') {
                  await _deleteRecord();
                  await _showPopupMsg('deleted');
                  _close();
                }
              },
            ))
      ]);

  Widget _buildCloseButton() => CupertinoButton(
        padding: const EdgeInsets.only(left: 0, right: 5, top: 5, bottom: 5),
        onPressed: () async {
          _resetValues();
          setState(() {
            editMode = false;
          });
          _key.currentState!.setEditMode(false);
        },
        child: const Text(
          'Cancel',
          style: TextStyle(color: systemBlue),
        ),
      );

  Widget _buildEditButton() => CupertinoButton(
      padding: const EdgeInsets.all(5),
      onPressed: () async {
        setState(() {
          editMode = true;
        });
        _key.currentState!.setEditMode(true);
      },
      child: const Text(
        'Edit',
        style: TextStyle(color: systemBlue),
      ));

  Widget _buildSaveButton() => CupertinoButton(
        padding: const EdgeInsets.all(5),
        onPressed: () async {
          location = _key.currentState!.getLocation();
          if (editMode && _validInput() && _valuesChanged()) {
            await _updateRecord();
            setState(() {
              editMode = false;
            });
            _key.currentState!.setEditMode(false);
          }
        },
        child: Text(
          'Save',
          style: TextStyle(
              color: editMode && _validInput() && _valuesChanged()
                  ? systemBlue
                  : grey),
        ),
      );
}
