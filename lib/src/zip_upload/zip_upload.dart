import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:archive/archive_io.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:filesize/filesize.dart' as fs;
import '../models.dart';

class ZipUpload {
  ZipUpload();

  static File zip({@required DirectoryItem directory}) {
    var encoder = ZipFileEncoder();
    String basename = path.basename(directory.path);
    popMsg("Processing for $basename");
    String endPath = "${directory.parent.path}/${directory.filename}.zip";
    print("ZIPPING $endPath");
    var timer = Stopwatch()..start();
    try {
      encoder.zipDirectory(directory.item, filename: endPath);
    } catch (e) {
      popMsg("Error zipping: ${e.message}");
      throw (e);
    }
    timer.stop();
    File file = File(endPath);
    String fileSize = fs.filesize(file);
    print("END ZIPPING in ${timer.elapsedMilliseconds} ms ( $fileSize )");
    if (timer.elapsedMicroseconds > 1000)
      popMsg("Directory zipped ( $fileSize ), uploading");
    return file;
  }

  static upload({@required File file, String serverUrl}) async {
    try {
      if (!file.existsSync()) throw ("File ${file.path} not found");
      var dio = Dio();
      String filename = path.basename(file.path);
      FormData formData =
          FormData.from({"file": UploadFileInfo(file, filename)});
      var response = await dio.post(serverUrl, data: formData);
      return response.statusCode;
    } catch (e) {
      popMsg("Can not upload: ${e.message}");
      throw (e);
    }
  }

  static zipUpload({@required DirectoryItem directory, String serverUrl}) {
    File file = zip(directory: directory);
    var timer = Stopwatch()..start();
    print("UPLOADING ZIP FILE");
    upload(file: file, serverUrl: serverUrl).then((_) {
      timer.stop();
      popMsg("File uploaded", finished: true);
      print("FILE UPLOADED in ${timer.elapsedMilliseconds} ms");
      file.delete();
    });
  }
}

popMsg(String msg, {bool finished = false, error = false}) async {
  Color color = Colors.yellow;
  Color txtColor = Colors.black;
  var duration = Toast.LENGTH_SHORT;
  if (finished) {
    color = Colors.green;
    txtColor = Colors.white;
  }
  if (error) {
    color = Colors.green;
    txtColor = Colors.white;
    duration = Toast.LENGTH_LONG;
  }
  Fluttertoast.showToast(
    msg: msg,
    backgroundColor: color,
    textColor: txtColor,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
  );
}
