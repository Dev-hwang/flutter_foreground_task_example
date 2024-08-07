import 'package:flutter_test/flutter_test.dart';
import 'package:internal_plugin/internal_plugin.dart';
import 'package:internal_plugin/internal_plugin_platform_interface.dart';
import 'package:internal_plugin/internal_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockInternalPluginPlatform
    with MockPlatformInterfaceMixin
    implements InternalPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final InternalPluginPlatform initialPlatform = InternalPluginPlatform.instance;

  test('$MethodChannelInternalPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelInternalPlugin>());
  });

  test('getPlatformVersion', () async {
    InternalPlugin internalPlugin = InternalPlugin();
    MockInternalPluginPlatform fakePlatform = MockInternalPluginPlatform();
    InternalPluginPlatform.instance = fakePlatform;

    expect(await internalPlugin.getPlatformVersion(), '42');
  });
}
