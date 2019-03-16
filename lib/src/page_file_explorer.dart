import 'dart:io';
import 'package:flutter/material.dart';
import 'package:err/err.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import "bloc_file_explorer.dart";
import "models.dart";
import 'zip_upload/zip_upload.dart';
import 'logger.dart';

class _DataviewPageState extends State<DataviewPage> {
  _DataviewPageState(this.path, {this.uploadTo, this.errRouter}) {
    path ??= "/";
    _bloc = ItemsBloc(path);
  }

  String path;
  final String uploadTo;
  final ErrRouter errRouter;

  ItemsBloc _bloc;

  final _addDirController = TextEditingController();
  SlidableController _slidableController;

  @override
  void initState() {
    initLogger(errRouter);
    super.initState();
  }

  @override
  void dispose() {
    _addDirController.dispose();
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Dataview"), actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.create_new_folder),
            tooltip: 'Add directory',
            onPressed: () {
              _addDir(context);
            },
          ),
        ]),
        body: Stack(children: <Widget>[
          StreamBuilder<List<DirectoryItem>>(
            stream: this._bloc.items,
            builder: (BuildContext context,
                AsyncSnapshot<List<DirectoryItem>> snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      DirectoryItem item = snapshot.data[index];
                      return Slidable(
                        key: Key(item.filename),
                        controller: _slidableController,
                        direction: Axis.horizontal,
                        delegate: const SlidableBehindDelegate(),
                        actionExtentRatio: 0.25,
                        child: _buildVerticalListItem(context, item),
                        actions: _getSlideIconActions(context, item),
                      );
                    });
              } else {
                return Center(child: const CircularProgressIndicator());
              }
            },
          ),
        ]));
  }

  Widget _buildVerticalListItem(BuildContext context, DirectoryItem item) {
    return ListTile(
      title: Text(item.filename),
      dense: true,
      leading: item.icon,
      trailing: Text("${item.filesize}"),
      onTap: () {
        String _p;
        if (path == "/") {
          _p = path + item.filename;
        } else {
          _p = path + "/" + item.filename;
        }
        if (item.isDirectory == true) {
          Navigator.of(context)
              .push(MaterialPageRoute<DataviewPage>(builder: (context) {
            return DataviewPage(
              _p,
              uploadTo: uploadTo,
            );
          }));
        }
      },
    );
  }

  List<Widget> _getSlideIconActions(BuildContext context, DirectoryItem item) {
    List<Widget> ic = [];
    ic.add(IconSlideAction(
      caption: 'Delete',
      color: Colors.red,
      icon: Icons.delete,
      onTap: () => _confirmDeleteDialog(context, item),
    ));
    if (uploadTo != null) {
      if (item.item is File) {
        ic.add(IconSlideAction(
          caption: 'Upload',
          color: Colors.lightBlue,
          icon: Icons.file_upload,
          onTap: () => upload(
                serverUrl: uploadTo,
                filename: item.filename,
                file: File(item.item.path),
                context: context,
              ),
        ));
      } else if (item.item is Directory) {
        ic.add(IconSlideAction(
            caption: 'Upload',
            color: Colors.lightBlue,
            icon: Icons.file_upload,
            onTap: () {
              zipUpload(directory: item, serverUrl: uploadTo, context: context)
                  .catchError((dynamic e) {
                throw (e);
              });
            }));
      }
    }
    return ic;
  }

  void _addDir(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: const Text("Create a directory"),
            actions: <Widget>[
              FlatButton(
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: const Text("Create"),
                onPressed: () {
                  _bloc.createDir(_addDirController.text).then((_) {
                    Navigator.of(context).pop();
                    _bloc.lsDir();
                  });
                },
              ),
            ],
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextField(
                    controller: _addDirController,
                    autofocus: true,
                    autocorrect: false,
                  ),
                ],
              ),
            ));
      },
    );
  }

  void _confirmDeleteDialog(BuildContext context, DirectoryItem item) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete ${item.filename}?"),
          actions: <Widget>[
            FlatButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: const Text("Delete"),
              color: Colors.red,
              onPressed: () {
                _bloc.deleteItem(item).then((_) {
                  Navigator.of(context).pop();
                  _bloc.lsDir();
                });
              },
            ),
          ],
        );
      },
    );
  }
}

class DataviewPage extends StatefulWidget {
  DataviewPage(this.path, {this.uploadTo});

  final String path;
  final String uploadTo;

  @override
  _DataviewPageState createState() =>
      _DataviewPageState(path, uploadTo: uploadTo);
}
