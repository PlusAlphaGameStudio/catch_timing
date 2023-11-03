import 'dart:math';
import 'dart:ui';

import 'package:another_flushbar/flushbar.dart';
import 'package:auto_route/annotations.dart';
import 'package:catch_timing/globals.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'path_painter.dart';
import 'prefs_key.dart';
import 'record_model.dart';

@RoutePage()
class GamePage extends StatefulWidget {
  final int stageId;

  const GamePage(@PathParam('stageId') this.stageId, {super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

enum PathSegmentType {
  line,
  curve,
}

// TODO: image size
const _imageSize = Size(640, 960);

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  double _fraction = 0.0;
  late final Animation<double> _moveAnim;
  late final AnimationController _moveAnimCtrl;
  double _alpha = 1.0;
  late final Animation<double> _alphaAnim;
  late final AnimationController _alphaAnimCtrl;
  late final AnimationController _tapCoolAnimCtrl;
  late final Path _path;
  late final PathMetric _pathMetric;
  late final Random _random;
  late final Offset _targetPos;
  var _precacheFinished = false;
  var _cleared = false;
  var _manualToggled = false;

  static const _circleRadius = 50.0;
  static const _circleSize = Size(_circleRadius, _circleRadius);
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

    _initMoveAnimCtrl();
    _initAlphaAnimCtrl();
    _initTapCoolAnimCtrl();

    _cleared = widget.stageId <=
        context.read<RecordModel>().getInt(PrefsKey.lastClearedStage);

    if (_cleared == false) {
      Future.delayed(Duration.zero, () {
        _showStartDialog();
      });
    } else {
      _alpha = 0;
    }

    Future.delayed(Duration.zero, _precacheResources);
  }

  void _showStartDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('준비~'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('$_stageName 시작합니다~'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('시작!!!'),
              onPressed: () {
                Navigator.of(context).pop();
                _moveAnimCtrl.repeat();
              },
            ),
          ],
        );
      },
    );
  }

  void _initMoveAnimCtrl() {
    _moveAnimCtrl = AnimationController(
        duration: Duration(milliseconds: (_pathMetric.length / _speed).round()),
        vsync: this);

    _moveAnim = Tween(begin: 0.0, end: 1.0).animate(_moveAnimCtrl)
      ..addListener(() {
        setState(() {
          _fraction = _moveAnim.value;
        });
      });
  }

  void _initAlphaAnimCtrl() {
    _alphaAnimCtrl =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);

    _alphaAnim = Tween(begin: 1.0, end: 0.0).animate(_alphaAnimCtrl)
      ..addListener(() {
        setState(() {
          _alpha = _alphaAnim.value;
        });
      });
  }

  Offset _getRandomPointWithin(Size size) {
    return Offset(
        _random.nextDouble() * size.width, _random.nextDouble() * size.height);
  }

  // Path _createDebugPath(Size size, Offset targetPos) {
  //   final path = Path();
  //   path.lineTo(size.width, 0);
  //   path.lineTo(size.width, size.height);
  //   path.lineTo(0, size.height);
  //   path.lineTo(0, 0);
  //   return path;
  // }

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

    final hit = (circlePos - _targetPos).distance < 10;

    final lockImage = Image.asset(getLockImagePath(widget.stageId));
    final clearImage = Image.asset(getClearImagePath(widget.stageId));

    var image = (hit || _cleared) ? clearImage : lockImage;
    if (_manualToggled) {
      if (image == clearImage) {
        image = lockImage;
      } else if (image == lockImage) {
        image = clearImage;
      }
    }

    final targetCirclePos = Offset(
      _targetPos.dx - _circleSize.width / 2,
      _targetPos.dy - _circleSize.height / 2,
    );

    final crosshairCirclePos = Offset(
      circlePos.dx - _circleSize.width / 2,
      circlePos.dy - _circleSize.height / 2,
    );
    return Scaffold(
      appBar: AppBar(title: Text(_stageName)),
      body: Center(
        child: _precacheFinished
            ? _buildGameWidget(image, targetCirclePos, crosshairCirclePos, hit)
            : const Text('Loading...'),
      ),
    );
  }

  String get _stageName => '스테이지 ${widget.stageId.toString().padLeft(2, '0')}';

  Widget _buildGameWidget(
    Widget image,
    Offset targetCirclePos,
    Offset crosshairCirclePos,
    bool hit,
  ) {
    return Stack(
      children: [
        image,
        Positioned.fill(
          child: Opacity(
            opacity: _alpha,
            child: CustomPaint(
              painter: PathPainter(
                _imageSize,
                _path,
                _circleSize,
                targetCirclePos,
                crosshairCirclePos,
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: GestureDetector(
            onTapDown: (details) async {
              // 이미 클리어!
              if (_cleared) {
                return;
              }

              if (_moveAnimCtrl.isAnimating == false) {
                _moveAnimCtrl.repeat();
                return;
              } else {
                // 탭 쿨 중이 아닐 때만 멈출 수 있다.
                if (_tapCoolAnimCtrl.isAnimating == false) {
                  _moveAnimCtrl.stop(canceled: false);
                } else {
                  return;
                }
              }

              _tapCoolAnimCtrl.reset();

              ScaffoldMessenger.of(context).clearSnackBars();

              if (hit) {
                _cleared = true;

                _showClearDialog();

                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Hit!')));

                final recordModel = context.read<RecordModel>();

                await recordModel.setInt(
                    PrefsKey.lastClearedStage,
                    max(recordModel.getInt(PrefsKey.lastClearedStage),
                        widget.stageId));
              } else {
                Flushbar(
                  animationDuration: const Duration(microseconds: 1),
                  flushbarPosition: FlushbarPosition.TOP,
                  flushbarStyle: FlushbarStyle.FLOATING,
                  title: "아앗",
                  message: "좀 더 정확하게!",
                  duration: const Duration(seconds: 1),
                  margin: const EdgeInsets.all(8),
                  borderRadius: BorderRadius.circular(8),
                ).show(context);

                _tapCoolAnimCtrl.forward();
                // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                //   behavior: SnackBarBehavior.floating,
                //   margin: EdgeInsets.only(top: 0),
                //   dismissDirection: DismissDirection.none,
                //   content: Text('Miss'),
                //   duration: Duration(milliseconds: 250),
                // ));
              }
            },
          ),
        ),
        if (_cleared) ...[
          Positioned(
            right: 0,
            top: 0,
            child: IconButton(
              icon: const Icon(
                Icons.switch_account,
                shadows: [Shadow(color: Colors.white, blurRadius: 15.0)],
              ),
              onPressed: () {
                setState(() {
                  _manualToggled = !_manualToggled;
                });
              },
            ),
          ),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _moveAnimCtrl.dispose();
    super.dispose();
  }

  void _createPathData() async {
    final imgData = await rootBundle.load(getLockImagePath(widget.stageId));
    final img = await decodeImageFromList(imgData.buffer.asUint8List());
    if (kDebugMode) {
      print('Image resolution: (${img.width}x${img.height})');
    }
  }

  void _showClearDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('클리어!🎉'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('$_stageName 클리어~~~'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
                _alphaAnimCtrl.forward();
              },
            ),
          ],
        );
      },
    );
  }

  void _initTapCoolAnimCtrl() {
    _tapCoolAnimCtrl = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
  }

  void _precacheResources() async {
    await precacheImage(AssetImage(getLockImagePath(widget.stageId)), context);
    if (context.mounted) {
      await precacheImage(
          AssetImage(getClearImagePath(widget.stageId)), context);
      setState(() {
        _precacheFinished = true;
      });
    }
  }
}
