// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfileModel _$UserProfileModelFromJson(Map<String, dynamic> json) =>
    UserProfileModel(
      id: json['id'] as String,
      name: json['name'] as String,
      currencyCode: json['currencyCode'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      dateFormat: json['dateFormat'] as String? ?? 'dd/MM/yyyy',
    );

Map<String, dynamic> _$UserProfileModelToJson(UserProfileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'currencyCode': instance.currencyCode,
      'dateFormat': instance.dateFormat,
      'createdAt': instance.createdAt.toIso8601String(),
    };
