import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mono/src/models/success_model.dart';
import 'package:flutter_mono/src/utils/extensions.dart';

import '../flutter_mono.dart';

class MonoFlutter {
  // Launch Flutter Mono
  static Future launchMono(
    BuildContext _, {

    /// Public Key from your https://app.withmono.com/apps
    String? key,

    /// Allows an optional configuration object to be passed.
    /// When the setup method is called without a config object,
    /// the list of institutions will be displayed for a user to select from. https://github.com/withmono/connect.js#setupconfig-object
    String? configJson,

    /// Success callback
    void Function(MonoSuccessModel code)? onSuccess,

    /// This optional function is called when certain events in the Mono Connect flow have occurred,
    /// for example, when the user selected an institution. This enables your application to gain
    /// further insight into the Mono Connect onboarding flow.
    ///
    ///
    /// The onEvent callback returns two paramters, eventName a string containing
    /// the event name and data an object that contains event metadata.

    void Function(String eventName, Map<String, dynamic> eventData)? onEvent,

    /// Triggered on Connect Widget close
    Function? onClose,

    /// Triggered on Connect Widget Load
    Function? onLoad,

    /// Error Widget will show if loading fails
    Widget? error,

    /// Show MonoView Logs
    bool showLogs = false,
    String? reference,
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
                  error: error,
                  onSuccess: onSuccess,
                  onLoad: onLoad,
                  onClose: onClose,
                  onEvent: onEvent,
                  showLogs: showLogs,
                  configJson: configJson,
                ),
              ),
            ),
          ],
        ),
        context: _,
      );
}
