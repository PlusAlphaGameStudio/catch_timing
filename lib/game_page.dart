import 'dart:math';
import 'dart:ui';

import 'package:auto_route/annotations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'path_painter.dart';

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

// TODO: image size
const _imageSize = Size(640, 960);

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

    _createPathData();

    _random = Random();

    _targetPos = _getRandomPointWithin(_imageSize);
    _path = _createPath(_imageSize, _targetPos);
    //_path = _createDebugPath(size, _targetPos);
    _pathMetric = _createMetric(_path);

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
    );

    final targetCirclePos = Offset(
      _targetPos.dx - _circleSize.width / 2,
      _targetPos.dy - _circleSize.height / 2,
    );

    final crosshairCirclePos = Offset(
      circlePos.dx - _circleSize.width / 2,
      circlePos.dy - _circleSize.height / 2,
    );
    return Scaffold(
      body: Center(
        child: _buildGameWidget(image, targetCirclePos, crosshairCirclePos),
      ),
    );
  }

  Widget _buildGameWidget(
    Image image,
    Offset targetCirclePos,
    Offset crosshairCirclePos,
  ) {
    return Stack(
      children: [
        image,
        Positioned.fill(
          child: CustomPaint(
            painter: PathPainter(
              _imageSize,
              _path,
              targetCirclePos,
              crosshairCirclePos,
            ),
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
