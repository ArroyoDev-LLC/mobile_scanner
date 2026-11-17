import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/src/method_channel/mobile_scanner_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MethodChannelMobileScanner platform;
  late List<MethodCall> calls;

  setUp(() {
    platform = MethodChannelMobileScanner();
    calls = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(platform.methodChannel, (call) async {
          calls.add(call);
          return switch (call.method) {
            'setExposureOffset' => -1.0,
            _ => null,
          };
        });
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(platform.methodChannel, null);
  });

  test('setMeteringPoint sends the point', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    await platform.setMeteringPoint(const Offset(0.25, 0.75));

    expect(calls.single.method, 'setMeteringPoint');
    expect(calls.single.arguments, {'dx': 0.25, 'dy': 0.75});
  });

  test('setExposureOffset returns the applied offset', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    final applied = await platform.setExposureOffset(-1.2);

    expect(calls.single.method, 'setExposureOffset');
    expect(calls.single.arguments, -1.2);
    expect(applied, -1.0);
  });

  test('metering is unsupported on desktop', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

    expect(
      () => platform.setMeteringPoint(Offset.zero),
      throwsUnimplementedError,
    );
    expect(() => platform.setExposureOffset(0), throwsUnimplementedError);
  });
}
