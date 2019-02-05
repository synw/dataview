import 'dart:io';
import 'dart:async';
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
    Directory dir = Directory(dirpath);
    List contents = dir.listSync()..sort((a, b) => a.path.compareTo(b.path));
    var dirs = <Directory>[];
    var files = <File>[];
    for (var fileOrDir in contents) {
      if (fileOrDir is Directory) {
        dirs.add(fileOrDir);
      } else {
        files.add(fileOrDir);
      }
    }
    var dl = <DirectoryItem>[];
    for (var el in dirs) {
      final String slug = el.path.replaceAll(RegExp(dirpath + "/"), '');
      DirectoryItem item = DirectoryItem(el, slug);
      dl.add(item);
    }
    for (var el in files) {
      final String slug = el.path.replaceAll(RegExp(dirpath + "/"), '');
      DirectoryItem item = DirectoryItem(el, slug);
      dl.add(item);
    }
    return dl;
  } catch (e) {
    throw ("Can not list directory: $e");
  }
}
