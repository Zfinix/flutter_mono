# Flutter Mono

`** This is an unofficial SDK for flutter`

This package makes it easy to use the Mono connect widget in a flutter project.

## 📸 Screen Shots

<p float="left">
<img src="https://github.com/Zfinix/flutter_mono/blob/main/img/1.png?raw=true" width="300">
<img src="https://github.com/Zfinix/flutter_mono/blob/main/img/2.png?raw=true" width="300">
<img src="https://github.com/Zfinix/flutter_mono/blob/main/img/3.png?raw=true" width="300">
</p>

### Getting Started

- Register on the [Mono](https://app.withmono.com/dashboard) website and get your public and secret keys.
- Setup a server to [exchange tokens](https://docs.mono.co/api/bank-data/authorisation/exchange-token) to access user financial data with your Mono secret key.

### iOS

- Add the key `Privacy - Camera Usage Description` and a usage description to your `Info.plist`.

If editing `Info.plist` as text, add:

```xml
<key>NSCameraUsageDescription</key>
<string>your usage description here</string>
```

### Android

State the camera permission in your `android/app/src/main/AndroidManifest.xml` file.

```xml
<uses-permission android:name="android.permission.CAMERA"/>
```

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
      selectedInstitution: ConnectInstitution(
        id: "5f2d08be60b92e2888287702",
        authMethod: ConnectAuthMethod.mobileBanking,
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
      selectedInstitution: ConnectInstitution(
        id: "5f2d08be60b92e2888287702",
        authMethod: ConnectAuthMethod.mobileBanking,
      ),
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
