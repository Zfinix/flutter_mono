import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

import '../raw/mono_html.dart';
import 'error_view.dart';

class MonoView extends StatefulWidget {
  /// Public Key from your https://app.withmono.com/apps
  final String apiKey;

  /// Success callback
  final Function(String code) onSuccess;

  /// Mono popup Close callback
  final Function onClosed;

  /// Error Widget will show if loading fails
  final Widget error;

  const MonoView({
    Key key,
    @required this.apiKey,
    this.error,
    this.onSuccess,
    this.onClosed,
  })  : assert(apiKey != null, 'API key cannot be null'),
        super(key: key);

  @override
  _MonoViewState createState() => _MonoViewState();
}

class _MonoViewState extends State<MonoView> {
  FlutterWebviewPlugin _webViewController = FlutterWebviewPlugin();
  StreamSubscription<WebViewStateChanged> _onStateChanged;
  StreamSubscription<WebViewHttpError> _onWebViewHttpError;
  bool isLoading = false;
  bool hasError = false;

  String contentBase64;

  @override
  void initState() {
    _handleInit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<String>(
          future: _getURL(),
          builder: (context, snapshot) {
            if (hasError) {
              return widget?.error ??
                  ErrorView(reload: () {
                    setState(() {});
                    _webViewController.reload();
                  });
            } else
              return snapshot.hasData
                  ? WebviewScaffold(
                      url: snapshot?.data,
                      javascriptChannels: {_monoJavascriptChannel()},
                      mediaPlaybackRequiresUserGesture: false,
                      withZoom: true,
                      withLocalStorage: true,
                      scrollBar: false,
                      hidden: true,
                      initialChild: Container(
                        child:
                            const Center(child: CupertinoActivityIndicator()),
                      ),
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
          if (kDebugMode) print('MonoClientInterface, ${message.message}');
          Map<String, dynamic> res = json.decode(message.message);
          handleResponse(res);
        });
  }

  /// parse event from javascript channel
  void handleResponse(Map<String, dynamic> body) async {
    try {
      String key = body['type'];
      if (body != null && key != null) {
        switch (key) {
          case 'mono.connect.widget.account_linked':
          case 'mono.modal.linked':
            var response = body['response'];
            if (response == null) return;
            var code = response['code'];
            if (widget.onSuccess != null) widget.onSuccess(code);
            if (mounted) {
              await _webViewController.close();
              Navigator.pop(context);
            }
            break;
          case 'mono.connect.widget.closed':
          case 'mono.modal.closed':
            if (widget.onClosed != null) widget.onClosed();
            if (mounted) {
              await _webViewController.close();
              Navigator.pop(context);
            }
            break;
          default:
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  /// Dispose unused Items
  @override
  void dispose() {
    _onWebViewHttpError.cancel();
    _onStateChanged.cancel();
    _webViewController.dispose();
    super.dispose();
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

  void _handleInit() {
    _onStateChanged =
        _webViewController.onStateChanged.listen((viewState) async {
      setState(() {
        switch (viewState.type) {
          case WebViewState.finishLoad:
            isLoading = false;
            hasError = false;

            break;
          case WebViewState.startLoad:
            isLoading = true;
            hasError = false;

            break;
          default:
        }
      });
    });

    _onWebViewHttpError = _webViewController.onHttpError.listen((err) async {
      setState(() {
        isLoading = false;
        hasError = true;
      });
    });

    // Hide Keyboard
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }
}
