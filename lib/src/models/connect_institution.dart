import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_mono/src/utils/extensions.dart';

enum ConnectAuthMethod {
  internetBanking("internet_banking"),
  mobileBanking("mobile_banking");

  final String value;

  const ConnectAuthMethod(this.value);

  static ConnectAuthMethod fromValue(String value) {
    final type =
        ConnectAuthMethod.values.firstWhereOrNull((e) => e.value == value);

    return type ?? ConnectAuthMethod.internetBanking;
  }
}

class ConnectInstitution with EquatableMixin {
  final String id;
  final ConnectAuthMethod authMethod;

  const ConnectInstitution({
    required this.id,
    required this.authMethod,
  });

  ConnectInstitution copyWith({
    String? id,
    ConnectAuthMethod? authMethod,
  }) {
    return ConnectInstitution(
      id: id ?? this.id,
      authMethod: authMethod ?? this.authMethod,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'auth_method': authMethod.value,
    };
  }

  factory ConnectInstitution.fromMap(Map<String, dynamic> map) {
    return ConnectInstitution(
      id: map['id'] as String,
      authMethod: ConnectAuthMethod.fromValue(map['auth_method'] as String),
    );
  }

  String toJson() => json.encode(toMap());

  factory ConnectInstitution.fromJson(String source) =>
      ConnectInstitution.fromMap(json.decode(source));

  @override
  String toString() => 'ConnectInstitution(id: $id, authMethod: $authMethod)';

  @override
  List<Object> get props => [id, authMethod];
}
