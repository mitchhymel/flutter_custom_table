

import 'package:flutter/material.dart';

typedef CustomCellRenderer<T> = Widget Function(T);
typedef CustomHeaderRenderer = Widget Function();

class CustomTableColumn<T> {
  final String columnTitle;
  final CustomCellRenderer<T> cellRenderer;
  final CustomHeaderRenderer? headerRenderer;
  final double minWidth;
  final Function(bool)? onColumnVisibilityChange;

  double actualWidth;
  bool hidden;
  double flex;

  CustomTableColumn({
    required this.columnTitle,
    required this.cellRenderer,
    this.headerRenderer,
    this.minWidth = 50,
    this.actualWidth = 150,
    this.hidden = false,
    this.flex = 1,
    this.onColumnVisibilityChange,
  });

  Map toMap() => {
    'columnTitle': columnTitle,
    'flex': flex,
    'actualWidth': actualWidth,
    'minWidth': minWidth,
  };

  @override
  String toString() => toMap().toString();

  void debugPrint({String tag = ''}) {
    print('$tag${toString()}');
  }
}