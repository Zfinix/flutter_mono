// ignore_for_file: constant_identifier_names, non_constant_identifier_names, unnecessary_brace_in_string_interps

import 'package:flutter_mono/src/models/customer_model.dart';

const WIDGET_SUCCESS = 'mono.connect.success';
const WIDGET_EVENT = 'mono.connect.event';
const WIDGET_ERROR = 'mono.connect.error';
const WIDGET_CLOSE = 'mono.connect.close';
const WIDGET_LOAD = 'mono.connect.load';
const WIDGET_FUNCTION = 'setupMonoConnect';
final CONNECT_WIDGET_URL = 'https://connect.withmono.com/connect.js';

typedef MonoConnectConfig = ({
  String key,
  String scope,
  MonoCustomer customer,
  String? reference,
  String configJson,
});

class MonoConnect {
  static const eventHandler = 'MonoClientInterface';
  static String script = '<script src="$CONNECT_WIDGET_URL"></script>';

  /// `[JS]` Create EventListener config for message client
  static String get messageHandler => '''

     // Create our shared stylesheet:
     var style = document.createElement("style");
      
      // Add EventListener for onMessage Event
      window.addEventListener('message', (event) => {
        sendMessage(event.data)
      });
      
      // Override default JS Console function
      console._log_old = console.log
      console.log = function(msg) {
          sendMessageRaw(msg);
          console._log_old(msg);
      }

      console._error_old = console.error
      console.error = function(msg) {
          sendMessageRaw(msg);
          console._error_old(msg);
      }
      
      // Send callback to dart JSMessageClient
      function sendMessage(message) {
          if (window.$eventHandler && window.$eventHandler.postMessage) {
              $eventHandler.postMessage(JSON.stringify(message));
          }
      } 

      // Send raw callback to dart JSMessageClient
      function sendMessageRaw(message) {
          if (window.$eventHandler && window.$eventHandler.postMessage) {
              $eventHandler.postMessage(message);
          }
      } 

      // Send error callback to dart JSMessageClient
      function sendErrorMessage(error) {
          if (window.$eventHandler && window.$eventHandler.postMessage) {
              $eventHandler.postMessage({type: `$WIDGET_ERROR`, error: error});
          }
      } 
''';

  /// `[JS]` Create EventListener config for message client
  static String createWidgetHtml({
    required MonoConnectConfig connectConfig,
  }) =>
      '''<!DOCTYPE html>
<html>

<head>
    <base href="/">

    <meta charset="UTF-8">
    <meta name="description" content="Flutter Mono Connect Widget">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mono Connect</title>
    $script
</head>

  <body onload="$WIDGET_FUNCTION()">
  <script type="text/javascript">
  $messageHandler
  ${injectWidgetFunction(config: connectConfig)}
  </script>
  
  </body>

</html>''';

  /// `[JS]` Create EventListener config for message client
  static String injectWidgetFunction({
    required MonoConnectConfig config,
  }) =>
      '''
        
        window.onload = setupMonoConnect;
        function setupMonoConnect() {

          const connect = new Connect({
                key: "${config.key}",
                reference: `${config.reference}`.length > 0 ? `${config.reference}` : null,
                onSuccess: (response) => sendMessage({ type: `$WIDGET_SUCCESS`, data: response.code }),
                onLoad: () => sendMessage({ type: `$WIDGET_LOAD` }),
                onClose: () => sendMessage({ type: `$WIDGET_CLOSE` }),
                onEvent: (event, data) => sendMessage({
                    type: `$WIDGET_EVENT`,
                    event: event,
                    data: data,
                }),
                data: {
                  customer: ${config.customer.toJson()}
                }
            });

            if (`${config.configJson}`.length > 0){
              const config = JSON.parse(`${config.configJson}`);
              connect.setup(config)
            } else {
              connect.setup()
            }

            connect.open()
            function sendMessage(message) {
                if (window.MonoClientInterface && window.MonoClientInterface.postMessage) {
                    MonoClientInterface.postMessage(JSON.stringify(message));
                    
                }
            }
      }
  ''';
}
