import 'package:flutter/material.dart';
import 'package:dataview/dataview.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My app',
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: RaisedButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) {
                  return DataviewPage("/");
                },
              ));
            },
            child: Text("View application data")));
  }
}

void main() {
  runApp(MyApp());
}
