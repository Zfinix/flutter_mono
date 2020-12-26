# ACR Cloud SDK
`** This is an unofficial SDK for flutter`

This package make it easy to use the Mono connect widget in a flutter project.

## 📸 Screen Shots

<p float="left">
<img src="https://github.com/Zfinix/flutter_mono/blob/main/1.png?raw=true" width="200">
<img src="https://github.com/Zfinix/flutter_mono/blob/main/2.png?raw=true" width="200">
</p>

### 🚀 How to Use plugin

- Launch MonoFlutter with launchMono method

```dart
import 'package:flutter_mono/flutter_mono.dart';
    
  void launch() async {
      await MonoFlutter.launchMono(
              context,
              key: 'Your Public Key', // from https://app.withmono.com/apps
              onClosed: () {
                  print('Widget closed')
              },
              onSuccess: (String code) {
                  print("Linked successfully: $code");
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
         onClosed: () {
            print('Widget closed')
         },
         onSuccess: (String code) {
            print("Linked successfully: $code");
         },
        error: Text('Error'),
      )

      ...
  
```

## ✨ Contribution
 Lots of PR's would be needed to improve this plugin. So lots of suggestions and PRs are welcome.
