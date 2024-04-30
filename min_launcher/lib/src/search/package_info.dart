import 'package:installed_apps/app_info.dart';

class PackageInfo {
  PackageInfo({
    required this.packageName,
    required this.name,
    this.score,
    this.lastAccessed,
  });

  String packageName;
  String name;
  int? score;
  int? lastAccessed;



  Map<String, dynamic> toMap() {
    return {
      'package_name': packageName,
      'name': name,
      'score': score,
      'last_accessed': lastAccessed,
    };
  }

  factory PackageInfo.fromMap(Map<String, dynamic> map) {
    return PackageInfo(
      packageName: map['package_name'],
      name: map['name'],
      score: map['score'],
      lastAccessed: map['last_accessed'],
    );
  }

  factory PackageInfo.fromAppInfo(AppInfo app) {
    return PackageInfo(
      packageName: app.packageName,
      name: app.name,
      score: null,
      lastAccessed: null,
    );
  }
}
