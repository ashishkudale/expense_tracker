import 'package:json_annotation/json_annotation.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../domain/entities/recurring_payment.dart';

part 'recurring_payment_model.g.dart';

@JsonSerializable()
class RecurringPaymentModel extends RecurringPayment {
  const RecurringPaymentModel({
    required super.id,
    required super.type,
    required super.categoryId,
    required super.amount,
    super.note,
    required super.frequency,
    required super.startDate,
    super.endDate,
    required super.lastProcessedDate,
    required super.isActive,
    required super.createdAt,
  });

  factory RecurringPaymentModel.fromJson(Map<String, dynamic> json) =>
      _$RecurringPaymentModelFromJson(json);

  Map<String, dynamic> toJson() => _$RecurringPaymentModelToJson(this);

  factory RecurringPaymentModel.fromEntity(RecurringPayment entity) {
    return RecurringPaymentModel(
      id: entity.id,
      type: entity.type,
      categoryId: entity.categoryId,
      amount: entity.amount,
      note: entity.note,
      frequency: entity.frequency,
      startDate: entity.startDate,
      endDate: entity.endDate,
      lastProcessedDate: entity.lastProcessedDate,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name.toUpperCase(),
      'category_id': categoryId,
      'amount': amount,
      'note': note,
      'frequency': frequency.name.toUpperCase(),
      'start_date': startDate.millisecondsSinceEpoch,
      'end_date': endDate?.millisecondsSinceEpoch,
      'last_processed_date': lastProcessedDate.millisecondsSinceEpoch,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory RecurringPaymentModel.fromMap(Map<String, dynamic> map) {
    return RecurringPaymentModel(
      id: map['id'] as String,
      type: TransactionType.values.firstWhere(
        (e) => e.name.toUpperCase() == (map['type'] as String).toUpperCase(),
      ),
      categoryId: map['category_id'] as String,
      amount: (map['amount'] as num).toDouble(),
      note: map['note'] as String?,
      frequency: RecurrenceFrequency.fromString(map['frequency'] as String),
      startDate: DateTime.fromMillisecondsSinceEpoch(map['start_date'] as int),
      endDate: map['end_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['end_date'] as int)
          : null,
      lastProcessedDate:
          DateTime.fromMillisecondsSinceEpoch(map['last_processed_date'] as int),
      isActive: (map['is_active'] as int) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }
}
