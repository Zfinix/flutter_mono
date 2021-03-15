import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../raw/mono_html.dart';
import 'error_view.dart';

class MonoView extends StatefulWidget {
  /// Public Key from your https://app.withmono.com/apps
  final String? apiKey;

  /// Success callback
  final Function(String code)? onSuccess;

  /// Mono popup Close callback
  final Function? onClosed;

  /// Error Widget will show if loading fails
  final Widget? error;

  /// Show MonoView Logs
  final bool showLogs;

  const MonoView( {
    Key? key,
    required this.apiKey,
    this.error,
    this.onSuccess,
    this.onClosed,
    this.showLogs = false,
  })  : assert(apiKey != null, 'API key cannot be null'),
        super(key: key);

  @override
  _MonoViewState createState() => _MonoViewState();
}

class _MonoViewState extends State<MonoView> {
  @override
  void initState() {
    super.initState();
    _handleInit();
    // Enable hybrid composition.
  }

  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  Future<WebViewController> get _webViewController => _controller.future;
  bool isLoading = false;
  bool hasError = false;

  String? contentBase64;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<String>(
          future: _getURL(),
          builder: (context, snapshot) {
            if (hasError) {
              return widget.error ??
                  ErrorView(reload: () async {
                    setState(() {});
                    (await _webViewController).reload();
                  });
            } else
              return snapshot.hasData
                  ? FutureBuilder<WebViewController>(
                      future: _controller.future,
                      builder: (BuildContext context,
                          AsyncSnapshot<WebViewController> controller) {
                        return WebView(
                          initialUrl: snapshot.data!,
                          
                          onWebViewCreated:
                              (WebViewController webViewController) {
                            _controller.complete(webViewController);
                          },
                          javascriptChannels: {_monoJavascriptChannel()},
                          javascriptMode: JavascriptMode.unrestricted,
                          onPageStarted: (String url) {
                            setState(() {
                              isLoading = true;
                            });
                          },
                          onPageFinished: (String url) {
                            setState(() {
                              isLoading = false;
                            });
                          },
                          navigationDelegate: (_) =>
                              _handleNavigationInterceptor(_),
                        );
                      },
                    )
                  : Center(child: CupertinoActivityIndicator());
          }),
    );
  }

  /// javascript channel for events sent by mono
  JavascriptChannel _monoJavascriptChannel() {
    return JavascriptChannel(
        name: 'MonoClientInterface',
        onMessageReceived: (JavascriptMessage message) {
          if (widget.showLogs == true)
            print('MonoClientInterface, ${message.message}');
          Map<String, dynamic> res = json.decode(message.message);
          handleResponse(res);
        });
  }

  /// parse event from javascript channel
  void handleResponse(Map<String, dynamic>? body) async {
    try {
      String? key = body?['type'];
      if (body != null && key != null) {
        switch (key) {
          case 'mono.connect.widget.account_linked':
            var response = body['data'];
            if (response == null) return;
            var code = response['code'];

            if (widget.onSuccess != null) widget.onSuccess!(code);
            break;
          case 'mono.connect.widget.closed':
            if (mounted && widget.onClosed != null) widget.onClosed!();
            break;
          default:
        }
      }
    } catch (e) {
      print('e.toString()');
      print(e.toString());
    }
  }

  Future<String> _getURL() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          hasError = false;
        });
        return Uri.dataFromString(buildMonoHtml(widget.apiKey),
                mimeType: 'text/html')
            .toString();
      } else {
        return Uri.dataFromString('<html><body>An Error Occurred</body></html>',
                mimeType: 'text/html')
            .toString();
      }
    } catch (_) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      return Uri.dataFromString('<html><body>An Error Occurred</body></html>',
              mimeType: 'text/html')
          .toString();
    }
  }

  void _handleInit() async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  NavigationDecision _handleNavigationInterceptor(NavigationRequest request) {
    if (request.url.toLowerCase().contains('mono')) {
      // Navigate to all urls contianing mono
      return NavigationDecision.navigate;
    } else {
      // Block all navigations outside mono
      return NavigationDecision.prevent;
    }
  }
}
