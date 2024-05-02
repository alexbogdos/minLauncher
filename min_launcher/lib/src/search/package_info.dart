import 'dart:typed_data';

import 'package:installed_apps/app_info.dart';

class PackageInfo implements Comparable {
  PackageInfo({
    required this.packageName,
    this.name,
    this.icon,
    this.score,
    this.lastAccessed,
  }) {
    hasIcon = icon != null && icon!.isNotEmpty;
  }

  String packageName;
  String? name;
  late bool hasIcon;
  Uint8List? icon;
  int? score;
  int? lastAccessed;

  int get lastAccessedDiff => (lastAccessed! - DateTime.now().millisecondsSinceEpoch).toInt();

  void launch() {
    lastAccessed = DateTime.now().millisecondsSinceEpoch;
    if (score != null) {
      score = score! + 1;
    } else {
      score = 1;
    }
  }

  bool get active => score != null && lastAccessed != null;

  double get frecency {
    if (!active) return 0;

    Duration diff = Duration(
        milliseconds: DateTime.now().millisecondsSinceEpoch - lastAccessed!);

    if (diff.inHours < 1) {
      // Within the last hour
      return score! * 4;
    } else if (diff.inDays < 1) {
      // Within the last day
      return score! * 2;
    } else if (diff.inDays < 8) {
      // Within the last week
      return score! / 2;
    } else {
      return score! / 4;
    }
  }

  @override
  String toString() {
    return "$name, \t$frecency";
  }

  @override
  int compareTo(other) {
    int diff = (other.frecency - frecency).sign.toInt();
    if (diff != 0) {
      return diff;
    }
    else if (other.name != null && name != null) {
      return name!.compareTo(other.name!);
    }
    return 0;
  }

  int compareNameTo(other) {
    if (other.name != null && name != null) {
      return name!.compareTo(other.name!);
    }
    return 0;
  }

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
