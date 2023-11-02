import 'package:catch_timing/stages_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CatchTimingApp());
}

class CatchTimingApp extends StatelessWidget {
  const CatchTimingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '캐치 타이밍',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
      ),
      home: const MainMenuPage(title: '캐치 타이밍 - All you need is timing'),
    );
  }
}

class MainMenuPage extends StatefulWidget {
  const MainMenuPage({super.key, required this.title});

  final String title;

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const StagesPage(),
                  ));
                },
                child: const Text('게임 시작하기')),
            //OutlinedButton(onPressed: () {}, child: const Text('갤러리')),
          ],
        ),
      ),
    );
  }
}
