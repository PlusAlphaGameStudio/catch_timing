import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'catch_timing_app_router.gr.dart';
import 'greyscale_color_filter.dart';

enum StageState {
  lock,
  unlock,
  clear,
}

class StageButton extends StatelessWidget {
  final int stageId;
  final StageState stageState;

  const StageButton(this.stageId, this.stageState, {super.key});

  String get _fileName => '${stageId.toString().padLeft(2, '0')}.png';

  @override
  Widget build(BuildContext context) {
    return stageState == StageState.clear
        ? Image.asset('assets/tests/images/clear/$_fileName')
        : stageState == StageState.unlock
            ? InkWell(
                onTap: () {
                  context.router.push(GameRoute(stageId: stageId));
                },
                child: Image.asset('assets/tests/images/lock/$_fileName'),
              )
            : ImageFiltered(
                imageFilter: greyscaleColorFilter,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Image.asset('assets/tests/images/lock/$_fileName'),
                ),
              );
  }
}
