import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import "bloc_file_explorer.dart";
import "models.dart";

class _DataviewPageState extends State<DataviewPage> {
  ItemsBloc bloc;
  String path;
  final addDirController = TextEditingController();
  SlidableController slidableController;

  _DataviewPageState(this.path);

  @override
  void initState() {
    this.bloc = ItemsBloc(this.path);
    super.initState();
  }

  @override
  void dispose() {
    addDirController.dispose();
    this.bloc.dispose();
    super.dispose();
  }

  Widget _buildVerticalListItem(BuildContext context, DirectoryItem item) {
    return ListTile(
      title: Text(item.filename),
      dense: true,
      leading: item.icon,
      trailing: Text("${item.filesize}"),
      onTap: () {
        String path;
        if (path == "/") {
          path = this.path + item.filename;
        } else {
          path = this.path + "/" + item.filename;
        }
        if (item.isDirectory == true) {
          Navigator.of(context).push(PageRouteBuilder(
              pageBuilder: (_, __, ___) => DataviewPage(path)));
        }
      },
    );
  }

  Widget _getSlidableWithLists(BuildContext context, DirectoryItem item) {
    return Slidable(
      key: Key(item.filename),
      controller: slidableController,
      direction: Axis.horizontal,
      delegate: SlidableBehindDelegate(),
      actionExtentRatio: 0.25,
      child: _buildVerticalListItem(context, item),
      actions: <Widget>[
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () => _confirmDeleteDialog(item),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dataview"), actions: <Widget>[
        IconButton(
          icon: Icon(Icons.create_new_folder),
          tooltip: 'Add directory',
          onPressed: () {
            _addDir();
          },
        ),
      ]),
      body: StreamBuilder<List<DirectoryItem>>(
        stream: this.bloc.items,
        builder: (BuildContext context,
            AsyncSnapshot<List<DirectoryItem>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  DirectoryItem item = snapshot.data[index];
                  return _getSlidableWithLists(context, item);
                });
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  _addDir() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text("Create a directory"),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextField(
                    controller: addDirController,
                    autofocus: true,
                    autocorrect: false,
                  ),
                  FlatButton(
                    child: Text("Create"),
                    onPressed: () {
                      bloc.createDir(this.path, addDirController.text);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ));
      },
    );
  }

  _confirmDeleteDialog(DirectoryItem item) {
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
                bloc.deleteItem(item);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class DataviewPage extends StatefulWidget {
  final String path;

  DataviewPage(this.path);
  @override
  _DataviewPageState createState() => _DataviewPageState(this.path);
}
