import 'package:flutter/cupertino.dart';
import 'package:kkb/model/statistic.dart';
import 'package:kkb/utils/format.dart';

class TrendItem extends StatelessWidget {
  final TrendData data;

  Widget renderRatio() {
    if (data.isNew) {
      return const Text(
        'New',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    if (data.ratio > 0) {
      return Text(
        '+${(data.ratio * 100).toStringAsFixed(1)}%',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: CupertinoColors.activeGreen,
        ),
      );
    } else if (data.ratio == 0) {
      return const Text(
        '--',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: CupertinoColors.systemGrey,
        ),
      );
    } else {
      return Text(
        '${(data.ratio * 100).toStringAsFixed(1)}%',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: CupertinoColors.systemRed,
        ),
      );
    }
  }

  Widget renderDiff() {
    const style = TextStyle(
      fontSize: 14,
      color: CupertinoColors.systemGrey,
    );

    if (data.diff > 0) {
      return Text(
        '(+¥${formatNumberWithCommas(data.diff)})',
        style: style,
      );
    } else if (data.diff == 0) {
      return const Text(
        '(--)',
        style: style,
      );
    } else {
      return Text(
        '(-¥${formatNumberWithCommas(data.diff.abs())})',
        style: style,
      );
    }
  }

  const TrendItem({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            data.category.getColorIcon(),
            const SizedBox(width: 6),
            Text(data.category.name, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            renderDiff(),
          ],
        ),
        renderRatio(),
      ],
    );
  }
}
