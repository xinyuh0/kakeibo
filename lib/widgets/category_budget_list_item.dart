import 'package:flutter/cupertino.dart';
import 'package:kkb/model/budget.dart';
import 'package:kkb/utils/format.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

const TextStyle subTextStyle = TextStyle(
  fontSize: 14,
  color: CupertinoColors.systemGrey,
);

class CategoryBudgetItem extends StatelessWidget {
  final VoidCallback onTap;
  final Progress data;

  const CategoryBudgetItem({
    Key? key,
    required this.data,
    required this.onTap,
  }) : super(key: key);

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return formatNumber(number);
    } else {
      return formatNumberWithCommas(number);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(left: 12, right: 12, top: 4, bottom: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 0,
                        bottom: 0,
                        left: 12,
                        right: 12,
                      ),
                      child: data.category.getColorIcon(),
                    ),
                    Container(
                      width: 48,
                      alignment: Alignment.center,
                      child: Text(
                        data.category.name,
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                    )
                  ],
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¥${_formatNumber(data.budget)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Row(
                      children: [
                        const Text(
                          'Used:',
                          style: subTextStyle,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '¥${_formatNumber(data.total)}',
                          style: subTextStyle,
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
            LinearPercentIndicator(
              width: 130,
              percent: data.percentage,
              progressColor: data.category.color,
              backgroundColor: const Color(0xFFF2F2F2),
              lineHeight: 8,
              barRadius: const Radius.circular(4),
            ),
          ],
        ),
      ),
    );
  }
}

class UnsetBudgetItem extends StatelessWidget {
  final VoidCallback onTap;
  final Progress data;

  const UnsetBudgetItem({
    Key? key,
    required this.data,
    required this.onTap,
  }) : super(key: key);

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return formatNumber(number);
    } else {
      return formatNumberWithCommas(number);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(left: 12, right: 12, top: 6, bottom: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 0,
                    bottom: 0,
                    left: 12,
                    right: 12,
                  ),
                  child: data.category.getColorIcon(),
                ),
                const SizedBox(width: 8),
                Text(
                  data.category.name,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(
              width: 120,
              child: Row(
                children: [
                  const Text(
                    'Used:',
                    style: subTextStyle,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '¥${_formatNumber(data.total)}',
                    style: subTextStyle,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
