import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';
import 'package:archive/archive_io.dart';
import 'package:dio/dio.dart';
import 'package:filesize/filesize.dart' as fs;
import 'package:filex/filex.dart';
import 'package:pedantic/pedantic.dart';
import '../exceptions.dart';
import '../logger.dart';

var dio = Dio();

Future<File> zip(
    {@required DirectoryItem directory, @required BuildContext context}) async {
  var encoder = ZipFileEncoder();
  final basename = path.basename(directory.path);
  unawaited(log.infoFlash("Zipping $basename"));
  final endPath = "${directory.parent.path}/${directory.filename}.zip";
  var timer = Stopwatch()..start();
  try {
    encoder.zipDirectory(Directory(directory.item.path), filename: endPath);
  } catch (e) {
    final msg = "Error zipping: ${e.message}";
    unawaited(log.errorScreen(msg, context: context));
    return null;
  }
  timer.stop();
  final file = File(endPath);
  String fileSize;
  try {
    fileSize = fs.filesize(file.lengthSync());
  } catch (e) {
    final msg = "Can not calculate filesize: ${e.message}";
    unawaited(log.errorScreen(msg, context: context));
    return null;
  }
  unawaited(log
      .debug("END ZIPPING in ${timer.elapsedMilliseconds} ms ( $fileSize )"));
  if (timer.elapsedMicroseconds > 1000) {
    unawaited(log.infoFlash("Directory zipped ( $fileSize ), uploading"));
  }
  return file;
}

Future<bool> upload(
    {@required String serverUrl,
    @required File file,
    @required String filename,
    @required BuildContext context}) async {
  dynamic response;
  if (file.existsSync() == false) {
    var ex = FileNotFound("File ${file.path} does not exist");
    unawaited(log.errorScreen("${ex.message}", context: context));
    return false;
  }
  var timer = Stopwatch()..start();
  final formData =
      FormData.from(<String, dynamic>{"file": UploadFileInfo(file, filename)});
  try {
    //print("URL $serverUrl");
    //print("FORM $formData");
    response = await dio.post<dynamic>(serverUrl, data: formData);
  } on DioError catch (e) {
    final msg = "Can not upload: ${e.type} : ${e.message}";
    unawaited(log.errorScreen(msg, context: context));
    return false;
  } catch (e) {
    final msg = "Can not upload: ${e.message}";
    unawaited(log.errorScreen(msg, context: context));
    return false;
  }
  if (response != null) {
    if (response.statusCode != 200) {
      final msg = "Response status code: ${response.statusCode}";
      unawaited(log.errorScreen(msg, context: context));
      return false;
    }
  }
  timer.stop();
  final elapsed = (timer.elapsedMilliseconds / 1000).toStringAsFixed(1);
  unawaited(log.infoScreen("File uploaded in $elapsed s", context: context));
  return true;
}

Future<void> zipUpload(
    {@required DirectoryItem directory,
    @required String serverUrl,
    @required BuildContext context}) async {
  File file;
  try {
    file = await zip(directory: directory, context: context);
  } catch (e) {
    final msg = "Can not zip directory: ${e.message}";
    unawaited(log.errorScreen(msg, context: context));
    return null;
  }
  if (file == null) return null;
  final filename = path.basename(file.path);
  final ok = await upload(
      file: file, serverUrl: serverUrl, filename: filename, context: context);
  if (!ok) {
    return null;
  }
  try {
    file.deleteSync();
  } catch (e) {
    final msg = "Can not delete file: ${e.message}";
    unawaited(log.errorScreen(msg, context: context));
  }
}
