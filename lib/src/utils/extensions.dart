import 'package:flutter/material.dart';

extension CustomContext on BuildContext {
  double screenHeight([double percent = 1]) =>
      MediaQuery.of(this).size.height * percent;

  double screenWidth([double percent = 1]) =>
      MediaQuery.of(this).size.width * percent;
}

extension StringRemovePrefixSuffixExtension on String {
  /// If this [String] starts with the given [prefix], returns a copy of this
  /// string with the prefix removed. Otherwise, returns this [String].
  String removePrefix(String prefix) {
    if (startsWith(prefix)) {
      return substring(prefix.length, length);
    } else {
      return this;
    }
  }

  /// If this [String] ends with the given [suffix], returns a copy of this
  /// [String] with the suffix removed. Otherwise, returns this [String].
  String removeSuffix(String suffix) {
    if (endsWith(suffix)) {
      return substring(0, length - suffix.length);
    } else {
      return this;
    }
  }
}
