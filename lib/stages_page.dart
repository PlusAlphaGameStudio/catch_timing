import 'package:auto_route/annotations.dart';
import 'package:catch_timing/stage_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'prefs_key.dart';
import 'record_model.dart';

@RoutePage()
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
      body: Consumer<RecordModel>(
        builder: (context, recordModel, child) {
          final lastClearedStage =
              recordModel.getInt(PrefsKey.lastClearedStage);

          return Consumer<ResourceModel>(
            builder: (context, resourceModel, child) {
              return GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.all(8),
                children: [
                  for (var i = 1; i <= resourceModel.totalImageCount; i++) ...[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: StageButton(
                          i,
                          i <= lastClearedStage
                              ? StageState.clear
                              : i == lastClearedStage + 1
                                  ? StageState.unlock
                                  : StageState.lock),
                    ),
                  ]
                ],
              );
            },
          );
        },
      ),
    );
  }
}
