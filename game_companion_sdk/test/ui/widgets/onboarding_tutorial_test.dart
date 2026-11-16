import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:game_companion_sdk/sdk/storage/collection_tracker.dart';
import 'package:game_companion_sdk/ui/providers/onboarding_provider.dart';
import 'package:game_companion_sdk/ui/screens/shell_screen.dart';
import 'package:game_companion_sdk/ui/widgets/onboarding_tutorial_overlay.dart';

void main() {
  group('OnboardingNotifier & Persistence', () {
    test('Defaults to false on first launch with SharedPreferences and persists completion across sessions', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container1 = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );

      // First launch: onboarding is not completed
      expect(container1.read(onboardingCompletedProvider), isFalse);
      expect(prefs.getBool(OnboardingNotifier.kOnboardingCompletedPrefKey), isNull);

      // Complete onboarding
      await container1.read(onboardingCompletedProvider.notifier).completeOnboarding();
      expect(container1.read(onboardingCompletedProvider), isTrue);
      expect(prefs.getBool(OnboardingNotifier.kOnboardingCompletedPrefKey), isTrue);

      // Second session: remembers completion
      final container2 = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      expect(container2.read(onboardingCompletedProvider), isTrue);

      // Reset onboarding for replay
      await container2.read(onboardingCompletedProvider.notifier).resetOnboarding();
      expect(container2.read(onboardingCompletedProvider), isFalse);
      expect(prefs.getBool(OnboardingNotifier.kOnboardingCompletedPrefKey), isFalse);
    });
  });

  group('OnboardingTutorialOverlay & ShellScreen Integration', () {
    testWidgets('Steps through all 4 onboarding cards, supports Back navigation, and completes on Get Started', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  Center(child: Text('Underlying Map Content')),
                  OnboardingTutorialOverlay(),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Step 1 of 4 is displayed
      expect(find.byKey(const Key('onboarding_tutorial_overlay')), findsOneWidget);
      expect(find.text('Step 1 of 4'), findsOneWidget);
      expect(find.text('Smart Map Filters'), findsOneWidget);
      expect(find.byKey(const Key('onboarding_back_button')), findsNothing);
      expect(find.text('Next'), findsOneWidget);

      // Advance to Step 2
      await tester.tap(find.byKey(const Key('onboarding_next_button')));
      await tester.pumpAndSettle();
      expect(find.text('Step 2 of 4'), findsOneWidget);
      expect(find.text('Tracking & Find Next Closest'), findsOneWidget);
      expect(find.byKey(const Key('onboarding_back_button')), findsOneWidget);

      // Test Back button returns to Step 1
      await tester.tap(find.byKey(const Key('onboarding_back_button')));
      await tester.pumpAndSettle();
      expect(find.text('Step 1 of 4'), findsOneWidget);

      // Advance to Step 2 -> Step 3 -> Step 4
      await tester.tap(find.byKey(const Key('onboarding_next_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('onboarding_next_button')));
      await tester.pumpAndSettle();
      expect(find.text('Step 3 of 4'), findsOneWidget);
      expect(find.text('Wiki & View Spawn on Map'), findsOneWidget);

      await tester.tap(find.byKey(const Key('onboarding_next_button')));
      await tester.pumpAndSettle();
      expect(find.text('Step 4 of 4'), findsOneWidget);
      expect(find.text('Curated Guides & Global Search'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);

      // Tap 'Get Started' to finish onboarding
      await tester.tap(find.byKey(const Key('onboarding_next_button')));
      await tester.pumpAndSettle();

      // Overlay is dismissed and completion is persisted
      expect(find.byKey(const Key('onboarding_tutorial_overlay')), findsNothing);
      expect(container.read(onboardingCompletedProvider), isTrue);
      expect(prefs.getBool(OnboardingNotifier.kOnboardingCompletedPrefKey), isTrue);
    });

    testWidgets('Skip dismisses onboarding and Replay App Tutorial from ShellScreen AppBar or Drawer relaunches from Step 1', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );

      final router = GoRouter(
        initialLocation: '/map',
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              return ShellScreen(navigationShell: navigationShell);
            },
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/map',
                    builder: (context, state) => const Center(child: Text('Map Tab Placeholder')),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/wiki',
                    builder: (context, state) => const Center(child: Text('Wiki Tab Placeholder')),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/guides',
                    builder: (context, state) => const Center(child: Text('Guides Tab Placeholder')),
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // First launch shows Step 1
      expect(find.byKey(const Key('onboarding_tutorial_overlay')), findsOneWidget);
      expect(find.text('Step 1 of 4'), findsOneWidget);

      // Tap Skip
      await tester.tap(find.byKey(const Key('onboarding_skip_button')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('onboarding_tutorial_overlay')), findsNothing);
      expect(container.read(onboardingCompletedProvider), isTrue);

      // Replay via ShellScreen AppBar '?' button
      await tester.tap(find.byKey(const Key('shell_replay_tutorial_button')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('onboarding_tutorial_overlay')), findsOneWidget);
      expect(find.text('Step 1 of 4'), findsOneWidget);

      // Skip again, then replay from the GameSwitcherDrawer
      await tester.tap(find.byKey(const Key('onboarding_skip_button')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('onboarding_tutorial_overlay')), findsNothing);

      // Open drawer and tap 'Replay App Tutorial'
      final scaffoldState = tester.firstState<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('drawer_replay_tutorial_tile')), findsOneWidget);
      await tester.tap(find.byKey(const Key('drawer_replay_tutorial_tile')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('onboarding_tutorial_overlay')), findsOneWidget);
      expect(find.text('Step 1 of 4'), findsOneWidget);
    });
  });
}
