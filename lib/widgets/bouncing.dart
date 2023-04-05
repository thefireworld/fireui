import 'dart:developer';

import 'package:flutter/material.dart';

class BouncingWidget extends StatefulWidget {
  final Widget? child;
  final VoidCallback? onTap;

  const BouncingWidget({this.child, this.onTap, Key? key}) : super(key: key);

  @override
  State<BouncingWidget> createState() => _BouncingWidgetState();
}

class _BouncingWidgetState extends State<BouncingWidget>
    with SingleTickerProviderStateMixin {
  late double _scale;
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 100,
      ),
      lowerBound: 0,
      upperBound: .05,
    )..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    log(details.toString());
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    log(details.toString());
    _controller.reverse();
  }

  void _onDragEnd(DragEndDetails details) {
    log(details.toString());
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _controller.value;

    return Transform.scale(
      scale: _scale,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: widget.onTap,
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onHorizontalDragEnd: _onDragEnd,
          onVerticalDragEnd: _onDragEnd,
          child: AbsorbPointer(child: widget.child),
        ),
      ),
    );
  }
}
