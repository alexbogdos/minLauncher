import 'dart:typed_data';

import 'package:installed_apps/app_info.dart';

class PackageInfo {
  PackageInfo({
    required this.packageName,
    required this.name,
    this.icon,
    this.score,
    this.lastAccessed,
  }) {
    hasIcon = icon != null && icon!.isNotEmpty;
  }

  String packageName;
  String name;
  late bool hasIcon;
  Uint8List? icon;
  int? score;
  int? lastAccessed;

  int get lastAccessedDiff => (lastAccessed! - DateTime.now().millisecondsSinceEpoch).toInt();

  Map<String, dynamic> toMap() {
    return {
      'package_name': packageName,
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

  factory PackageInfo.fromApp(AppInfo app) {
    return PackageInfo(
      packageName: app.packageName,
      name: app.name,
      icon: app.icon,
      score: null,
      lastAccessed: null,
    );
  }
}
