import 'package:flutter/material.dart';
import 'package:dataview/dataview.dart';

final routes = {
  // ...
  '/dataview': (BuildContext context) => new DataviewScreen("/"),
};

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My app',
      routes: routes,
    );
  }
}

void main() {
  runApp(MyApp());
}
