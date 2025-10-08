import 'package:equatable/equatable.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

class OnboardingSubmitted extends OnboardingEvent {
  final String name;
  final String currencyCode;

  const OnboardingSubmitted({
    required this.name,
    required this.currencyCode,
  });

  @override
  List<Object?> get props => [name, currencyCode];
}