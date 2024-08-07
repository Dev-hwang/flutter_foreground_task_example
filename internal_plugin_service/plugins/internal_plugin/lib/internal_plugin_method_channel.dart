import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'internal_plugin_platform_interface.dart';

/// An implementation of [InternalPluginPlatform] that uses method channels.
class MethodChannelInternalPlugin extends InternalPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('internal_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
