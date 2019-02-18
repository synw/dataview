import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import "models.dart";
import "commands.dart";
import 'exceptions.dart';

class ItemsBloc {
  ItemsBloc(this.path) {
    getDocumentsDir().then((_) {
      _currentDirectory = Directory(_documentsDirectory.path + path);
      lsDir(_currentDirectory);
    });
  }

  String path;
  Directory _documentsDirectory;
  Directory _currentDirectory;

  final _itemController = StreamController<List<DirectoryItem>>.broadcast();

  get items => _itemController.stream;

  Dio dio = Dio();

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

  upload({String serverUrl, File file, String filename}) async {
    try {
      if (file.existsSync() == false) {
        throw FileNotFound("File ${file.path} does not exist");
      }
      print("Uploading ${file.path} to $serverUrl");
      FormData formData =
          FormData.from({"file": UploadFileInfo(file, filename)});
      var response = await dio.post(serverUrl, data: formData).catchError((e) {
        throw (e);
      });
      if (response.statusCode == 200) {
        Fluttertoast.showToast(
            msg: "File uploaded",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        Fluttertoast.showToast(
            msg: "Response status code: ${response.statusCode}",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 3,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } on DioError catch (e) {
      Fluttertoast.showToast(
          msg: "Error ${e.message}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 3,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } catch (e) {
      throw (e);
    }
  }
}
