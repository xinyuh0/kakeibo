import 'package:flutter/material.dart';

class Category {
  const Category({
    required this.index,
    required this.name,
    required this.color,
    required this.iconData,
  });

  final int index;
  final String name;
  final Color color;
  final IconData iconData;

  Icon getIcon({double size = 24.0}) => Icon(iconData, size: size);

  Icon getColorIcon({double size = 24.0}) =>
      Icon(iconData, color: color, size: size);
}
