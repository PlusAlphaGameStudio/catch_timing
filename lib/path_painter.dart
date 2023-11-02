import 'dart:math';
import 'package:flutter/material.dart';

class PathPainter extends CustomPainter {
  final Size _bounds;
  final Path _path;
  final Offset _targetPos;
  final Offset _circlePos;
  final Size _circleSize = const Size(100, 100);

  late final Paint _circlePaint;
  late final Paint _targetPaint;

  PathPainter(this._bounds, this._path, this._targetPos, this._circlePos) {
    _circlePaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12.0
      ..strokeCap = StrokeCap.round;

    _targetPaint = Paint()
      ..color = Colors.cyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12.0
      ..strokeCap = StrokeCap.round;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0;

    final sX = size.width / _bounds.width;
    final sY = size.height / _bounds.height;
    final s = min(sX, sY);

    // if (kDebugMode) {
    //   print('Path painter size: $size');
    //   print('Path painter scale: $s');
    // }

    canvas.scale(s);

    canvas.drawPath(_path, paint);
    canvas.drawArc(
        _targetPos & _circleSize, -pi / 2, pi * 2, false, _targetPaint);
    canvas.drawArc(
        _circlePos & _circleSize, -pi / 2, pi * 2, false, _circlePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
