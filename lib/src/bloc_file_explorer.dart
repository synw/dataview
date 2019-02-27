import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import "models.dart";
import "commands.dart";

class ItemsBloc {
  ItemsBloc(this.path) {
    getDocumentsDir().then((_) {
      _currentDirectory = Directory(
          _documentsDirectory.path.replaceFirst("/app_flutter", "") + path);
      lsDir(_currentDirectory);
    });
  }

  String path;
  Directory _documentsDirectory;
  Directory _currentDirectory;

  final _itemController = StreamController<List<DirectoryItem>>();

  get items => _itemController.stream;

  Dio dio = Dio(new BaseOptions(
    connectTimeout: 5000,
    headers: {"user-agent": "Dataview"},
  ));

  getDocumentsDir() async {
    _documentsDirectory = await getApplicationDocumentsDirectory();
  }

  dispose() {
    _itemController.close();
  }

  deleteItem(DirectoryItem item) async {
    try {
      await rm(item);
    } catch (e) {
      print("Can not delete directory: $e.message");
    }
  }

  createDir(String name) async {
    try {
      // trim the filename for leading and trailing spaces
      name = name.trim();
      // create the directory
      await mkdir(_currentDirectory, name).then((v) {
        lsDir(_currentDirectory);
      });
    } catch (e) {
      print("Can not create directory: $e.message");
    }
  }

  lsDir([Directory dir]) async {
    try {
      dir = dir ?? _currentDirectory;
      ListedDirectory _d = await getListedDirectory(dir);
      _itemController.sink.add(_d.items);
    } catch (e) {
      print("Can not ls dir: $e.message");
    }
  }
}
