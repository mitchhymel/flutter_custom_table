import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_improved_scrolling/flutter_improved_scrolling.dart';
import 'package:known_extents_list_view_builder/known_extents_list_view_builder.dart';
import 'package:custom_table/src/custom_table_column.dart';
import 'package:custom_table/src/custom_table_column_switch.dart';
import 'package:custom_table/src/custom_table_divider.dart';

typedef CustomSort<T> = int Function(T, T);

class CustomTable<T> extends StatefulWidget {
  static const CustomTableDividerStyle _defaultDividerStyle =
  CustomTableDividerStyle(
    width: 4,
    height: 24,
    color: Colors.white12,
  );

  final List<T> items;
  final List<CustomTableColumn<T>> columns;
  final Color headerBackgroundColor;
  final TextStyle? headerTextStyle;
  final Color Function(int) getRowBackgroundColor;
  final CustomTableDividerStyle dividerStyle;
  final List<double> itemExtents;
  final String Function(int) rowKeyBuilder;
  final Function(int, PointerDownEvent)? onRowRightClick;
  final ScrollController? controller;
  final Function(int)? onRowClicked;

  const CustomTable({
    Key? key,
    required this.items,
    required this.columns,
    required this.headerBackgroundColor,
    required this.getRowBackgroundColor,
    this.dividerStyle = _defaultDividerStyle,
    required this.itemExtents,
    required this.rowKeyBuilder,
    this.headerTextStyle,
    this.onRowRightClick,
    this.controller,
    this.onRowClicked,
  }) : super(key: key);

  @override
  State createState() => CustomTableState<T>();
}

class CustomTableState<T> extends State<CustomTable<T>> {
  // copy columns so we can change their widths/flexs
  List<CustomTableColumn<T>> columns = [];
  ScrollController controller = ScrollController();
  CustomTableState();

