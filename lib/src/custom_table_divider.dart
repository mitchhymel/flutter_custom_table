import 'package:flutter/material.dart';

class CustomTableDividerStyle {
  final double height;
  final double width;
  final Color color;
  const CustomTableDividerStyle(
      {required this.height, required this.width, required this.color});
}

class CustomTableDivider extends StatefulWidget {
  final Widget child;
  final double width;
  final Function(Offset, Offset) onDrag;
  final CustomTableDividerStyle style;
  const CustomTableDivider({
    Key? key,
    required this.width,
    required this.child,
    required this.onDrag,
    required this.style,
  }) : super(key: key);

  @override
  State createState() => _CustomTableDividerState();
}

class _CustomTableDividerState extends State<CustomTableDivider> {
  static const double defaultSizeOfDragBox = 4;

  Offset previous = const Offset(0, 0);
  Offset starting = const Offset(0, 0);
  bool dragging = false;

  @override
  Widget build(BuildContext context) {
    var style = widget.style;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: widget.width, child: widget.child),
        MouseRegion(
          cursor: SystemMouseCursors.resizeColumn,
          onHover: (details) {
            if (!dragging) {
              setState(() {
                starting = details.position;
              });
            }
          },
          child: Draggable(
            feedback: Container(),
            child: Container(
              width: style.width,
              height: style.height,
              color: style.color,
            ),
            childWhenDragging: Container(
              width: style.width,
              height: style.height,
              color: style.color,
            ),
            onDragStarted: () {
              setState(() {
                dragging = true;
                previous = starting;
              });
              
            },
            onDragUpdate: (details) {
              widget.onDrag(previous, details.globalPosition);
              setState(() {
                previous = details.globalPosition;
              });
            },
          ),
        )
      ],
    );
  }
}