import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';
import 'package:archive/archive_io.dart';
import 'package:dio/dio.dart';
import 'package:filesize/filesize.dart' as fs;
import '../models.dart';
import '../exceptions.dart';
import '../logger.dart';

var dio = Dio();

Future<File> zip(
    {@required DirectoryItem directory, @required BuildContext context}) async {
  var encoder = ZipFileEncoder();
  String basename = path.basename(directory.path);
  log.infoFlash("Zipping $basename");
  String endPath = "${directory.parent.path}/${directory.filename}.zip";
  var timer = Stopwatch()..start();
  try {
    encoder.zipDirectory(directory.item, filename: endPath);
  } catch (e) {
    String msg = "Error zipping: ${e.message}";
    log.error(msg, context);
    return null;
  }
  timer.stop();
  File file = File(endPath);
  String fileSize;
  try {
    fileSize = fs.filesize(file.lengthSync());
  } catch (e) {
    String msg = "Can not calculate filesize: ${e.message}";
    log.error(msg, context);
    return null;
  }
  log.debug("END ZIPPING in ${timer.elapsedMilliseconds} ms ( $fileSize )");
  if (timer.elapsedMicroseconds > 1000)
    log.infoFlash("Directory zipped ( $fileSize ), uploading");
  return file;
}

Future<bool> upload(
    {@required String serverUrl,
    @required File file,
    @required String filename,
    @required BuildContext context}) async {
  var response;
  if (file.existsSync() == false) {
    var ex = FileNotFound("File ${file.path} does not exist");
    log.error("${ex.message}", context);
    return false;
  }
  var timer = Stopwatch()..start();
  FormData formData = FormData.from({"file": UploadFileInfo(file, filename)});
  try {
    print("URL $serverUrl");
    print("FORM $formData");
    response = await dio.post(serverUrl, data: formData);
  } on DioError catch (e) {
    String msg = "Can not upload: ${e.type} : ${e.message}";
    log.error(msg, context);
    return false;
  } catch (e) {
    String msg = "Can not upload: ${e.message}";
    log.error(msg, context);
    return false;
  }
  if (response != null) {
    if (response.statusCode != 200) {
      String msg = "Response status code: ${response.statusCode}";
      log.error(msg, context);
      return false;
    }
  }
  timer.stop();
  String elapsed = (timer.elapsedMilliseconds / 1000).toStringAsFixed(1);
  log.info("File uploaded in $elapsed s", context);
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
    String msg = "Can not zip directory: ${e.message}";
    log.error(msg, context);
    return null;
  }
  if (file == null) return null;
  String filename = path.basename(file.path);
  bool ok = await upload(
      file: file, serverUrl: serverUrl, filename: filename, context: context);
  if (!ok) {
    return null;
  }
  try {
    file.deleteSync();
  } catch (e) {
    String msg = "Can not delete file: ${e.message}";
    log.error(msg, context);
  }
}
