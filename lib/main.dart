import 'package:auto_route/auto_route.dart';
import 'package:catch_timing/catch_timing_app_router.gr.dart';
import 'package:flutter/material.dart';

import 'catch_timing_app_router.dart';

void main() {
  runApp(CatchTimingApp());
}

class CatchTimingApp extends StatelessWidget {
  final _appRouter = CatchTimingAppRouter();

  CatchTimingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _appRouter.config(),
      title: '캐치 타이밍',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
      ),
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
