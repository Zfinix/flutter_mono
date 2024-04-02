# Flutter Mono

`** This is an unofficial SDK for flutter`

This package makes it easy to use the Mono connect widget in a flutter project.

## 📸 Screen Shots

<p float="left">
<img src="https://github.com/Zfinix/flutter_mono/blob/main/img/1.png?raw=true" width="300">
<img src="https://github.com/Zfinix/flutter_mono/blob/main/img/2.png?raw=true" width="300">
<img src="https://github.com/Zfinix/flutter_mono/blob/main/img/3.png?raw=true" width="300">
</p>

### 🚀 How to Use plugin

- Launch MonoFlutter with launchMono method

```dart
import 'package:flutter_mono/flutter_mono.dart';

 void launch() async {
    FlutterMono(
      apiKey: 'Your Public Key', // from https://app.withmono.com/apps
      reference: "some_random_string",
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
        existingCustomer: MonoExistingCustomerModel(
          id: "1234-RTFG-ABCD", // REQUIRED
        ),
      ),
      configJson: const {
        "selectedInstitution": {
          "id": "5f2d08be60b92e2888287702",
          "auth_method": "mobile_banking"
        }
      },
      onClose: (it) =>log('Success: $it'),
      onLoad: () => log('widget_loaded'),
      onEvent: (eventName, eventData) {
        switch (eventName) {
          case 'mono.connect.institution_selected':
            /// do something
            break;
        }
      },
    ).launchMono(context);
 }
```

- Use MonoView widget

```dart
import 'package:flutter_mono/flutter_mono.dart';

   ...

   FlutterMono(
      apiKey: 'Your Public Key', // from https://app.withmono.com/apps
      reference: "some_random_string",
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
        existingCustomer: MonoExistingCustomerModel(
          id: "1234-RTFG-ABCD", // REQUIRED
        ),
      ),
      configJson: const {
        "selectedInstitution": {
          "id": "5f2d08be60b92e2888287702",
          "auth_method": "mobile_banking"
        }
      },
      onClose: (it) =>log('Success: $it'),
      onLoad: () => log('widget_loaded'),
      onEvent: (eventName, eventData) {
        switch (eventName) {
          case 'mono.connect.institution_selected':
            /// do something
            break;
        }
      },
    )

   ...

```

## ✨ Contribution

Lots of PR's would be needed to improve this plugin. So lots of suggestions and PRs are welcome.
