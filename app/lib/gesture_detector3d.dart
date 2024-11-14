import 'package:flutter/material.dart';
import 'dart:convert';

class Drag extends StatefulWidget {
  final Widget child;

  final void Function(dynamic) sendMessage;
  const Drag(this.child, this.sendMessage, {super.key});

  @override
  DragState createState() => DragState();
}

class DragState extends State<Drag> with SingleTickerProviderStateMixin {
  int cnt = 0;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          child: GestureDetector(
            child: widget.child,
            onScaleUpdate: (ScaleUpdateDetails details) {
              if (details.pointerCount == 1) {
                widget.sendMessage(jsonEncode({
                  'yaw': details.focalPointDelta.dx,
                  'pitch': details.focalPointDelta.dy,
                  'code': "orientationUpdate"
                }));
              } else if (details.pointerCount == 2) {
                if (cnt % 4 == 3) {
                  widget.sendMessage(jsonEncode(
                      {'scale': details.scale, 'code': "scaleUpdate"}));
                  setState(() {
                    cnt = 0;
                  });
                } else {
                  setState(() {
                    cnt++;
                  });
                }
              }
            },
            onScaleEnd: (ScaleEndDetails details) {
              widget.sendMessage(jsonEncode({"code": "scaleEnd"}));
            },
          ),
        )
      ],
    );
  }
}
