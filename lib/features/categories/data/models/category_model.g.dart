// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryModel _$CategoryModelFromJson(Map<String, dynamic> json) =>
    CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$CategoryTypeEnumMap, json['type']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      archived: json['archived'] as bool? ?? false,
    );

Map<String, dynamic> _$CategoryModelToJson(CategoryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$CategoryTypeEnumMap[instance.type]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'archived': instance.archived,
    };

const _$CategoryTypeEnumMap = {
  CategoryType.spend: 'spend',
  CategoryType.earn: 'earn',
};
