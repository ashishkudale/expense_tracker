import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String name;
  final String currencyCode;
  final String dateFormat;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.currencyCode,
    required this.createdAt,
    this.dateFormat = 'dd/MM/yyyy',
  });

  @override
  List<Object?> get props => [id, name, currencyCode, dateFormat, createdAt];
}