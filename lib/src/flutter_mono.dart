import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mono/src/const/const.dart';
import 'package:flutter_mono/src/models/models.dart';
import 'package:flutter_mono/src/utils/utils.dart';
import 'package:flutter_mono/src/views/error_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

const _loggerName = 'MonoFlutterLog';

class FlutterMono extends StatefulWidget {
  /// Public Key from your https://app.withmono.com/apps
  final String apiKey;

  /// The new mono widget now expects a scope parameter with its string value set to “auth”.
  final String scope;

  /// The customer objects expects the following keys based on the following conditions:
  /// New Customers: For new customers, the customer object expects the user’s name, email and identity
  /// Existing Customers: For existing customers, the customer object expects only the customer ID.
  final MonoCustomer customer;

  /// Allows an optional selected institution to be passed.
  final ConnectInstitution? selectedInstitution;

  /// This optional string is used as a reference to the current
  /// instance of Mono Connect. It will be passed to the data object
  /// in all onEvent callbacks. It's recommended to pass a random string.
  final String? reference;

  /// This optional function is called when certain events in the Mono Connect flow have occurred,
  /// for example, when the user selected an institution. This enables your application to gain
  /// further insight into the Mono Connect onboarding flow.
  ///
  ///
  /// The onEvent callback returns two paramters,
  ///
  /// `event` a string containing The event name and
  ///
  /// `data` an object that contains event metadata.

  final Function(String event, Map<String, dynamic> data)? onEvent;

  /// Triggered on Connect Widget close
  final ValueChanged<String>? onClose;

  /// Triggered on Connect Widget Load
  final Function? onLoad;

  /// Error Widget will show if loading fails
  final Widget? errorView;

  /// Show MonoView Logs
  final bool showLogs;

  const FlutterMono({
    super.key,
    required this.apiKey,
    required this.customer,
    this.errorView,
    this.scope = 'auth',
    this.onLoad,
    this.onClose,
    this.onEvent,
    this.reference,
    this.selectedInstitution,
    this.showLogs = false,
  });

  void launchMono(BuildContext context) => showDialog(
        context: context,
        builder: (_) => this,
      );

  @override
  _FlutterMonoState createState() => _FlutterMonoState();
}

class _FlutterMonoState extends State<FlutterMono> {
  late WebViewController controller;

  @override
  void initState() {
    super.initState();
    handleInitialization();
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

  int? _loadingPercent;
  int? get loadingPercent => _loadingPercent;
  set loadingPercent(int? val) {
    _loadingPercent = val;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: SizedBox(
              height: context.screenHeight(.7),
              child: FutureBuilder<List<ConnectivityResult>>(
                future: Connectivity().checkConnectivity(),
                builder: (context, snapshot) {
                  return switch (hasError) {
                    true => widget.errorView ??
                        ErrorView(
                          reload: () async {
                            setState(() {});
                            (await _webViewController).reload();
                          },
                        ),
                    false => Stack(
                        alignment: Alignment.center,
                        children: [
                          if (isLoading == true) ...[
                            const CupertinoActivityIndicator(),
                          ],

                          /// Webview
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 400),
                            opacity: isLoading == true && _loadingPercent != 100
                                ? 0
                                : 1,
                            child: WebViewWidget(
                              controller: controller,
                            ),
                          ),
                        ],
                      )
                  };
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Handle WebView initialization
  void handleInitialization() async {
    late final PlatformWebViewControllerCreationParams params;
    params = WebViewPlatform.instance is WebKitWebViewPlatform
        ? WebKitWebViewControllerCreationParams(
            allowsInlineMediaPlayback: true,
          )
        : const PlatformWebViewControllerCreationParams();

    controller = WebViewController.fromPlatformCreationParams(
      params,
      onPermissionRequest: (request) => request.grant(),
    );

    await SystemChannels.textInput.invokeMethod<String>('TextInput.hide');

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(true)
      ..addJavaScriptChannel(
        Constants.eventHandler,
        onMessageReceived: (JavaScriptMessage data) {
          final rawData = data.message
              .removePrefix('"')
              .removeSuffix('"')
              .replaceAll(r'\', '');
          try {
            handleResponse(rawData);
          } catch (e) {
            logger(e.toString());
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => isLoading = true,
          onWebResourceError: (e) {
            logger(e.toString());
          },
          onProgress: (it) {
            loadingPercent = it;
            print(it);
          },
          onPageFinished: (_) {
            isLoading = false;
          },
        ),
      )
      ..setUserAgent('Mozilla/5.0 (Linux; Android 10; Pixel 3 XL) '
          'AppleWebKit/537.36 (KHTML, like Gecko) '
          'Chrome/88.0.4324.93 '
          'Mobile Safari/537.36');

    confirmPermissionsAndLoad();
  }

  Future<void> confirmPermissionsAndLoad() async {
    bool isCameraGranted;

    if (!kIsWeb) {
      // Request camera permission
      final cameraStatus = await Permission.camera.status;
      isCameraGranted = cameraStatus.isGranted;
    } else {
      isCameraGranted = true;
    }

    if (!isCameraGranted) {
      final result = await Permission.camera.request();

      if (result != PermissionStatus.granted) {
        const snackBar = SnackBar(
          content: Text('Permissions not granted'),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      }
    }

    await loadRequest();
  }

  Future<void> loadRequest() {
    final customerJson = {'customer': widget.customer.toMap()};
    final data = json.encode(customerJson);

    String? extraData;
    if (widget.selectedInstitution != null) {
      extraData = widget.selectedInstitution!.toJson();
    }

    final queryParameters = {
      'key': widget.apiKey,
      'version': Constants.version,
      'scope': widget.scope,
      'data': data,
      if (widget.reference != null) 'reference': widget.reference,
      if (extraData != null) 'selectedInstitution': extraData,
    };

    final uri = Uri(
      scheme: Constants.urlScheme,
      host: Constants.connectHost,
      queryParameters: queryParameters,
    );

    return controller.loadRequest(uri);
  }

  /// parse event from javascript channel
  void handleResponse(String body) async {
    try {
      final Map<String, dynamic> bodyMap = json.decode(body);
      String? key = bodyMap['type'] as String?;
      final data = bodyMap['data'] as Map<String, dynamic>? ?? {};
      if (key != null) {
        switch (key) {
          case 'mono.widget.event':
            var eventName = bodyMap['event'] as String;
            if (widget.onEvent != null) widget.onEvent!(eventName, bodyMap);
            break;
          case 'mono.connect.widget.closed':
            final code = data['code'] as String? ?? '';
            Navigator.pop(context);
            if (mounted && widget.onClose != null) widget.onClose?.call(code);
            break;
          case 'mono.connect.widget_opened':
          case 'onLoad':
            if (mounted && widget.onLoad != null) widget.onLoad!();
            break;
          default:
            if (mounted && widget.onEvent != null)
              widget.onEvent?.call(key, data);
        }
      }
    } catch (e) {
      logger('$_loggerName: ${e.toString()}');
    }
  }

  void logger(String log) {
    if (widget.showLogs == true) {
      print('$_loggerName: $log');
    }
  }
}
