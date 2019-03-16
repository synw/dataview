import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import "models.dart";
import "commands.dart";

class ItemsBloc {
  ItemsBloc(this.path) {
    getDocumentsDir().then((dynamic _) {
      _currentDirectory = Directory(
          _documentsDirectory.path.replaceFirst("/app_flutter", "") + path);
      lsDir(_currentDirectory);
    });
  }

  final String path;
  Directory _documentsDirectory;
  Directory _currentDirectory;

  final _itemController = StreamController<List<DirectoryItem>>();

  Stream<List<DirectoryItem>> get items => _itemController.stream;

  Dio dio = Dio(BaseOptions(
    connectTimeout: 5000,
    headers: <String, dynamic>{"user-agent": "Dataview"},
  ));

  Future<void> getDocumentsDir() async {
    _documentsDirectory = await getApplicationDocumentsDirectory();
  }

  void dispose() {
    _itemController.close();
  }

  Future<void> deleteItem(DirectoryItem item) async {
    try {
      await rm(item);
    } catch (e) {
      print("Can not delete directory: $e.message");
    }
  }

  Future<void> createDir(String name) async {
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

  Future<void> lsDir([Directory dir]) async {
    try {
      dir = dir ?? _currentDirectory;
      ListedDirectory _d = await getListedDirectory(dir);
      _itemController.sink.add(_d.items);
    } catch (e) {
      print("Can not ls dir: $e.message");
    }
  }
}
