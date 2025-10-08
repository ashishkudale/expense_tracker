import 'package:equatable/equatable.dart';

abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
}

class OnboardingInProgress extends OnboardingState {
  const OnboardingInProgress();
}

class OnboardingSuccess extends OnboardingState {
  const OnboardingSuccess();
}

class OnboardingFailure extends OnboardingState {
  final String message;

  const OnboardingFailure(this.message);

  @override
  List<Object?> get props => [message];
}