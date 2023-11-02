import 'dart:math';
import 'dart:ui';

import 'package:auto_route/annotations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

@RoutePage()
class GamePage extends StatefulWidget {
  final int stageId;

  const GamePage(@PathParam('stageId') this.stageId, {super.key});

  String get fileName => '${stageId.toString().padLeft(2, '0')}.png';

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage>
    with SingleTickerProviderStateMixin {
  double _fraction = 0.0;
  late final Animation<double> _animation;
  late final AnimationController _controller;
  late final Path _path;
  late final PathMetric _pathMetric;
  late final Random _random;
  late final Offset _targetPos;

  static const _circleSize = Size(100, 100);
  static const _speed = 0.2;

  @override
  void initState() {
    super.initState();

    _random = Random();

    const size = Size(600, 600);
    _targetPos = _getRandomPointWithin(size);
    _path = _createPath(size, _targetPos);
    _pathMetric = _createMetric(_path);

    if (kDebugMode) {
      print(_path.getBounds());
      print(_targetPos);
    }

    _controller = AnimationController(
        duration: Duration(milliseconds: (_pathMetric.length / _speed).round()),
        vsync: this);

    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {
          _fraction = _animation.value;
        });
      });

    //_controller.forward();
    _controller.repeat();
  }

  Offset _getRandomPointWithin(Size size) {
    return Offset(
        _random.nextDouble() * size.width, _random.nextDouble() * size.height);
  }

  Path _createPath(Size size, Offset targetPos) {
    final path = Path();

    final initial = _moveToRandomPoint(path, size);
    for (var i = 0; i < 10; i++) {
      final r = _random.nextInt(10);
      if (r == 0) {
        _lineToRandomPoint(path, size);
      } else if (r < 3) {
        path.lineTo(targetPos.dx, targetPos.dy);
      } else if (r < 5) {
        final p1 = _getRandomPointWithin(size);
        path.quadraticBezierTo(p1.dx, p1.dy, targetPos.dx, targetPos.dy);
      } else {
        _curveToRandomPoint(path, size);
      }
    }
    path.lineTo(initial.dx, initial.dy);
    return path;
  }

  Offset _moveToRandomPoint(Path path, Size size) {
    final p = _getRandomPointWithin(size);
    path.moveTo(p.dx, p.dy);
    return p;
  }

  void _lineToRandomPoint(Path path, Size size) {
    final p = _getRandomPointWithin(size);
    path.lineTo(p.dx, p.dy);
  }

  void _curveToRandomPoint(Path path, Size size) {
    final p1 = _getRandomPointWithin(size);
    final p2 = _getRandomPointWithin(size);
    path.quadraticBezierTo(p1.dx, p1.dy, p2.dx, p2.dy);
  }

  PathMetric _createMetric(Path path) {
    final pathMetrics = path.computeMetrics();
    return pathMetrics.elementAt(0);
  }

  Offset _calculatePosition(double normalizedValue) {
    return _pathMetric
            .getTangentForOffset(_pathMetric.length * normalizedValue)
            ?.position ??
        Offset.zero;
  }

  @override
  Widget build(BuildContext context) {
    final circlePos = _calculatePosition(_fraction);

    final aligned = (circlePos - _targetPos).distance < 10;

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          Image.asset(
            aligned
                ? 'assets/tests/images/clear/${widget.fileName}'
                : 'assets/tests/images/lock/${widget.fileName}',
            fit: BoxFit.contain,
            //height: double.infinity,
            //width: double.infinity,
          ),
          CustomPaint(
            painter: PathPainter(_path),
          ),
          Positioned(
            left: _targetPos.dx - _circleSize.width / 2,
            top: _targetPos.dy - _circleSize.height / 2,
            child: CustomPaint(
              painter: CirclePainter(
                fraction: 1,
                circleColor: Colors.cyan,
              ),
              size: _circleSize,
            ),
          ),
          Positioned(
            left: circlePos.dx - _circleSize.width / 2,
            top: circlePos.dy - _circleSize.height / 2,
            child: CustomPaint(
              painter: CirclePainter(
                fraction: 1,
                circleColor: Colors.red,
              ),
              size: _circleSize,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class CirclePainter extends CustomPainter {
  final double fraction;
  late final Paint _circlePaint;

  CirclePainter({required this.fraction, Color? circleColor}) {
    _circlePaint = Paint()
      ..color = circleColor ?? Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12.0
      ..strokeCap = StrokeCap.round;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var rect = const Offset(0.0, 0.0) & size;

    canvas.drawArc(rect, -pi / 2, pi * 2 * fraction, false, _circlePaint);
  }

  @override
  bool shouldRepaint(CirclePainter oldDelegate) {
    return oldDelegate.fraction != fraction;
  }
}

class PathPainter extends CustomPainter {
  final Path _path;

  PathPainter(this._path);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.redAccent.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawPath(_path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
