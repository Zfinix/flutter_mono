import 'dart:convert';

import 'package:equatable/equatable.dart';

class MonoSuccessModel with EquatableMixin {
  final String type;
  final MonoData data;
  MonoSuccessModel({
    required this.type,
    required this.data,
  });

  MonoSuccessModel copyWith({
    String? type,
    MonoData? data,
  }) {
    return MonoSuccessModel(
      type: type ?? this.type,
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'data': data.toMap(),
    };
  }

  factory MonoSuccessModel.fromMap(Map<String, dynamic> map) {
    return MonoSuccessModel(
      type: map['type'],
      data: MonoData.fromMap(map['data'] ?? map['response']),
    );
  }

  String toJson() => json.encode(toMap());

  factory MonoSuccessModel.fromJson(String source) =>
      MonoSuccessModel.fromMap(json.decode(source));

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [type, data];
}

class MonoData with EquatableMixin {
  final String code;
  MonoData({
    required this.code,
  });

  MonoData copyWith({
    String? code,
  }) {
    return MonoData(
      code: code ?? this.code,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
    };
  }

  factory MonoData.fromMap(Map<String, dynamic> map) {
    return MonoData(
      code: map['code'],
    );
  }

  String toJson() => json.encode(toMap());

  factory MonoData.fromJson(String source) =>
      MonoData.fromMap(json.decode(source));

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [code];
}
