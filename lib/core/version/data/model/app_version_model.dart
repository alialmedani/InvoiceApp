class AppVersionModel {
  final String? appName;
  final String? googlePlayLink;
  final String? appStoreLink;
  final String? version;
  final String? androidVersion;
  final String? iosVersion;
  final String? id;

  AppVersionModel({
    this.appName,
    this.googlePlayLink,
    this.appStoreLink,
    this.version,
    this.androidVersion,
    this.iosVersion,
    this.id,
  });

  // From JSON - Parse API response
  factory AppVersionModel.fromJson(Map<String, dynamic> json) {
    return AppVersionModel(
      appName: json['appName'],
      googlePlayLink: json['googlePlayLink'],
      appStoreLink: json['appStoreLink'],
      version: json['version'],
      androidVersion: json['androidVersion'],
      iosVersion: json['iosVersion'],
      id: json['id'],
    );
  }

  // To JSON - Send to API
  Map<String, dynamic> toJson() {
    return {
      'appName': appName,
      'googlePlayLink': googlePlayLink,
      'appStoreLink': appStoreLink,
      'version': version,
      'androidVersion': androidVersion,
      'iosVersion': iosVersion,
      'id': id,
    };
  }
}
