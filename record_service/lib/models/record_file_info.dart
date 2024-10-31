import 'dart:io';

import 'package:path/path.dart' as p;

class RecordFileInfo {
  const RecordFileInfo({
    required this.name,
    required this.path,
  });

  final String name;
  final String path;

  factory RecordFileInfo.fromFileSystemEntity(FileSystemEntity entity) {
    return RecordFileInfo(
      name: p.basename(entity.path),
      path: entity.path,
    );
  }
}
