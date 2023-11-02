// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i4;
import 'package:catch_timing/game_page.dart' as _i1;
import 'package:catch_timing/main.dart' as _i2;
import 'package:catch_timing/stages_page.dart' as _i3;
import 'package:flutter/material.dart' as _i5;

abstract class $CatchTimingAppRouter extends _i4.RootStackRouter {
  $CatchTimingAppRouter({super.navigatorKey});

  @override
  final Map<String, _i4.PageFactory> pagesMap = {
    GameRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<GameRouteArgs>(
          orElse: () => GameRouteArgs(stageId: pathParams.getInt('stageId')));
      return _i4.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i1.GamePage(
          args.stageId,
          key: args.key,
        ),
      );
    },
    MainMenuRoute.name: (routeData) {
      return _i4.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i2.MainMenuPage(),
      );
    },
    StagesRoute.name: (routeData) {
      return _i4.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i3.StagesPage(),
      );
    },
  };
}

/// generated route for
/// [_i1.GamePage]
class GameRoute extends _i4.PageRouteInfo<GameRouteArgs> {
  GameRoute({
    required int stageId,
    _i5.Key? key,
    List<_i4.PageRouteInfo>? children,
  }) : super(
          GameRoute.name,
          args: GameRouteArgs(
            stageId: stageId,
            key: key,
          ),
          rawPathParams: {'stageId': stageId},
          initialChildren: children,
        );

  static const String name = 'GameRoute';

  static const _i4.PageInfo<GameRouteArgs> page =
      _i4.PageInfo<GameRouteArgs>(name);
}

class GameRouteArgs {
  const GameRouteArgs({
    required this.stageId,
    this.key,
  });

  final int stageId;

  final _i5.Key? key;

  @override
  String toString() {
    return 'GameRouteArgs{stageId: $stageId, key: $key}';
  }
}

/// generated route for
/// [_i2.MainMenuPage]
class MainMenuRoute extends _i4.PageRouteInfo<void> {
  const MainMenuRoute({List<_i4.PageRouteInfo>? children})
      : super(
          MainMenuRoute.name,
          initialChildren: children,
        );

  static const String name = 'MainMenuRoute';

  static const _i4.PageInfo<void> page = _i4.PageInfo<void>(name);
}

/// generated route for
/// [_i3.StagesPage]
class StagesRoute extends _i4.PageRouteInfo<void> {
  const StagesRoute({List<_i4.PageRouteInfo>? children})
      : super(
          StagesRoute.name,
          initialChildren: children,
        );

  static const String name = 'StagesRoute';

  static const _i4.PageInfo<void> page = _i4.PageInfo<void>(name);
}
