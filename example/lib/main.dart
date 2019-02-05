import 'package:flutter/material.dart';
import 'package:dataview/dataview.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dataview Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: RaisedButton(
        child: Text("Dataview"),
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) {
                return DataviewPage("/");
              },
            )),
      ),
    ));
  }
}
