import 'dart:math';
import 'dart:ui';

import 'package:auto_route/annotations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

@RoutePage()
class GamePage extends StatefulWidget {
  final int stageId;

  const GamePage(@PathParam('stageId') this.stageId, {super.key});

  String get fileName => '${stageId.toString().padLeft(2, '0')}.png';

  @override
  State<GamePage> createState() => _GamePageState();
}

enum PathSegmentType {
  line,
  curve,
}

class PathSegment {}

class LinePathSegment extends PathSegment {}

class CurvePathSegment extends PathSegment {}

class _GamePageState extends State<GamePage>
    with SingleTickerProviderStateMixin {
  double _fraction = 0.0;
  late final Animation<double> _animation;
  late final AnimationController _controller;
  late final Path _path;
  late final PathMetric _pathMetric;
  late final Random _random;
  late final Offset _targetPos;
  late final Rect _pathBounds;

  static const _circleSize = Size(100, 100);
  static const _speed = 0.2;

  @override
  void initState() {
    super.initState();

    _createPathData();

    _random = Random();

    //final size = Size(500 - _circleSize.width, 1000 - _circleSize.height);
    const size = Size(640, 960);
    _targetPos = _getRandomPointWithin(size);
    _path = _createPath(size, _targetPos);
    //_path = _createDebugPath(size, _targetPos);
    _pathMetric = _createMetric(_path);
    _pathBounds = _path.getBounds();

    if (kDebugMode) {
      print('Path bounds: ${_path.getBounds()}');
      print('Target pos: $_targetPos');
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

  Path _createDebugPath(Size size, Offset targetPos) {
    final path = Path();
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, 0);
    return path;
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

    final image = Image.asset(
      aligned
          ? 'assets/tests/images/clear/${widget.fileName}'
          : 'assets/tests/images/lock/${widget.fileName}',
      //fit: BoxFit.contain,
      //height: double.infinity,
      //width: double.infinity,
    );

    // final originX =
    //     constraints.constrainWidth() / 2 - _pathBounds.width / 2;
    // final originY =
    //     constraints.constrainHeight() / 2 - _pathBounds.height / 2;

    // final scaleFactor =
    //     1.0; //              constraints.constrainHeight() / _pathBounds.height;

    // if (kDebugMode) {
    //   print(
    //       'Constrain: ${constraints.constrainWidth()} x ${constraints.constrainHeight()}');
    // }

    final targetCenterPos = Offset(
      _targetPos.dx - _circleSize.width / 2,
      _targetPos.dy - _circleSize.height / 2,
    );

    final circleCenterPos = Offset(
      circlePos.dx - _circleSize.width / 2,
      circlePos.dy - _circleSize.height / 2,
    );
    return Scaffold(
      body: Center(
        child: _buildGameWidget(image, targetCenterPos, circleCenterPos),
      ),
    );
  }

  Widget _buildGameWidget(
    Image image,
    Offset targetCenterPos,
    Offset circleCenterPos,
  ) {
    return Stack(
      children: [
        image,
        Positioned.fill(
          child: CustomPaint(
            painter: PathPainter(_path, targetCenterPos, circleCenterPos),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _createPathData() async {
    final imgData =
        await rootBundle.load('assets/tests/images/lock/${widget.fileName}');
    final img = await decodeImageFromList(imgData.buffer.asUint8List());
    if (kDebugMode) {
      print('Image resolution: (${img.width}x${img.height})');
    }
  }
}

// class CirclePainter extends CustomPainter {
//   final double fraction;
//   late final Paint _circlePaint;

//   CirclePainter({required this.fraction, Color? circleColor}) {
//     _circlePaint = Paint()
//       ..color = circleColor ?? Colors.white
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 12.0
//       ..strokeCap = StrokeCap.round;
//   }

//   @override
//   void paint(Canvas canvas, Size size) {
//     var rect = const Offset(0.0, 0.0) & size;

//     final sX = size.width / 640;
//     final sY = size.height / 960;
//     final s = min(sX, sY);

//     if (kDebugMode) {
//       // print('Path painter size: $size');
//       // print('Path painter scale: $s');
//     }

//     canvas.scale(s);

//     canvas.drawArc(rect, -pi / 2, pi * 2 * fraction, false, _circlePaint);
//   }

//   @override
//   bool shouldRepaint(CirclePainter oldDelegate) {
//     return oldDelegate.fraction != fraction;
//   }
// }

class PathPainter extends CustomPainter {
  final Path _path;
  final Offset _targetPos;
  final Offset _circlePos;
  final Size _circleSize = const Size(100, 100);

  late final Paint _circlePaint;
  late final Paint _targetPaint;

  PathPainter(this._path, this._targetPos, this._circlePos) {
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
      ..color = Colors.redAccent.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0;

    final sX = size.width / 640;
    final sY = size.height / 960;
    final s = min(sX, sY);

    if (kDebugMode) {
      print('Path painter size: $size');
      print('Path painter scale: $s');
    }

    var sizeBackground = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color.fromARGB(30, 200, 30, 30)
      ..isAntiAlias = true;

    var background = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color.fromARGB(30, 30, 30, 30)
      ..isAntiAlias = true;

    //
    canvas.scale(s);

    //canvas.translate(0, (960 - size.height) / 2);

    //canvas.drawRect(const Rect.fromLTWH(0, 0, 640, 960), background);

    // canvas.drawRect(
    //     Rect.fromLTWH(0, 0, size.width, size.height), sizeBackground);

    canvas.drawPath(_path, paint);
    canvas.drawArc(
        _targetPos & _circleSize, -pi / 2, pi * 2, false, _targetPaint);
    canvas.drawArc(
        _circlePos & _circleSize, -pi / 2, pi * 2, false, _circlePaint);

    //canvas.translate(size.width / 2, size.height / 2);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
