import 'dart:math';

import 'package:custom_table/custom_table.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(Example());
}

class Example extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CustomTableExample',
      home: Scaffold(
        body: ExampleTable()
      )
    );
  }
}


class ExampleData {
  late int index;
  late String name;
  late int multiplied;
  ExampleData(int i) {
    index = i;
    name = i.toString();
    multiplied = i * 10;
  }
}

final customTableKey = GlobalKey<CustomTableState<ExampleData>>();

class ExampleTable extends StatefulWidget {
  
  @override
  State createState() => _ExampleTableState();
}

class _ExampleTableState extends State<ExampleTable> {

  bool sortAscending = true;
  ScrollController controller = ScrollController();

  @override
  dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {

    List<ExampleData> items = [];
    for (int i = 0; i < 1000; i ++) {
      items.add(ExampleData(i));
    }

    List<double> itemExtents = [];
    for (int i = 0; i < items.length; i++) {
      itemExtents.add(40 + i * Random().nextDouble());
    }

    const headerTextStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );

    List<CustomTableColumn<ExampleData>> columns = [
      CustomTableColumn(
        columnTitle: 'Index',
        cellRenderer: (item) => Text(item.index.toString()),
        headerRenderer: () => InkWell(
          child: Container(
            color: sortAscending ? Colors.transparent : Colors.blue,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text('Index',
                  style: headerTextStyle,
                  overflow: TextOverflow.ellipsis
                ),
                if (sortAscending) const Icon(Icons.arrow_downward, size: 16),
                if (!sortAscending) const Icon(Icons.arrow_upward, size: 16),
              ],
            )
          ),
          onTap: () {
            setState(() {
              sortAscending = !sortAscending;
            });
          }
        ),
      ),
      CustomTableColumn(
        columnTitle: 'Name',
        cellRenderer: (item) => Text(item.name),
      ),
      CustomTableColumn(
        columnTitle: 'Multiplied',
        cellRenderer: (item) => Text(item.multiplied.toString(),
          style: TextStyle(
            color: Colors.blueAccent
          )
        ),
        flex: 3,
      ),
    ];

    return Expanded(
      child: CustomTable<ExampleData>(
        items: items,
        itemExtents: itemExtents,
        key: customTableKey,
        columns: columns,
        controller: controller,
        headerTextStyle: headerTextStyle,
        headerBackgroundColor: Theme.of(context).primaryColor,
        rowKeyBuilder: (index) => items[index].index.toString(),
        getRowBackgroundColor: (index) => index%2==0 ? Colors.purpleAccent : Colors.blueAccent,
      )
    );
  }
}
