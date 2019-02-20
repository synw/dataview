# Dataview

[![pub package](https://img.shields.io/pub/v/dataview.svg)](https://pub.dartlang.org/packages/dataview) [![Build Status](https://app.bitrise.io/app/88344c830e936002/status.svg?token=nFg7ltBAPglC0HDwDjy5BA)](https://app.bitrise.io/app/88344c830e936002#/builds)

A file explorer for the application's documents directory.

   ```yaml
   dependencies:
      dataview: ^0.1.1
   ```

![Screenshot](screenshot.gif)

## Usage

In a router:

   ```dart
   import 'package:dataview/dataview.dart';

   final routes = {
    // ...
    '/dataview': (BuildContext context) => new DataviewPage("/"),
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


