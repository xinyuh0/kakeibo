import 'package:flutter/cupertino.dart';

import '../controllers/category_controller.dart';
import '../model/category.dart';

const _kItemExtent = 32.0;

class CategoryPicker extends StatelessWidget {
  const CategoryPicker({
    required this.controller,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  final FixedExtentScrollController controller;
  final void Function(int) onChanged;

  @override
  Widget build(BuildContext context) {
    return CupertinoPicker(
      magnification: 1.22,
      squeeze: 1.2,
      useMagnifier: true,
      itemExtent: _kItemExtent,
      // This sets the initial item.
      scrollController: controller,
      // This is called when selected item is changed.
      onSelectedItemChanged: onChanged,
      children: List<Widget>.generate(CategoryController.getCategoryCount() - 1,
          (int i) {
        Category c = CategoryController.getCategories()[i];
        return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(c.iconData, color: c.color),
          const SizedBox(width: 10),
          Text(c.name)
        ]);
      }),
    );
  }
}
