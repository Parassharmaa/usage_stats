import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:usage_stats/usage_stats.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List events = [];

  @override
  void initState() {
    super.initState();
    initUsage();
  }

  Future<void> initUsage() async {
    DateTime endDate = new DateTime.now();
    DateTime startDate =
        DateTime(endDate.year, endDate.month, endDate.day, 18, 30, 0);
    print(startDate);
    var queryEvents = await UsageStats.queryEvents(startDate, endDate);
    print(queryEvents.toString());
    this.setState(() {
      events = queryEvents;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Usage Events"),
        ),
        body: ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(events[index]['packageName']),
                subtitle: Text(DateTime.fromMillisecondsSinceEpoch(
                        int.parse(events[index]['timeStamp']))
                    .toString()),
                trailing: Text(events[index]['eventType'].toString()),
              );
            }),
      ),
    );
  }
}
