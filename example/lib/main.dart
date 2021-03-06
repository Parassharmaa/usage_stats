import 'package:flutter/material.dart';
import 'dart:async';
import 'package:usage_stats/usage_stats.dart';
import 'package:usage_stats/src/network_info.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<EventUsageInfo> events = [];
  Map<String, NetworkInfo> _netInfoMap = Map();

  @override
  void initState() {
    super.initState();
    initUsage();
  }

  Future<void> initUsage() async {
    UsageStats.grantUsagePermission();
    DateTime endDate = new DateTime.now();
    DateTime startDate = endDate.subtract(Duration(days: 30));

    List<EventUsageInfo> queryEvents = await UsageStats.queryEvents(startDate, endDate);
    List<NetworkInfo> networkInfos = await UsageStats.queryNetworkUsageStats(startDate, endDate);
    Map<String, NetworkInfo> netInfoMap = Map.fromIterable(networkInfos, key: (v) => v.packageName, value: (v) => v);

    this.setState(() {
      events = queryEvents.reversed.toList();
      _netInfoMap = netInfoMap;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Usage Stats"),
        ),
        body: Container(
            child: ListView.separated(
                itemBuilder: (context, index) {
                  var event = events[index];
                  var networkInfo = _netInfoMap[event.packageName];
                  return ListTile(
                    title: Text(events[index].packageName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "Last time used: ${DateTime.fromMillisecondsSinceEpoch(int.parse(events[index].timeStamp)).toIso8601String()}"),
                        networkInfo == null
                            ? Text("Unknown network usage")
                            : Text("Received bytes: ${networkInfo.rxTotalBytes}\n" +
                                "Transfered bytes : ${networkInfo.txTotalBytes}"),
                      ],
                    ),
                    trailing: Text(events[index].eventType),
                  );
                },
                separatorBuilder: (context, index) => Divider(),
                itemCount: events.length)),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            initUsage();
          },
          child: Icon(
            Icons.refresh,
          ),
          mini: true,
        ),
      ),
    );
  }
}
