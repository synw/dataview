import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:filesize/filesize.dart' as fs;

class ListedDirectory {
  ListedDirectory(
      {@required this.directory,
      @required this.listedDirectories,
      @required this.listedFiles}) {
    _getItems();
  }

  final Directory directory;
  final List<Directory> listedDirectories;
  final List<File> listedFiles;

  List<DirectoryItem> _items;

  List<DirectoryItem> get items => _items;

  _getItems() {
    var _d = <DirectoryItem>[];
    for (var _item in listedDirectories) {
      _d.add(DirectoryItem(item: _item));
    }
    var _f = <DirectoryItem>[];
    for (var _item in listedFiles) {
      _f.add(DirectoryItem(item: _item));
    }
    _items = new List.from(_d)..addAll(_f);
  }
}

class DirectoryItem {
  DirectoryItem({@required this.item}) {
    _filesize = _getFilesize(item);
    _filename = basename(item.path);
    _icon = _setIcon(item, _filename);
  }

  final FileSystemEntity item;

  String _filename;
  Icon _icon;
  String _filesize = "";

  Icon get icon => _icon;
  String get filesize => _filesize;
  String get filename => _filename;
  bool get isDirectory => item is Directory;

  String _getFilesize(FileSystemEntity _item) {
    if (_item is File) {
      String size = fs.filesize(_item.lengthSync());
      return "$size";
    } else {
      return "";
    }
  }

  Icon _setIcon(dynamic _item, String _filename) {
    Icon _ic;
    if (_item is Directory) {
      _ic = Icon(Icons.folder, color: Colors.yellow);
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
      _ic = Icon(Icons.description, color: Colors.grey);
    }
    return _ic;
  }
}
