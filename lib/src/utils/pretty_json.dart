import 'dart:convert';

String jsonPretty(dynamic obj) {
  String prettyprint;

  if (obj is Map ||
      obj is Map<dynamic, dynamic> ||
      obj is Map<String, dynamic>) {
    const encoder = JsonEncoder.withIndent('  ');
    prettyprint = encoder.convert(obj);
  } else {
    prettyprint = '$obj';
  }

  return prettyprint;
}
