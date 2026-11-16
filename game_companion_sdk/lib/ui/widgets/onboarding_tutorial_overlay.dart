import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/onboarding_provider.dart';

class OnboardingStepData {
  final String title;
  final String subtitle;
  final String description;
  final String highlightTip;
  final IconData icon;
  final Color accentColor;

  const OnboardingStepData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.highlightTip,
    required this.icon,
    required this.accentColor,
  });
}

const List<OnboardingStepData> kOnboardingSteps = [
  OnboardingStepData(
    title: 'Smart Map Filters',
    subtitle: 'Clean by Default, Full Control When Needed',
    description:
        'The map starts with only Services (Safehouses, Properties & Ammu-Nation) enabled so it stays readable. Toggle Collectibles, Stunts, or Secrets & World in the top bar — or tap the bottom-right Filters button for individual subcategories.',
    highlightTip: 'Tip: Tap "All" in the top bar to reveal all 330 GTA V pins at once.',
    icon: Icons.filter_alt_outlined,
    accentColor: Color(0xFF00E676),
  ),
  OnboardingStepData(
    title: 'Tracking & Find Next Closest',
    subtitle: 'Track Progress & Chain Nearby Collectibles',
    description:
        'Tap any map pin to inspect coordinates and Stunt Jump specifications. Mark items as Collected to update your X/237 Found progress pill, then tap "Find Next Closest" to automatically pan to and highlight the nearest uncollected item.',
    highlightTip: 'Tip: Toggle "Hide Found" to focus only on your remaining collectibles.',
    icon: Icons.near_me_outlined,
    accentColor: Color(0xFF00B0FF),
  ),
  OnboardingStepData(
    title: 'Wiki & View Spawn on Map',
    subtitle: 'Vehicles, Weapons & Acquisition Secrets',
    description:
        'Browse Vehicles and Weapons by subcategory (Supercars, Sports, Muscle, Pistols, Heavy & more). Open any entry for free-roam spawn locations, upgrade secrets (like the Karin Sultan -> Sultan RS mod), and tap "View Spawn on Map" to jump straight to the pin.',
    highlightTip: 'Tip: Subcategory chips filter vehicles & weapons in a single tap.',
    icon: Icons.menu_book_outlined,
    accentColor: Color(0xFFFFB300),
  ),
  OnboardingStepData(
    title: 'Curated Guides & Global Search',
    subtitle: '100% Checklists, Stock Market & Instant Lookup',
    description:
        'Explore the Guides tab for Lester\'s Assassination stock market walkthroughs and YouTube previews, or use the top Global Search Bar from anywhere to search Map POIs, Wiki items, spawn neighborhoods, and Guides simultaneously.',
    highlightTip: 'Tip: Replay this tutorial anytime from the side drawer or the ? button.',
    icon: Icons.search_rounded,
    accentColor: Color(0xFFD0BCFF),
  ),
];

class OnboardingTutorialOverlay extends ConsumerWidget {
  const OnboardingTutorialOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompleted = ref.watch(onboardingCompletedProvider);
    if (isCompleted) {
      return const SizedBox.shrink();
    }

    final rawStep = ref.watch(onboardingStepProvider);
    final stepIndex = rawStep.clamp(0, kOnboardingSteps.length - 1);
    final step = kOnboardingSteps[stepIndex];
    final isLastStep = stepIndex == kOnboardingSteps.length - 1;

    return Material(
      key: const Key('onboarding_tutorial_overlay'),
      color: Colors.black.withValues(alpha: 0.68),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1C24),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: step.accentColor.withValues(alpha: 0.55),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: step.accentColor.withValues(alpha: 0.2),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Step Badge & Skip Action
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: step.accentColor.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Step ${stepIndex + 1} of ${kOnboardingSteps.length}',
                            style: TextStyle(
                              color: step.accentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        TextButton(
                          key: const Key('onboarding_skip_button'),
                          onPressed: () {
                            ref.read(onboardingStepProvider.notifier).state = 0;
                            ref
                                .read(onboardingCompletedProvider.notifier)
                                .completeOnboarding();
                          },
                          child: const Text('Skip'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Icon & Title Row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: step.accentColor.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: step.accentColor.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Icon(
                            step.icon,
                            color: step.accentColor,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                step.subtitle,
                                style: TextStyle(
                                  color: step.accentColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Description
                    Text(
                      step.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            height: 1.45,
                          ),
                    ),
                    const SizedBox(height: 14),

                    // Callout Tip Pill
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: step.accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: step.accentColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            size: 16,
                            color: step.accentColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              step.highlightTip,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Footer: Step Dots + Back / Next / Get Started Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            kOnboardingSteps.length,
                            (idx) {
                              final isCurrent = idx == stepIndex;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(right: 6),
                                width: isCurrent ? 20 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isCurrent
                                      ? step.accentColor
                                      : Colors.white.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            },
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (stepIndex > 0) ...[
                              OutlinedButton(
                                key: const Key('onboarding_back_button'),
                                onPressed: () {
                                  ref
                                      .read(onboardingStepProvider.notifier)
                                      .state = stepIndex - 1;
                                },
                                child: const Text('Back'),
                              ),
                              const SizedBox(width: 8),
                            ],
                            FilledButton(
                              key: const Key('onboarding_next_button'),
                              style: FilledButton.styleFrom(
                                backgroundColor: step.accentColor,
                                foregroundColor: Colors.black,
                              ),
                              onPressed: () {
                                if (isLastStep) {
                                  ref
                                      .read(onboardingStepProvider.notifier)
                                      .state = 0;
                                  ref
                                      .read(onboardingCompletedProvider.notifier)
                                      .completeOnboarding();
                                } else {
                                  ref
                                      .read(onboardingStepProvider.notifier)
                                      .state = stepIndex + 1;
                                }
                              },
                              child: Text(
                                isLastStep ? 'Get Started' : 'Next',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
