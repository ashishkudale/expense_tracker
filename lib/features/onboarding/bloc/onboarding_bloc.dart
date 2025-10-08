import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../domain/entities/user_profile.dart';
import '../domain/repositories/user_profile_repository.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final UserProfileRepository _userProfileRepository;
  final SharedPreferences _prefs;
  static const String _onboardingKey = 'onboarding_completed';

  OnboardingBloc({
    required UserProfileRepository userProfileRepository,
    required SharedPreferences prefs,
  })  : _userProfileRepository = userProfileRepository,
        _prefs = prefs,
        super(const OnboardingInitial()) {
    on<OnboardingSubmitted>(_onOnboardingSubmitted);
  }

  Future<void> _onOnboardingSubmitted(
    OnboardingSubmitted event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(const OnboardingInProgress());

    final profile = UserProfile(
      id: const Uuid().v4(),
      name: event.name,
      currencyCode: event.currencyCode,
      createdAt: DateTime.now(),
    );

    final result = await _userProfileRepository.saveUserProfile(profile);

    await result.fold(
      onSuccess: (data) async {
        await _prefs.setBool(_onboardingKey, true);
        emit(const OnboardingSuccess());
      },
      onFailure: (message) async {
        emit(OnboardingFailure(message));
      },
    );
  }
}