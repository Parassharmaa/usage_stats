import 'package:flutter/material.dart';
import 'package:usage_stats/usage_stats.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  bool isGranted = false;
  List<EventUsageInfo> events = [];
  Map<String?, NetworkInfo?> _netInfoMap = {};

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      final newGranted = await UsageStats.checkUsagePermission() ?? false;
      if (newGranted != isGranted) {
        setState(() {
          isGranted = newGranted;
        });
        if (isGranted) {
          initUsage();
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    initUsage();
  }

  Future<void> initUsage() async {
    isGranted = await UsageStats.checkUsagePermission() ?? false;
    if (isGranted) {
      try {
        DateTime endDate = DateTime.now();
        DateTime startDate = endDate.subtract(const Duration(days: 1));

        List<EventUsageInfo> queryEvents =
            await UsageStats.queryEvents(startDate, endDate);
        List<NetworkInfo> networkInfos =
            await UsageStats.queryNetworkUsageStats(
          startDate,
          endDate,
          networkType: NetworkType.all,
        );

        var netInfoMap = {for (var v in networkInfos) v.packageName: v};

        var t = await UsageStats.queryUsageStats(startDate, endDate);

        for (var i in t) {
          if (double.parse(i.totalTimeInForeground!) > 0) {
            print(DateTime.fromMillisecondsSinceEpoch(
                    int.parse(i.firstTimeStamp!))
                .toIso8601String());

            print(
                DateTime.fromMillisecondsSinceEpoch(int.parse(i.lastTimeStamp!))
                    .toIso8601String());

            print(i.packageName);
            print(
                DateTime.fromMillisecondsSinceEpoch(int.parse(i.lastTimeUsed!))
                    .toIso8601String());
            print(int.parse(i.totalTimeInForeground!) / 1000 / 60);

            print('-----\n');
          }
        }

        setState(() {
          events = queryEvents.reversed.toList();
          _netInfoMap = netInfoMap;
        });
      } catch (err) {
        print(err);
      }
    } else {
      UsageStats.grantUsagePermission();
    }
  }

  Widget info() {
    return Expanded(
      child: ListView.separated(
        itemBuilder: (context, index) {
          var event = events[index];
          var networkInfo = _netInfoMap[event.packageName];
          return ListTile(
            title: Text(events[index].packageName!),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    "Last time used: ${DateTime.fromMillisecondsSinceEpoch(int.parse(events[index].timeStamp!)).toIso8601String()}"),
                networkInfo == null
                    ? const Text("Unknown network usage")
                    : Text("Received bytes: ${networkInfo.rxTotalBytes}\n" +
                        "Transfered bytes : ${networkInfo.txTotalBytes}"),
              ],
            ),
            trailing: Text(events[index].eventType!),
          );
        },
        separatorBuilder: (context, index) => const Divider(),
        itemCount: events.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextButton(
            onPressed: initUsage,
            child: const Text('info'),
          ),
          info(),
        ],
      ),
    );
  }
}
