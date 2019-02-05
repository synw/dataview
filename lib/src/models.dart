import 'dart:io';
import 'package:flutter/material.dart';
import 'package:filesize/filesize.dart' as fs;

class DirectoryItem {
  DirectoryItem(this.item, this.filename)
      : icon = setIcon(item, filename),
        filesize = _getFilesize(item);

  final dynamic item;
  final String filename;
  Icon icon;
  String filesize = "";

  bool get isDirectory => item is Directory;

  static String _getFilesize(dynamic _item) {
    if (_item is File) {
      String size = fs.filesize(_item.lengthSync());
      return "$size";
    } else {
      return "";
    }
  }

  static Icon setIcon(dynamic _item, String _filename) {
    Icon icon;
    if (_item is Directory) {
      icon = Icon(Icons.folder, color: Colors.yellow);
    } else {
      // special cases
      String extension = _filename.split(".").last;
      if (extension == "db" ||
          extension == "sqlite" ||
          extension == "sqlite3") {
        return Icon(Icons.dns);
      } else if (extension == "jpg" ||
          extension == "jpeg" ||
          extension == "png") {
        return Icon(Icons.image);
      }
      // default
      icon = Icon(Icons.description, color: Colors.grey);
    }
    return icon;
  }
}
