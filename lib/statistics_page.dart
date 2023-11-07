import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'globals.dart';

@RoutePage()
class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  Map<String, dynamic>? data;

  @override
  void initState() {
    super.initState();
    _query().then((response) {
      setState(() {
        data = jsonDecode(response.body);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('통계'),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Row(
            children: [
              const Spacer(),
              Column(
                //crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DataTable(
                    columns: const [
                      DataColumn(
                        label: Expanded(
                          child: Text('스테이지'),
                        ),
                      ),
                      DataColumn(
                        label: Expanded(
                          child: Text('시작'),
                        ),
                      ),
                      DataColumn(
                        label: Expanded(
                          child: Text('클리어'),
                        ),
                      ),
                    ],
                    rows: [
                      for (var i = 0;
                          i < (data?['start'].length ?? 0);
                          i++) ...[
                        DataRow(
                          cells: <DataCell>[
                            DataCell(Text((i + 1).toString())),
                            DataCell(Text(data?['start'][i]?.toString() ?? '')),
                            DataCell(Text(data?['clear'][i]?.toString() ?? '')),
                          ],
                        ),
                      ]
                    ],
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Future<http.Response> _query() {
    return http.get(Uri.parse('$baseUrl/catchTiming/statistics'));
  }
}
