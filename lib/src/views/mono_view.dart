import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mono/src/models/success_model.dart';
import 'package:flutter_mono/src/utils/pretty_json.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../raw/mono_html.dart';
import 'error_view.dart';

class MonoView extends StatefulWidget {
  /// Public Key from your https://app.withmono.com/apps
  final String? apiKey;

  /// Allows an optional configuration object to be passed.
  /// When the setup method is called without a config object,
  /// the list of institutions will be displayed for a user to select from. https://github.com/withmono/connect.js#setupconfig-object
  final String? configJson;

  /// This optional string is used as a reference to the current
  /// instance of Mono Connect. It will be passed to the data object
  /// in all onEvent callbacks. It's recommended to pass a random string.
  final String? reference;

  /// Success callback
  final Function(MonoSuccessModel code)? onSuccess;

  /// This optional function is called when certain events in the Mono Connect flow have occurred,
  /// for example, when the user selected an institution. This enables your application to gain
  /// further insight into the Mono Connect onboarding flow.
  ///
  ///
  /// The onEvent callback returns two paramters,
  ///
  /// `eventName` a string containing The event name and
  ///
  /// `eventData` an object that contains event metadata.

  final Function(String eventName, Map<String, dynamic> eventData)? onEvent;

  /// Triggered on Connect Widget close
  final Function? onClose;

  /// Triggered on Connect Widget Load
  final Function? onLoad;

  /// Error Widget will show if loading fails
  final Widget? error;

  /// Show MonoView Logs
  final bool showLogs;

  const MonoView({
    Key? key,
    required this.apiKey,
    this.error,
    this.onLoad,
    this.onClose,
    this.onEvent,
    this.onSuccess,
    this.reference,
    this.configJson,
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

  final _controller = Completer<WebViewController>();
  Future<WebViewController> get _webViewController => _controller.future;

  bool _isLoading = true;
  bool get isLoading => _isLoading;
  set isLoading(bool val) {
    _isLoading = val;
    setState(() {});
  }

  bool _hasError = false;
  bool get hasError => _hasError;
  set hasError(bool val) {
    _hasError = val;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<ConnectivityResult>(
          future: Connectivity().checkConnectivity(),
          builder: (context, snapshot) {
            if (hasError) {
              return widget.error ??
                  ErrorView(
                    reload: () async {
                      setState(() {});
                      (await _webViewController).reload();
                    },
                  );
            } else if (snapshot.hasData == true &&
                snapshot.data != ConnectivityResult.none) {
              return FutureBuilder<WebViewController>(
                future: _controller.future,
                builder: (BuildContext context,
                    AsyncSnapshot<WebViewController> controller) {
                  return WebView(
                    initialUrl: Uri.dataFromString(
                      buildMonoHtml(
                        widget.apiKey,
                        widget.configJson,
                        widget.reference ?? '',
                      ),
                      mimeType: 'text/html',
                    ).toString(),
                    onWebViewCreated: (WebViewController webViewController) {
                      _controller.complete(webViewController);
                    },
                    javascriptChannels: _monoJavascriptChannel,
                    javascriptMode: JavascriptMode.unrestricted,
                    onPageStarted: (url) {
                      isLoading = true;
                    },
                    onPageFinished: (url) {
                      isLoading = false;
                    },
                    navigationDelegate: _handleNavigationInterceptor,
                  );
                },
              );
            } else {
              return Center(child: CupertinoActivityIndicator());
            }
          }),
    );
  }

  /// javascript channel for events sent by mono
  Set<JavascriptChannel> get _monoJavascriptChannel => {
        JavascriptChannel(
          name: 'MonoClientInterface',
          onMessageReceived: (data) {
            if (widget.showLogs == true) {
              print('MonoClientInterface:');
              print('${jsonPretty(json.decode(data.message))}');
            }
            handleResponse(data.message);
          },
        )
      };

  /// parse event from javascript channel
  void handleResponse(String body) async {
    try {
      final Map<String, dynamic> bodyMap = json.decode(body);
      String? key = bodyMap['type'] as String?;
      if (key != null) {
        switch (key) {
          case 'onEvent':
            var eventName = bodyMap['eventName'] as String;
            if (widget.onEvent != null) widget.onEvent!(eventName, bodyMap);
            break;
          case 'onClose':
          case 'mono.modal.closed':
            if (mounted && widget.onClose != null) widget.onClose!();
            break;
          case 'onSuccess':
          case 'mono.modal.linked':
            var successModel = MonoSuccessModel.fromJson(body);
            if (mounted && widget.onSuccess != null)
              widget.onSuccess!(successModel);
            break;
          case 'onLoad':
            if (mounted && widget.onLoad != null) widget.onLoad!();
            break;
          default:
        }
      }
    } catch (e) {
      if (widget.showLogs == true) {
        print('MonoClientLog, ${e.toString()}');
      }
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
