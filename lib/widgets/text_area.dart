import 'package:flutter/cupertino.dart';
import 'package:kkb/assets/icons.dart';

typedef HandleConfirmFunction = Function(String);

class MultiLineTextArea extends StatefulWidget {
  final HandleConfirmFunction handleConfirm;
  final double height;
  final BoxDecoration? boxDecoration;
  final bool disableConfirm;

  const MultiLineTextArea({
    super.key,
    required this.handleConfirm,
    // Height of TextField, doesn't contain footer area
    this.height = 148.0,
    this.boxDecoration,
    this.disableConfirm = false,
  });

  @override
  State<MultiLineTextArea> createState() => _TextAreaState();
}

class _TextAreaState extends State<MultiLineTextArea> {
  String val = '';

  final TextEditingController _controller = TextEditingController();

  void onConfirm() {
    if (widget.disableConfirm || val == '') {
      return;
    }

    // Send value and clear input field
    widget.handleConfirm(val);

    _controller.clear();
    setState(() {
      val = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: widget.boxDecoration,
      child: Column(
        children: [
          SizedBox(
            height: widget.height,
            child: CupertinoTextField.borderless(
              textAlignVertical: TextAlignVertical.top,
              placeholder: 'Ask any questions about your spendings',
              controller: _controller,
              keyboardType: TextInputType.multiline,
              padding: const EdgeInsets.only(
                top: 12,
                bottom: 0,
                left: 12,
                right: 12,
              ),
              maxLines: null,
              expands: true,
              style: const TextStyle(fontSize: 18),
              onChanged: (value) {
                setState(() {
                  val = value;
                });
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  right: 12,
                  bottom: 12,
                ),
                child: GestureDetector(
                  onTap: onConfirm,
                  child: Icon(
                    iconSendMessage,
                    size: 32,
                    color: widget.disableConfirm
                        ? CupertinoColors.systemGrey
                        : CupertinoColors.activeBlue,
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
