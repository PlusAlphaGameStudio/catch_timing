import 'package:catch_timing/stage_button.dart';
import 'package:flutter/material.dart';

class StagesPage extends StatefulWidget {
  const StagesPage({super.key});

  @override
  State<StagesPage> createState() => _StagesPageState();
}

class _StagesPageState extends State<StagesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('스테이지 선택'),
      ),
      body: GridView.count(
        crossAxisCount: 3,
        children: [for (var i = 1; i <= 4; i++) ...[
          StageButton(i, i == 1 ? StageState.unlock : StageState.lock),
        ]],
      ),
    );
  }
}
