import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mono/flutter_mono.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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
  String code = '';

  final monoPublicKey = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(code ?? ''),
          const SizedBox(
            height: 150,
          ),
          Container(
            height: 50,
            width: 200,
            child: RaisedButton(
              color: Colors.blue,
              textColor: Colors.white,
              child: Text('Launch Mono'),
              onPressed: () async {
                await MonoFlutter.launchMono(
                  context,
                  key: monoPublicKey,
                  onClosed: () {},
                  onSuccess: (String _code) {
                    setState(() {
                      code = _code;
                    });
                  },
                );
              },
            ),
          ),
        ],
      )),
    );
  }
}
