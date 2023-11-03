import 'package:another_flushbar/flushbar.dart';
import 'package:auto_route/auto_route.dart';
import 'package:catch_timing/globals.dart';
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

  @override
  Widget build(BuildContext context) {
    return stageState == StageState.clear
        ? InkWell(
            onTap: () {
              context.router.push(GameRoute(stageId: stageId));
            },
            child: Stack(children: [
              Center(child: Image.asset(getClearImagePath(stageId))),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      border: Border.all(),
                      color: Colors.yellow),
                  child: const Text(
                    '클리어🎉',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ]),
          )
        : stageState == StageState.unlock
            ? InkWell(
                onTap: () {
                  context.router.push(GameRoute(stageId: stageId));
                },
                child: Image.asset(getLockImagePath(stageId)),
              )
            : InkWell(
                onTap: () {
                  Flushbar(
                    animationDuration: const Duration(microseconds: 1),
                    flushbarPosition: FlushbarPosition.TOP,
                    flushbarStyle: FlushbarStyle.FLOATING,
                    title: "잠긴 스테이지",
                    message: "아직 깨지 않은 스테이지가 있어요! 스테이지는 순서대로 깨 주세요~",
                    duration: const Duration(seconds: 2),
                    margin: const EdgeInsets.all(8),
                    borderRadius: BorderRadius.circular(8),
                  ).show(context);
                },
                child: Stack(
                  children: [
                    Center(
                      child: ImageFiltered(
                        imageFilter: greyscaleColorFilter,
                        child: Image.asset(getLockImagePath(stageId)),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Colors.black.withOpacity(0.8)),
                    )
                  ],
                ),
              );
  }
}
