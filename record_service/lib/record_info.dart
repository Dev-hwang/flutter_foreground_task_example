import 'dart:io';

import 'package:path/path.dart' as p;

class RecordInfo {
  const RecordInfo({
    required this.name,
    required this.path,
  });

  final String name;
  final String path;

  factory RecordInfo.fromFileSystemEntity(FileSystemEntity entity) {
    return RecordInfo(
      name: p.basename(entity.path),
      path: entity.path,
    );
  }
}
