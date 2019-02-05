import 'dart:io';
import 'dart:async';
import "models.dart";
import "commands.dart";

class ItemsBloc {
  final String path;

  List<Directory> folders;
  List<File> files;

  ItemsBloc(this.path) {
    lsDir(this.path);
  }
  final _itemController = StreamController<List<DirectoryItem>>.broadcast();
  get items => _itemController.stream;

  dispose() {
    _itemController.close();
  }

  deleteItem(DirectoryItem item) async {
    try {
      await rm(item).then((v) {
        lsDir(this.path);
      });
    } catch (e) {
      print("Can not delete directory: $e.message");
    }
  }

  createDir(String dirPath, String dirName) async {
    String path = dirPath + dirName;
    try {
      await mkdir(path).then((v) {
        lsDir(dirPath);
      });
    } catch (e) {
      print("Can not create directory: $e.message");
    }
  }

  lsDir([String path = "/"]) async {
    try {
      List<DirectoryItem> dirs = await ls(path);
      _itemController.sink.add(dirs);
    } catch (e) {
      print("Can not ls dir: $e.message");
    }
  }
}
