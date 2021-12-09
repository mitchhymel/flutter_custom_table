import 'package:flutter/material.dart';

class CustomTableColumnSwitch extends StatefulWidget {
  final bool initVal;
  final Function(bool) onChanged;
  const CustomTableColumnSwitch({
    Key? key,
    required this.initVal,
    required this.onChanged,
  }) : super(key: key);

  @override
  State createState() => _CustomTableColumnSwitchState();
}

class _CustomTableColumnSwitchState extends State<CustomTableColumnSwitch> {
  late bool enabled;

  _CustomTableColumnSwitchState() {
    enabled = widget.initVal;
  }

  @override
  Widget build(BuildContext context) {

    return Switch(
      value: enabled,
      onChanged: (value) {
        widget.onChanged(value);
        setState(() {
          enabled = value;
        });
      },
    );
  }
}