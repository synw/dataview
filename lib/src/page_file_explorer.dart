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
    path = path ?? "/";
    _bloc = ItemsBloc(path);
  }

  String path;
  String uploadTo;
  ErrRouter errRouter;

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
        appBar: AppBar(title: Text("Dataview"), actions: <Widget>[
          IconButton(
            icon: Icon(Icons.create_new_folder),
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
                        delegate: SlidableBehindDelegate(),
                        actionExtentRatio: 0.25,
                        child: _buildVerticalListItem(context, item),
                        actions: _getSlideIconActions(context, item),
                      );
                    });
              } else {
                return Center(child: CircularProgressIndicator());
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
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
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
                file: item.item,
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
                  .catchError((e) {
                throw (e);
              });
            }));
      }
    }
    return ic;
  }

  _addDir(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text("Create a directory"),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text("Create"),
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

  _confirmDeleteDialog(BuildContext context, DirectoryItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete ${item.filename}?"),
          actions: <Widget>[
            FlatButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("Delete"),
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
