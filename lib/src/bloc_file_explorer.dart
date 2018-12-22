import 'dart:async';
import "models.dart";
import "commands.dart";

class ItemsBloc {
  final String path;

  ItemsBloc(this.path) {
    lsDir(this.path);
  }
  final _itemController = StreamController<List<DirectoryItem>>.broadcast();
  get items => _itemController.stream;

  dispose() {
    _itemController.close();
  }

  deleteItem(DirectoryItem item) async {
    bool ok = await rm(item);
    if (ok == false) {
      print("Can not delete item");
      return;
    }
    lsDir(this.path);
  }

  createDir(String dirPath, String dirName) async {
    String path = dirPath + dirName;
    bool ok = await mkdir(path);
    if (ok == false) {
      print("Can not create directory");
      return;
    }
    lsDir(dirPath);
  }

  lsDir([String path = "/"]) async {
    try {
      List<DirectoryItem> dirs = await ls(path);
      _itemController.sink.add(dirs);
    } catch (e) {
      print("Can not ls dir");
      print(e);
    }
  }
}
