import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import "models.dart";

Future<bool> rm(DirectoryItem item) async {
  try {
    item.item.delete();
  } catch (e) {
    print("Error deleting the file");
    return false;
  }
  return true;
}

Future<bool> mkdir(String dirPath) async {
  try {
    Directory ddir = await getApplicationDocumentsDirectory();
    Directory dir = Directory(ddir.path + dirPath);
    dir.createSync(recursive: true);
    return true;
  } catch (e) {
    print("Can not create directory");
    print(e);
    return false;
  }
}

Future<List<DirectoryItem>> ls(
    [String path = "/", bool absPath = false]) async {
  String dirpath;
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
  List contents = dir.listSync();
  var dl = <DirectoryItem>[];
  Icon icon = Icon(Icons.description);
  String ftype;
  for (var fileOrDir in contents) {
    if (fileOrDir is Directory) {
      icon = Icon(Icons.folder);
      ftype = "folder";
    } else {
      ftype = "file";
    }
    final String slug = fileOrDir.path.replaceAll(RegExp(dirpath + "/"), '');
    DirectoryItem f = DirectoryItem(fileOrDir, dir, slug, icon, ftype);
    dl.add(f);
  }
  return dl;
}
