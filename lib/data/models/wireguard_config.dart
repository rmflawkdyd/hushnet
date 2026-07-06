class WireGuardConfig {
  const WireGuardConfig({
    required this.name,
    required this.serverAddress,
    required this.wgQuickConfig,
    this.providerBundleIdentifier = '',
  });

  final String name;

  final String serverAddress;

  final String wgQuickConfig;

  final String providerBundleIdentifier;
}
