import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/features/onboarding/bloc/onboarding_bloc.dart';
import 'package:expense_tracker/features/onboarding/bloc/onboarding_event.dart';
import 'package:expense_tracker/features/onboarding/bloc/onboarding_state.dart';
import 'package:expense_tracker/features/onboarding/domain/entities/user_profile.dart';
import 'package:expense_tracker/features/onboarding/domain/repositories/user_profile_repository.dart';
import 'package:expense_tracker/core/utils/result.dart' as app_result;
import 'package:shared_preferences/shared_preferences.dart';

class MockUserProfileRepository implements UserProfileRepository {
  bool shouldFail = false;
  UserProfile? savedProfile;

  @override
  Future<app_result.Result<UserProfile?>> getUserProfile() async {
    return app_result.Success(savedProfile);
  }

  @override
  Future<app_result.Result<UserProfile>> saveUserProfile(UserProfile profile) async {
    if (shouldFail) {
      return const app_result.Failure('Failed to save profile');
    }
    savedProfile = profile;
    return app_result.Success(profile);
  }

  @override
  Future<app_result.Result<bool>> deleteUserProfile() async {
    savedProfile = null;
    return const app_result.Success(true);
  }
}

void main() {
  group('OnboardingBloc', () {
    late OnboardingBloc bloc;
    late MockUserProfileRepository mockRepository;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      mockRepository = MockUserProfileRepository();
      bloc = OnboardingBloc(
        userProfileRepository: mockRepository,
        prefs: prefs,
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is OnboardingInitial', () {
      expect(bloc.state, const OnboardingInitial());
    });

    test('emits [OnboardingInProgress, OnboardingSuccess] when profile is saved successfully', () async {
      final states = <OnboardingState>[];
      bloc.stream.listen(states.add);

      bloc.add(const OnboardingSubmitted(
        name: 'John Doe',
        currencyCode: 'USD',
      ));

      await Future.delayed(const Duration(milliseconds: 100));

      expect(states, [
        const OnboardingInProgress(),
        const OnboardingSuccess(),
      ]);

      expect(mockRepository.savedProfile?.name, 'John Doe');
      expect(mockRepository.savedProfile?.currencyCode, 'USD');
      expect(prefs.getBool('onboarding_completed'), true);
    });

    test('emits [OnboardingInProgress, OnboardingFailure] when profile save fails', () async {
      mockRepository.shouldFail = true;
      final states = <OnboardingState>[];
      bloc.stream.listen(states.add);

      bloc.add(const OnboardingSubmitted(
        name: 'John Doe',
        currencyCode: 'USD',
      ));

      await Future.delayed(const Duration(milliseconds: 100));

      expect(states, [
        const OnboardingInProgress(),
        const OnboardingFailure('Failed to save profile'),
      ]);

      expect(prefs.getBool('onboarding_completed'), null);
    });
  });
}