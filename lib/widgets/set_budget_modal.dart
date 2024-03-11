import 'package:flutter/cupertino.dart';
import 'package:kkb/model/budget.dart';
import 'package:kkb/model/category.dart';

typedef ChangeBudgetFunction = Function(int, Category);

class SetBudgetDialog extends StatefulWidget {
  final ChangeBudgetFunction handleChangeBudget;
  final Progress data;
  final int lowerBound;

  const SetBudgetDialog({
    super.key,
    required this.data,
    required this.lowerBound,
    required this.handleChangeBudget,
  });

  @override
  State<SetBudgetDialog> createState() => _SetBudgetDialogState();
}

class _SetBudgetDialogState extends State<SetBudgetDialog> {
  var inputBudget = 0;
  bool _isError = false;
  String _errorMsg = '';

  void _validateInput(String value) {
    // When the input is empty, regard it as 0
    if (value.isEmpty) {
      if (widget.lowerBound > 0) {
        setState(() {
          _isError = true;
          _errorMsg =
              'Total budget should be greater than sum of category budgets.';
        });
        return;
      }

      setState(() {
        _isError = false;
        _errorMsg = '';
      });
      return;
    }

    // When the input is not empty
    final number = int.tryParse(value);

    String msg = '';

    if (number == null) {
      msg = 'Invalid input.';
    } else if (number < widget.lowerBound && widget.lowerBound == 0) {
      msg = 'Budget should be greater than ${widget.lowerBound}';
    } else if (number < widget.lowerBound && widget.lowerBound > 0) {
      msg = 'Total budget should be greater than sum of category budgets.';
    }

    setState(() {
      _isError = (number == null || number < widget.lowerBound);
      _errorMsg = msg;
    });
  }

  Future<void> onConfirm() async {
    if (_isError) {
      return;
    }

    await widget.handleChangeBudget(inputBudget, widget.data.category);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text('Set Budget'),
      content: Column(
        children: [
          const SizedBox(height: 12),
          CupertinoTextField(
            prefix: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                CupertinoIcons.pen,
                size: 24,
              ),
            ),
            clearButtonMode: OverlayVisibilityMode.editing,
            placeholder: '${widget.data.budget}',
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              border: Border.all(
                // TODO: add some error message
                color: _isError
                    ? CupertinoColors.systemRed
                    : CupertinoColors.systemGrey5,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(5.0),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                inputBudget = int.tryParse(value) ?? 0;
                _validateInput(value);
              });
            },
          ),
          Visibility(
            visible: _isError,
            child: Column(children: [
              const SizedBox(height: 4),
              Text(
                _errorMsg,
                style: const TextStyle(
                  color: CupertinoColors.systemRed,
                ),
              ),
            ]),
          ),
        ],
      ),
      actions: [
        CupertinoDialogAction(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        CupertinoDialogAction(
          child: Text(
            'Confirm',
            style: TextStyle(
              color: _isError
                  ? CupertinoColors.systemGrey
                  : CupertinoColors.activeBlue,
            ),
          ),
          onPressed: () async {
            if (_isError) {
              return;
            }
            // Make sure the operation in onConfirm is finished
            onConfirm().then((value) => {Navigator.of(context).pop()});
          },
        ),
      ],
    );
  }
}
