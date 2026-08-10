/// Entity representing the result of an app version check
class VersionCheckResult {
  final bool needsUpdate;
  final String currentVersion;
  final String latestVersion;
  final String? googlePlayLink;
  final String? appStoreLink;

  VersionCheckResult({
    required this.needsUpdate,
    required this.currentVersion,
    required this.latestVersion,
    this.googlePlayLink,
    this.appStoreLink,
  });
}
