# Dataview

[![pub package](https://img.shields.io/pub/v/dataview.svg)](https://pub.dartlang.org/packages/dataview)

A file explorer for the application's documents directory. Can upload files and directories to a server.

![Screenshot](screenshot.gif)

## Usage

In a router:

   ```dart
   import 'package:dataview/dataview.dart';

   final routes = {
    // ...
    '/dataview': (BuildContext context) => new DataviewPage(),
    };
   ```

In a link:

   ```dart
   import 'package:dataview/dataview.dart';

   // ...
   RaisedButton(
    onPressed: () {
     Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
       return DataviewPage("/");
      },
    ));
   },
   child: Text("View application data"))
   ```

## Upload files and directories

Specify the `uploadTo` parameter to be able to upload to a server:

   ```dart
   DataviewPage(uploadTo: "http://192.168.1.2:8082/upload")
   ```

A default basic development [Go server](https://github.com/synw/dataview/tree/master/server) is provided for local usage. A compiled version for Linux is attached to the [Github release](https://github.com/synw/dataview/releases/latest). To run it:

   ```bash
   ./devserver_linux64
   ```

It will receive the files in the same directory as the running binary
