import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'internal_plugin_method_channel.dart';

abstract class InternalPluginPlatform extends PlatformInterface {
  /// Constructs a InternalPluginPlatform.
  InternalPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static InternalPluginPlatform _instance = MethodChannelInternalPlugin();

  /// The default instance of [InternalPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelInternalPlugin].
  static InternalPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [InternalPluginPlatform] when
  /// they register themselves.
  static set instance(InternalPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
