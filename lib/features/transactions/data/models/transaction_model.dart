import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/transaction.dart';

part 'transaction_model.g.dart';

@JsonSerializable()
class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.type,
    required super.categoryId,
    required super.amount,
    required super.occurredOn,
    super.note,
    required super.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionModelToJson(this);

  factory TransactionModel.fromEntity(Transaction entity) {
    return TransactionModel(
      id: entity.id,
      type: entity.type,
      categoryId: entity.categoryId,
      amount: entity.amount,
      occurredOn: entity.occurredOn,
      note: entity.note,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type == TransactionType.spend ? 'SPEND' : 'EARN',
      'category_id': categoryId,
      'amount': amount,
      'occurred_on': occurredOn.millisecondsSinceEpoch,
      'note': note,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      type: (map['type'] as String) == 'SPEND' 
          ? TransactionType.spend 
          : TransactionType.earn,
      categoryId: map['category_id'] as String,
      amount: (map['amount'] as num).toDouble(),
      occurredOn: DateTime.fromMillisecondsSinceEpoch(map['occurred_on'] as int),
      note: map['note'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }
}