import 'package:flutter/material.dart';

class GamePage extends StatefulWidget {
  final int stageId;

  const GamePage(this.stageId, {super.key});

  String get fileName => '${stageId.toString().padLeft(2, '0')}.png';

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [Image.asset('assets/tests/images/lock/${widget.fileName}')],
    );
  }
}
