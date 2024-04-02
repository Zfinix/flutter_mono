import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mono/flutter_mono.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
      ),
      child: MaterialApp(
        title: 'Mono Flutter Demo',
        theme: ThemeData(
          primaryColor: Colors.black,
        ),
        debugShowCheckedModeBanner: false,
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String _code = 'no_code_yet';
  String get code => _code;
  set code(String value) {
    setState(() => _code = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MonoConnect v2.0 Demo',
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
              code,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 60),
            Column(
              children: [
                SizedBox(
                  height: 50,
                  width: 260,
                  child: CupertinoButton(
                    color: Colors.black,
                    child: const Center(
                      child: Text(
                        'Launch Mono',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    onPressed: () => launch(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void launch(BuildContext context) {
    try {
      FlutterMono(
        apiKey: 'test_pk_lwWSeByMA8yGfckIN87I',
        reference: 'random_string',
        showLogs: true,
        customer: const MonoCustomer(
          newCustomer: MonoNewCustomerModel(
            name: "Samuel Olamide", // REQUIRED
            email: "samuel@neem.com", // REQUIRED
            identity: MonoNewCustomerIdentity(
              type: "bvn",
              number: "2323233239",
            ),
          ),
        ),
        configJson: const {
          "selectedInstitution": {
            "id": "5f2d08be60b92e2888287702",
            "auth_method": "mobile_banking"
          }
        },
        onLoad: () => log('widget_loaded'),
        onEvent: (eventName, data) => log(
          '$eventName: $data',
        ),
        onClose: (it) {
          log('Success: $it');
          code = it;
        },
      ).launchMono(context);
    } catch (e) {
      log(e.toString());
    }
  }
}
