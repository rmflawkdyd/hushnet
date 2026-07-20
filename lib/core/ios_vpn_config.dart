class IosVpnConfig {
  static const String appGroup = String.fromEnvironment(
    'HUSHNET_IOS_APP_GROUP',
    defaultValue: 'group.io.github.rmflawkdyd.hushnet',
  );

  static const String extensionBundleId = String.fromEnvironment(
    'HUSHNET_IOS_EXTENSION_BUNDLE_ID',
    defaultValue: 'io.github.rmflawkdyd.hushnet.WGExtension',
  );
}
