class AppVersion {
  final String latestVersion;
  final String minRequiredVersion;
  final bool forceUpdate;
  final String updateMessage;
  final String androidUrl;
  final String iosUrl;

  AppVersion({
    required this.latestVersion,
    required this.minRequiredVersion,
    required this.forceUpdate,
    required this.updateMessage,
    required this.androidUrl,
    required this.iosUrl,
  });

  factory AppVersion.fromJson(Map<String, dynamic> json) {
    return AppVersion(
      latestVersion: json['latest_version'] ?? '1.0.0',
      minRequiredVersion: json['min_required_version'] ?? '1.0.0',
      forceUpdate: json['force_update'] ?? false,
      updateMessage: json['update_message'] ?? 'A new version is available',
      androidUrl: json['android_url'] ?? '',
      iosUrl: json['ios_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latest_version': latestVersion,
      'min_required_version': minRequiredVersion,
      'force_update': forceUpdate,
      'update_message': updateMessage,
      'android_url': androidUrl,
      'ios_url': iosUrl,
    };
  }
}
