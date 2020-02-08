import 'dart:io';

import 'package:dataview/src/logger.dart';
import 'package:err_router/err_router.dart';
import 'package:filex/filex.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'logger.dart';
import 'zip_upload/zip_upload.dart';

class _DataviewPageState extends State<DataviewPage> {
  _DataviewPageState({this.path, this.uploadTo, this.errRouter}) {
    path ??= "";
    errRouter ??= log;
  }

  String basePath;
  String path;
  final String uploadTo;
  FilexController controller;
  ErrRouter errRouter;
  bool ready = false;

  @override
  void initState() {
    getApplicationDocumentsDirectory().then((dir) {
      basePath = dir.path;
      controller = FilexController(path: basePath + path)
        ..showHiddenFiles = true;
      setState(() => ready = true);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dataview"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => controller.addDirectory(context),
          )
        ],
      ),
      body: ready
          ? Scrollbar(
              child: Filex(
              controller: controller,
              actions: <PredefinedAction>[PredefinedAction.delete],
              extraActions: <FilexSlidableAction>[
                FilexSlidableAction(
                  name: "Upload",
                  iconData: Icons.file_upload,
                  color: Colors.blue,
                  onTap: uploadAction,
                )
              ],
            ))
          : const Center(child: CircularProgressIndicator()),
    );
  }

  void uploadAction(BuildContext context, DirectoryItem item) {
    if (item.isDirectory) {
      zipUpload(directory: item, context: context, serverUrl: uploadTo);
    } else {
      upload(
          file: File(item.path),
          context: context,
          filename: item.filename,
          serverUrl: uploadTo);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class DataviewPage extends StatefulWidget {
  DataviewPage({this.path, this.uploadTo, this.errRouter});

  final String uploadTo;
  final String path;
  final ErrRouter errRouter;

  @override
  _DataviewPageState createState() =>
      _DataviewPageState(path: path, uploadTo: uploadTo, errRouter: errRouter);
}
