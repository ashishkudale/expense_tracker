// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_payment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecurringPaymentModel _$RecurringPaymentModelFromJson(
  Map<String, dynamic> json,
) => RecurringPaymentModel(
  id: json['id'] as String,
  type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
  categoryId: json['categoryId'] as String,
  amount: (json['amount'] as num).toDouble(),
  note: json['note'] as String?,
  frequency: $enumDecode(_$RecurrenceFrequencyEnumMap, json['frequency']),
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: json['endDate'] == null
      ? null
      : DateTime.parse(json['endDate'] as String),
  lastProcessedDate: DateTime.parse(json['lastProcessedDate'] as String),
  isActive: json['isActive'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$RecurringPaymentModelToJson(
  RecurringPaymentModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': _$TransactionTypeEnumMap[instance.type]!,
  'categoryId': instance.categoryId,
  'amount': instance.amount,
  'note': instance.note,
  'frequency': _$RecurrenceFrequencyEnumMap[instance.frequency]!,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate?.toIso8601String(),
  'lastProcessedDate': instance.lastProcessedDate.toIso8601String(),
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$TransactionTypeEnumMap = {
  TransactionType.spend: 'spend',
  TransactionType.earn: 'earn',
};

const _$RecurrenceFrequencyEnumMap = {
  RecurrenceFrequency.daily: 'daily',
  RecurrenceFrequency.weekly: 'weekly',
  RecurrenceFrequency.monthly: 'monthly',
  RecurrenceFrequency.quarterly: 'quarterly',
  RecurrenceFrequency.yearly: 'yearly',
};
