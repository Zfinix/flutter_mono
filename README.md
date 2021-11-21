# Flutter Mono

`** This is an unofficial SDK for flutter`

This package make it easy to use the Mono connect widget in a flutter project.

## 📸 Screen Shots

<p float="left">
<img src="https://github.com/Zfinix/flutter_mono/blob/main/1.png?raw=true" width="200">
<img src="https://github.com/Zfinix/flutter_mono/blob/main/2.png?raw=true" width="200">
<img src="https://github.com/Zfinix/flutter_mono/blob/main/3.png?raw=true" width="200">
</p>

### 🚀 How to Use plugin

- Launch MonoFlutter with launchMono method

```dart
import 'package:flutter_mono/flutter_mono.dart';

  void launch() async {
       await MonoFlutter.launchMono(
               context,
               key: 'Your Public Key', // from https://app.withmono.com/apps
               reference: "some_random_string"
               configJson: '{
                  "selectedInstitution": {
                    "id": "5f2d08c060b92e2888287706", 
                    "auth_method": "internet_banking" 
                  }
               }' /// must be a valid JSON string
               showLogs: true,
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
  }
```

- Use MonoView widget

```dart
import 'package:flutter_mono/flutter_mono.dart';

     ...

   MonoView(
      apiKey: 'Your Public Key', // from https://app.withmono.com/apps
      reference: "some_random_string"
      configJson: '{
          "selectedInstitution": {
            "id": "5f2d08c060b92e2888287706", 
            "auth_method": "internet_banking" 
           }
      }' /// must be a valid JSON string
      showLogs: true,
      onClose: () {
         print('onClose');
      },
      onLoad: () {
         print('onLoad');
      },
      onEvent: (eventName, eventData) {
         switch (eventName) {
            case 'mono.connect.institution_selected':
            /// do something
            break;
         }
      },
      onSuccess: (data) {
         print('Success: ${data.toJson()}');
      },
   )

      ...

```

## ✨ Contribution

Lots of PR's would be needed to improve this plugin. So lots of suggestions and PRs are welcome.
