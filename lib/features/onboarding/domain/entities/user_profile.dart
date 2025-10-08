import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String name;
  final String currencyCode;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.currencyCode,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, currencyCode, createdAt];
}