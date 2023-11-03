import 'package:auto_route/auto_route.dart';
import 'package:catch_timing/catch_timing_app_router.gr.dart';
import 'package:catch_timing/record_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'catch_timing_app_router.dart';

void main() {
  runApp(CatchTimingApp());
}

class CatchTimingApp extends StatelessWidget {
  final _appRouter = CatchTimingAppRouter();

  CatchTimingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ResourceModel()),
        ChangeNotifierProvider(create: (_) => RecordModel()),
      ],
      child: Consumer2<ResourceModel, RecordModel>(
          builder: (context, resourceModel, recordModel, child) {
        resourceModel.tryInit();
        recordModel.tryInit();

        if (resourceModel.inited == true && recordModel.inited == true) {
          return MaterialApp.router(
            routerConfig: _appRouter.config(),
            title: '캐치 타이밍',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
              appBarTheme: const AppBarTheme(
                centerTitle: true,
              ),
              useMaterial3: true,
            ),
          );
        } else {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                  child: Text(resourceModel.inited == false ||
                          recordModel.inited == false
                      ? 'Init failed. Aborted.'
                      : 'Loading...')),
            ),
          );
        }
      }),
    );
  }
}

@RoutePage()
class MainMenuPage extends StatefulWidget {
  const MainMenuPage({super.key});

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Column(
              children: [
                Text('캐치 타이밍', style: Theme.of(context).textTheme.displayLarge),
                Text('All you need is timing',
                    style: Theme.of(context).textTheme.headlineMedium),
              ],
            ),
            OutlinedButton(
                onPressed: () {
                  context.router.push(const StagesRoute());
                },
                child: const Text('게임 시작하기')),
            //OutlinedButton(onPressed: () {}, child: const Text('갤러리')),
          ],
        ),
      ),
    );
  }
}