  @override
  void initState() {
    super.initState();

    if (widget.controller != null) {
      controller = widget.controller!;
    }

    columns = widget.columns;
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      controller.dispose();
    }
    super.dispose();
  }

  List<CustomTableColumn<T>> _getNonHiddenColumns() =>
      columns.where((element) => !element.hidden).toList();

  double get widthOfAllColumns {
    var cols = _getNonHiddenColumns();
    double width = 0;
    cols.toList().forEach((element) {
      width += element.actualWidth;
    });
    return width;
  }

  double get minWidthOfAllColumns {
    var cols = _getNonHiddenColumns();
    double width = 0;
    cols.toList().forEach((element) {
      width += element.minWidth;
    });
    return width;
  }

  double get totalFlex {
    var nonHiddenColumns = _getNonHiddenColumns().toList();
    double total = 0;
    for (var element in nonHiddenColumns) {
      total += element.flex;
    }

    return total;
  }

  _getShowHideColumnsControls() {
    var switches = columns
        .map((column) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(column.columnTitle),
        Expanded(child: Container()),
        CustomTableColumnSwitch(
          initVal: !column.hidden,
          onChanged: (val) {
            if (column.onColumnVisibilityChange != null) {
              column.onColumnVisibilityChange!(val);
            }

            setState(() {
              column.hidden = !val;
            });
          },
        )
      ],
    ))
        .toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: switches,
    );
  }

  _getHeader({required double maxWidth}) {
    var nonHiddenColumns = _getNonHiddenColumns();

    List<Widget> headerWidgets = [];

    for (int i = 0; i < nonHiddenColumns.length; i++) {
      var column = nonHiddenColumns[i];
      bool isLast = (i == nonHiddenColumns.length - 1);
      var actualWidthToUse = column.actualWidth;

      var columnHeader = SizedBox(
          width: actualWidthToUse,
          height: widget.dividerStyle.height,
          child: column.headerRenderer != null
              ? column.headerRenderer!()
              : Text(column.columnTitle,
              overflow: TextOverflow.ellipsis,
              style: widget.headerTextStyle ??
                  const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  )));

      // for last column dont include resizer
      if (isLast) {
        headerWidgets.add(columnHeader);
        continue;
      }

      var resizer = CustomTableDivider(
        width: actualWidthToUse,
        child: columnHeader,
        style: widget.dividerStyle,
        onDrag: (previous, offset) {
          _onColumnResize(
            maxWidth: maxWidth,
            columnToResize: column,
            previous: previous,
            offset: offset
          );
        },
      );

      headerWidgets.add(resizer);
    }

    return Listener(
      onPointerDown: (event) {
        if (event.kind == PointerDeviceKind.mouse &&
            event.buttons == kSecondaryMouseButton) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Select columns to show'),
              content: _getShowHideColumnsControls()
            )
          );
        }
      },
      child: Container(
        color: widget.headerBackgroundColor,
        child: Row(
          children: headerWidgets,
        )
      )
    );
  }

  _getRow(int index, T item) {
    var nonHiddenColumns = _getNonHiddenColumns();

    List<Widget> cellWidgets = [];
    for (int i = 0; i < nonHiddenColumns.length; i++) {
      var column = nonHiddenColumns[i];
      var isLast = (i == nonHiddenColumns.length - 1);
      var actualWidthToUse = column.actualWidth;
      var newWidget =
      SizedBox(width: actualWidthToUse, child: column.cellRenderer(item));

      cellWidgets.add(newWidget);

      if (!isLast) {
        cellWidgets.add(Container(width: widget.dividerStyle.width));
      }
    }

    Color rowColor = widget.getRowBackgroundColor(index);

    Widget child = Container(
      key: Key(widget.rowKeyBuilder(index)),
      decoration: BoxDecoration(
        color: rowColor,
      ),
      child: Row(
        children: cellWidgets,
      )
    );

    if (widget.onRowRightClick != null) {
      child = Listener(
        onPointerDown: (event) async {
          if (event.kind == PointerDeviceKind.mouse &&
              event.buttons == kSecondaryMouseButton) {
            widget.onRowRightClick!(index, event);
          }
        },
        child: child,
      );
    }

    if (widget.onRowClicked != null) {
      child = Listener(
        onPointerDown: (event) async {
          if (event.kind == PointerDeviceKind.mouse && event.buttons == kPrimaryMouseButton) {
            widget.onRowClicked!(index);
          }
        },
        child: child,
      );
    }


    return child;
  }

  _getRows() {
    if (widget.items.isEmpty) {
      return Container();
    }

    return Expanded(
      child: ImprovedScrolling(
        scrollController: controller,
        enableMMBScrolling: true,
        mmbScrollConfig: const MMBScrollConfig(
          customScrollCursor: DefaultCustomScrollCursor()
        ),
        child: KnownExtentsListView.builder(
          controller: controller,
          key: ValueKey(widget.itemExtents.hashCode),
          physics: const ClampingScrollPhysics(),
          itemCount: widget.items.length,
          itemExtents: widget.itemExtents,
          itemBuilder: (_, index) => _getRow(index, widget.items[index]),
        )
      )
    );
  }

  _onColumnResize({
    required double maxWidth,
    required CustomTableColumn<T> columnToResize,
    required Offset previous,
    required Offset offset,
  }) {
    // print('maxWidth: $maxWidth');
    // columnToResize.debugPrint(tag: 'resize');
    // print('previous: $previous');
    // print('offset: $offset');
    //
    // var delta = offset.dx - previous.dx;
    //
    // if (delta < 0 && columnToResize.minWidth == columnToResize.actualWidth) {
    //   print('column is already minflex');
    //   return;
    // }
    //
    // var newWidth = columnToResize.actualWidth + delta;
    // var oldFlex = columnToResize.flex;
    // var newFlex = newWidth / maxWidth * totalFlex;
    // var minFlex = columnToResize.minWidth / maxWidth * totalFlex;
    //
    // print('newWidth: $newWidth');
    // print('oldFlex: $oldFlex');
    // print('newFlex: $newFlex');
    // print('minFlex: $minFlex');
    //
    // if (newFlex < minFlex) {
    //   print('column hit minFlex');
    //   newFlex = minFlex;
    //   newWidth = columnToResize.minWidth;
    // }
    //
    // var deltaFlex = newFlex - oldFlex;
    // print('deltaFlex: $deltaFlex');
    //
    // var nonHiddenColumns = _getNonHiddenColumns();
    // var columnToResizeIndex = nonHiddenColumns.indexOf(columnToResize);
    // var columnsRightOfResizingColumn = nonHiddenColumns.sublist(columnToResizeIndex+1);
    // // if increasing size
    // if (delta > 0) {
    //   var columnsRightThatCanBeResized = columnsRightOfResizingColumn.where((x) => x.actualWidth > x.minWidth).toList();
    //
    //   while (deltaFlex != 0) {
    //     var columnToDecrease = columnsRightThatCanBeResized.first;
    //     columnToDecrease.debugPrint(tag: 'decreasecolumn');
    //
    //     var newDecreaseFlex = columnToDecrease.flex - deltaFlex;
    //     var minDecreaseFlex = columnToDecrease.minWidth / maxWidth * totalFlex;
    //     if (newDecreaseFlex < minDecreaseFlex) {
    //       print('cant resize this column');
    //       columnsRightThatCanBeResized.removeAt(0);
    //
    //       if (columnsRightThatCanBeResized.isEmpty) {
    //         print('no columns could be resized');
    //         return;
    //       }
    //     }
    //     else {
    //       columnToDecrease.flex = newDecreaseFlex;
    //       deltaFlex = 0;
    //     }
    //   }
    //
    //   columnToResize.flex = newFlex;
    //   setState((){});
    //
    //
    // }
    // else {
    //
    // }

    // var minFlex = columnToResize.minWidth/maxWidth*totalFlex;
    // var newFlex = columnToResize.flex + (2*offset.dx/maxWidth);
    // if (newFlex < minFlex) {
    //   newFlex = minFlex;
    // }
    //
    // setState(() {
    //   columnToResize.flex = newFlex;
    // });

    // var nonHiddenColumns = _getNonHiddenColumns();
    // var columnToResizeIndex = nonHiddenColumns.indexOf(columnToResize);
    // var columnsRightOfResizingColumn = nonHiddenColumns.sublist(columnToResizeIndex+1);
    // var columnsRightThatCanBeResized = columnsRightOfResizingColumn.where((x) => x.actualWidth > x.minWidth);
    //
    // if (columnsRightThatCanBeResized.isEmpty) {
    //   print('cant resize anything');
    //   return;
    // }
    //
    // double deltaAsFlex = dragDelta/maxWidth;
    //
    // double totalFlexOfColumnsThatCanBeResized = 0;
    // for (var x in columnsRightThatCanBeResized) {
    //   totalFlexOfColumnsThatCanBeResized += x.flex;
    // }
    //
    // var columnsThatWouldGoBelowMinIfResized = columnsRightThatCanBeResized.where((x) {
    //   return (x.flex - deltaAsFlex/totalFlexOfColumnsThatCanBeResized) * maxWidth < x.minWidth;
    // });
    //
    // var columnsToResize = columnsRightThatCanBeResized.where((x) => !columnsThatWouldGoBelowMinIfResized.contains(x));
    // for (var x in columnsToResize) {
    //   totalFlexOfColumnsThatCanBeResized += x.flex;
    // }
    //
    // setState((){
    //   columnToResize.flex += deltaAsFlex;
    //   for (var x in columnsToResize) {
    //     x.flex += deltaAsFlex/totalFlexOfColumnsThatCanBeResized;
    //   }
    // });

    // var nonHiddenColumns = _getNonHiddenColumns().toList();
    // double total = totalFlex;
    //
    // if (total == 0) {
    //   throw Exception('total flex was 0');
    // }
    //
    // for (var element in nonHiddenColumns) {
    //   var columnWidth = element.flex/total
    //       * maxWidth
    //       - DraggableBar.defaultSizeOfDragBox;
    //   if (columnWidth < element.minWidth) {
    //     columnWidth = element.minWidth;
    //   }
    //
    //   element.actualWidth = columnWidth;
    // }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        // calculate columns actual width;
        var nonHiddenColumns = _getNonHiddenColumns().toList();
        double total = totalFlex;
        if (total == 0) {
          throw Exception('Total flex was 0');
        }

        double totalMinWidth = minWidthOfAllColumns;
        if (totalMinWidth > constraints.maxWidth) {
          print('Total min width of columns ($totalMinWidth) exceeded current view max width (${constraints.maxWidth})');
        }

        double sumWidthOfDragBoxes =
            widget.dividerStyle.width * (nonHiddenColumns.length - 1);
        double widthToUse = constraints.maxWidth - sumWidthOfDragBoxes;

        for (var element in nonHiddenColumns) {
          var columnWidth = element.flex / total * widthToUse;
          // if (columnWidth < element.minWidth) {
          //   columnWidth = element.minWidth;
          // }

          element.actualWidth = columnWidth;
        }

        return Column(
          children: [
            _getHeader(maxWidth: constraints.maxWidth),
            _getRows(),
          ],
        );
      },
    );
  }
}
