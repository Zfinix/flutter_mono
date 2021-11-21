/// Raw mono html formation
String buildMonoHtml(String? key,
        [String? configJson, String reference = '']) =>
    '''
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mono Connect</title>
</head>

<body onload="setupMonoConnect()" style="border-radius: 20px; background-color:#fff;height:100vh;overflow: hidden; ">
    <script src="https://connect.withmono.com/connect.js"></script>
    <script type="text/javascript">
        window.onload = setupMonoConnect;
        function setupMonoConnect() {
            var connect = new Connect({
                key: "$key",
                reference: `$reference`.length > 0 ? `$reference` : null,
                onSuccess: (code) =>
                    sendMessage({ type: "onSuccess", data: code}),
                onLoad: () => sendMessage({ type: "onLoad" }),
                onClose: () => sendMessage({ type: "onClose" }),
                onEvent: (eventName, data) =>
                  sendMessage({
                    type: "onEvent",
                    eventName: eventName,
                    data: { ...data },
                  }),
            });

            if (`$configJson`.length > 0){
              connect.setup(JSON.parse(`$configJson`))
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
    </script>
</body>

</html>
''';
