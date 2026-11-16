import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../sdk/storage/collection_tracker.dart';

/// Manages whether the user has completed (or dismissed) the interactive onboarding tutorial.
class OnboardingNotifier extends StateNotifier<bool> {
  static const String kOnboardingCompletedPrefKey = 'has_completed_onboarding';

  final SharedPreferences? _prefs;

  OnboardingNotifier([SharedPreferences? prefs, bool? initialCompleted])
      : _prefs = prefs,
        super(
          initialCompleted ??
              (prefs != null
                  ? (prefs.getBool(kOnboardingCompletedPrefKey) ?? false)
                  : true),
        );

  /// Marks onboarding as completed and persists to SharedPreferences.
  Future<void> completeOnboarding() async {
    state = true;
    await _prefs?.setBool(kOnboardingCompletedPrefKey, true);
  }

  /// Resets onboarding so the interactive tutorial overlay is shown again from Step 1.
  Future<void> resetOnboarding() async {
    state = false;
    await _prefs?.setBool(kOnboardingCompletedPrefKey, false);
  }
}

/// Provides whether the first-launch onboarding tutorial has been completed (`true` = hidden, `false` = active).
final onboardingCompletedProvider =
    StateNotifierProvider<OnboardingNotifier, bool>((ref) {
  SharedPreferences? prefs;
  try {
    prefs = ref.watch(sharedPreferencesProvider);
  } catch (_) {
    prefs = null;
  }
  return OnboardingNotifier(prefs);
});

/// Tracks the active 0-based step index inside the onboarding tutorial overlay.
final onboardingStepProvider = StateProvider<int>((ref) => 0);
