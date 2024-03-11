import 'package:flutter/cupertino.dart';

import 'dialog_action.dart';

class PopupDialog extends StatelessWidget {
  const PopupDialog({
    this.title = const Text(''),
    this.content = const Text(''),
    required this.actions,
    Key? key,
  }) : super(key: key);

  final Widget title;
  final Widget content;
  final List<DialogAction> actions;

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: title,
      content: content,
      actions: actions,
    );
  }
}
