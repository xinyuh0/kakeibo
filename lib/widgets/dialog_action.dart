import 'package:flutter/cupertino.dart';

class DialogAction extends StatelessWidget {
  const DialogAction({
    required this.text,
    this.isDefault = true,
    this.isDestructive = false,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  final String text;
  final bool isDefault;
  final bool isDestructive;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CupertinoDialogAction(
      isDefaultAction: isDefault,
      isDestructiveAction: isDestructive,
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
