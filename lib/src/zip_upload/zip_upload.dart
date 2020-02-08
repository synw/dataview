import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:dio/dio.dart';
import 'package:err/err.dart';
import 'package:filesize/filesize.dart' as fs;
import 'package:filex/filex.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

import '../exceptions.dart';
import '../logger.dart';

final Dio dio = Dio();

Future<File> zip(
    {@required DirectoryItem directory, @required BuildContext context}) async {
  final encoder = ZipFileEncoder();
  final basename = path.basename(directory.path);
  log.flash("Zipping $basename");
  final endPath = "${directory.parent.path}/${directory.filename}.zip";
  final timer = Stopwatch()..start();
  try {
    encoder.zipDirectory(Directory(directory.item.path), filename: endPath);
  } catch (e) {
    final msg = "Error zipping: ${e.message}";
    log.screen(Err.error(msg), context);
    return null;
  }
  timer.stop();
  final file = File(endPath);
  String fileSize;
  try {
    fileSize = fs.filesize(file.lengthSync());
  } catch (e) {
    final msg = "Can not calculate filesize: ${e.message}";
    log.screen(Err.error(msg), context);
    return null;
  }
  log.console("END ZIPPING in ${timer.elapsedMilliseconds} ms ( $fileSize )");
  if (timer.elapsedMicroseconds > 1000) {
    log.flash("Directory zipped ( $fileSize ), uploading");
  }
  return file;
}

Future<bool> upload(
    {@required String serverUrl,
    @required File file,
    @required String filename,
    @required BuildContext context}) async {
  dynamic response;
  final timer = Stopwatch()..start();
  final formData = FormData.fromMap(<String, dynamic>{
    "file": await MultipartFile.fromFile(file.path, filename: filename)
  });
  try {
    //print("URL $serverUrl");
    //print("FORM ${file.path} / $filename");
    response = await Dio().post<dynamic>(serverUrl, data: formData);
  } on DioError catch (e) {
    final msg = "Can not upload: ${e.type} : ${e.message}";
    log.screen(Err.error(msg), context);
    return false;
  } catch (e) {
    final msg = "Can not upload: ${e.message}";
    log.screen(Err.error(msg), context);
    return false;
  }
  if (response != null) {
    if (response.statusCode != 200) {
      final msg = "Response status code: ${response.statusCode}";
      log.screen(Err.error(msg), context);
      return false;
    }
  }
  timer.stop();
  final elapsed = (timer.elapsedMilliseconds / 1000).toStringAsFixed(1);
  log.screen(Err.info("File uploaded in $elapsed s"), context);
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
    log.screen(Err.error(msg), context);
  }
  if (file == null) {
    return;
  }
  final filename = path.basename(file.path);
  final ok = await upload(
      file: file, serverUrl: serverUrl, filename: filename, context: context);
  if (!ok) {
    return;
  }
  try {
    file.deleteSync();
  } catch (e) {
    final msg = "Can not delete file: ${e.message}";
    log.screen(Err.error(msg), context);
  }
}
