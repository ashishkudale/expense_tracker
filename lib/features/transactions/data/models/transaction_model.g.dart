// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionModel _$TransactionModelFromJson(Map<String, dynamic> json) =>
    TransactionModel(
      id: json['id'] as String,
      type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
      categoryId: json['categoryId'] as String,
      amount: (json['amount'] as num).toDouble(),
      occurredOn: DateTime.parse(json['occurredOn'] as String),
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$TransactionModelToJson(TransactionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$TransactionTypeEnumMap[instance.type]!,
      'categoryId': instance.categoryId,
      'amount': instance.amount,
      'occurredOn': instance.occurredOn.toIso8601String(),
      'note': instance.note,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$TransactionTypeEnumMap = {
  TransactionType.spend: 'spend',
  TransactionType.earn: 'earn',
};
