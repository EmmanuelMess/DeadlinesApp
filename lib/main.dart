import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeadLines',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'DeadLines'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _decrementCounter() {
    setState(() {
      _counter--;
    });
  }

  List<Widget> _createCards(BuildContext context) {
    return new List<Widget>.generate(_counter, (index) =>
        Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const ListTile(
                leading: Icon(Icons.album),
                title: Text('Thing'),
                subtitle: Text('Due in two days'),
              ),
              ButtonBar(
                children: <Widget>[
                  FlatButton(
                    child: const Text('FINISHED'),
                    onPressed: () {
                      _decrementCounter();

                      final snackBar = SnackBar(
                        content: Text('Nice!'),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {
                            _incrementCounter();
                          },
                        ),
                      );
                      Scaffold.of(context).showSnackBar(snackBar);
                    },
                  ),
                ],
              ),
            ],
          ),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Builder(
        builder: (context) =>
            Align(
              alignment: Alignment.topCenter,
              child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.all(15.0),
                  children: _createCards(context)
              ),
            ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
