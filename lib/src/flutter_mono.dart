import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mono/src/utils/extensions.dart';

import '../flutter_mono.dart';

class MonoFlutter {
  // Launch Flutter Mono
  static Future launchMono(
    BuildContext _, {

    /// Public Key from your https://app.withmono.com/apps
    required String key,

    /// Success callback
    Function(String code)? onSuccess,

    /// Mono popup Close callback
    Function ? onClosed,

    /// final Widget error;
    Widget? error,

    /// Show MonoView Logs
    bool showLogs = false,
  }) async =>
      showDialog(
        builder: (context) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Container(
                width: context.screenWidth(.9),
                height: context.screenHeight(.73),
                child: MonoView(
                  apiKey: key,
                  onClosed: onClosed,
                  onSuccess: onSuccess,
                  showLogs: showLogs,
                  error: error,
                ),
              ),
            ),
          ],
        ),
        context: _,
      );
}
