import 'dart:io';
import 'package:path_provider/path_provider.dart';
import "models.dart";

Future<void> rm(DirectoryItem item) async {
  try {
    item.item.delete(recursive: true);
  } catch (e) {
    throw ("Error deleting the file: $e");
  }
}

Future<void> mkdir(String dirPath) async {
  try {
    Directory ddir = await getApplicationDocumentsDirectory();
    Directory dir = Directory(ddir.path + dirPath);
    dir.createSync(recursive: true);
  } catch (e) {
    throw ("Can not create directory: $e");
  }
}

Future<List<DirectoryItem>> ls(
    [String path = "/", bool absPath = false]) async {
  String dirpath;
  try {
    if (absPath == false) {
      Directory ddir = await getApplicationDocumentsDirectory();
      if (path == "/") {
        dirpath = ddir.path;
      } else {
        dirpath = ddir.path + path;
      }
    } else {
      dirpath = path;
    }
    print("LS " + dirpath);

    Directory dir = Directory(dirpath);
    List contents = dir.listSync()..sort((a, b) => a.path.compareTo(b.path));
    var dl = <DirectoryItem>[];
    String ftype;
    for (var fileOrDir in contents) {
      final String slug = fileOrDir.path.replaceAll(RegExp(dirpath + "/"), '');
      DirectoryItem f = DirectoryItem(fileOrDir, slug);
      dl.add(f);
    }
    return dl;
  } catch (e) {
    throw ("Can not list directory: $e");
  }
}
