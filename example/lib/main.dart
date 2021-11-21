import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mono/flutter_mono.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
      ),
      child: MaterialApp(
        title: 'Mono Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        home: MyHomePage(title: 'Mono Demo'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  MonoSuccessModel? success;

  final monoPublicKey = 'your public key';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title ?? '',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SelectableText(
              success?.data.code ?? '',
              style: TextStyle(
                color: monoColor,
                fontWeight: FontWeight.w600,
                fontSize: 25,
              ),
            ),
            const SizedBox(height: 60),
            Column(
              children: [
                Container(
                  height: 50,
                  width: 260,
                  child: CupertinoButton(
                    color: monoColor,
                    child: Center(
                      child: Text(
                        'Launch Mono',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    onPressed: () async {
                      try {
                        await MonoFlutter.launchMono(
                          context,
                          key: monoPublicKey,
                          showLogs: true,
                          reference: 'reference',
                          configJson: '''{
                                "selectedInstitution": {
                                  "id": "5f2d08c060b92e2888287706", 
                                  "auth_method": "internet_banking" 
                                }
                          }''',
                          onClose: () {
                            print('onClose');
                          },
                          onLoad: () {
                            print('onLoad');
                          },
                          onEvent: (eventName, eventData) {
                            switch (eventName) {
                              case '':
                                break;
                              default:
                            }
                          },
                          onSuccess: (data) {
                            print('Success: ${data.toJson()}');
                          },
                        );
                      } catch (e) {
                        print(e.toString());
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

final monoColor = Color(0xff182cd1);
