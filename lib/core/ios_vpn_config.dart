class IosVpnConfig {
  static const String appGroup = String.fromEnvironment(
    'HUSHNET_IOS_APP_GROUP',
    defaultValue: 'group.com.example.hushnet',
  );

  static const String extensionBundleId = String.fromEnvironment(
    'HUSHNET_IOS_EXTENSION_BUNDLE_ID',
    defaultValue: 'com.example.hushnet.WGExtension',
  );
}
