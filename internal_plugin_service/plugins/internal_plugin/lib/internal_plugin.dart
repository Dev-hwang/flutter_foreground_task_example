import 'internal_plugin_platform_interface.dart';

class InternalPlugin {
  Future<String?> getPlatformVersion() {
    return InternalPluginPlatform.instance.getPlatformVersion();
  }
}
