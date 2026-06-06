// Smoke test for the usage_stats example app. The plugin's platform channel is
// mocked so the widget tree builds without a real Android device.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usage_stats_example/main.dart';

void main() {
  const channel = MethodChannel('usage_stats');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      switch (call.method) {
        case 'isUsagePermission':
          return false;
        case 'getAppStandbyBucket':
          return null;
        default:
          return <dynamic>[];
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  testWidgets('renders the tabbed showcase', (tester) async {
    await tester.pumpWidget(const UsageStatsDemoApp());
    await tester.pump();

    expect(find.text('usage_stats'), findsOneWidget);
    expect(find.text('Usage'), findsOneWidget);
    expect(find.text('Apps'), findsOneWidget);
  });
}
