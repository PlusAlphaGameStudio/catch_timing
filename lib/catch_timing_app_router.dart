import 'package:auto_route/auto_route.dart';

import 'catch_timing_app_router.gr.dart';

@AutoRouterConfig()
class CatchTimingAppRouter extends $CatchTimingAppRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          page: MainMenuRoute.page,
          initial: true,
        ),
        AutoRoute(
          path: '/stages',
          page: StagesRoute.page,
        ),
        AutoRoute(
          path: '/game/:stageId',
          page: GameRoute.page,
        ),
      ];
}
