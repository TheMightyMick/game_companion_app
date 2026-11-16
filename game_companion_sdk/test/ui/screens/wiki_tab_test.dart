import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:game_companion_sdk/sdk/models/map_poi.dart';
import 'package:game_companion_sdk/sdk/models/wiki_item.dart';
import 'package:game_companion_sdk/sdk/map/target_map_position_provider.dart';
import 'package:game_companion_sdk/ui/providers/wiki_providers.dart';
import 'package:game_companion_sdk/ui/screens/wiki_tab.dart';
import 'package:game_companion_sdk/ui/screens/wiki_detail_screen.dart';
import 'package:game_companion_sdk/ui/providers/map_providers.dart';

void main() {
  testWidgets('WikiTab renders list of items', (WidgetTester tester) async {
    final mockItems = [
      WikiItem(
        id: '1',
        title: 'Item 1',
        category: 'Weapons',
        stats: {},
        description: 'Desc 1',
        thumbnailUrl: '', // blank handles bad network without image caching errors
      ),
      WikiItem(
        id: '2',
        title: 'Item 2',
        category: 'Vehicles',
        stats: {},
        description: 'Desc 2',
        thumbnailUrl: '',
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          wikiItemsProvider.overrideWith((ref) => Future.value(mockItems)),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: WikiTab(),
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Item 1'), findsOneWidget);
    expect(find.text('Item 2'), findsOneWidget);

    expect(find.text('All'), findsOneWidget);
    expect(find.text('Weapons'), findsNWidgets(2));
    expect(find.text('Vehicles'), findsNWidgets(2));
  });

  testWidgets('WikiDetailScreen renders stats and linear progress indicator', (WidgetTester tester) async {
    final item = WikiItem(
      id: '1',
      title: 'Adder',
      category: 'Vehicles',
      stats: {
        'Speed': 0.85,
      },
      description: 'A very fast supercar.',
      thumbnailUrl: '',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mapPoiProvider.overrideWith((ref) => Future.value([])),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: WikiDetailScreen(item: item),
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Adder'), findsOneWidget);
    expect(find.text('Speed'), findsOneWidget);
    expect(find.text('85%'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);
  });

  testWidgets('WikiTab navigates to WikiDetailScreen with BackButton and pops back', (WidgetTester tester) async {
    final mockItems = [
      WikiItem(
        id: '1',
        title: 'Item 1',
        category: 'Weapons',
        stats: {'Damage': 0.5},
        description: 'Desc 1',
        thumbnailUrl: '',
      ),
    ];

    final container = ProviderContainer(
      overrides: [
        wikiItemsProvider.overrideWith((ref) => Future.value(mockItems)),
        mapPoiProvider.overrideWith((ref) => Future.value([])),
      ],
    );

    final router = GoRouter(
      initialLocation: '/wiki',
      routes: [
        GoRoute(
          path: '/wiki',
          builder: (context, state) => const Scaffold(body: WikiTab()),
        ),
        GoRoute(
          path: '/wiki/detail',
          builder: (context, state) {
            final item = state.extra as WikiItem;
            return WikiDetailScreen(item: item);
          },
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

    expect(find.text('Item 1'), findsOneWidget);

    // Tap on Item 1 to open detail view
    await tester.tap(find.text('Item 1'));
    await tester.pumpAndSettle();

    // Verify detail screen is displayed
    expect(find.text('Desc 1'), findsOneWidget);

    // Verify BackButton exists and tap it
    expect(find.byType(BackButton), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    // Verify returned back to WikiTab
    expect(find.text('Item 1'), findsOneWidget);
    expect(find.text('Desc 1'), findsNothing);
  });

  testWidgets('WikiDetailScreen BackButton navigates back to /wiki if cannot pop', (WidgetTester tester) async {
    final item = WikiItem(
      id: '1',
      title: 'Item 1',
      category: 'Weapons',
      stats: {},
      description: 'Desc 1',
      thumbnailUrl: '',
    );

    final container = ProviderContainer(
      overrides: [
        wikiItemsProvider.overrideWith((ref) => Future.value([item])),
        mapPoiProvider.overrideWith((ref) => Future.value([])),
      ],
    );

    final router = GoRouter(
      initialLocation: '/wiki/detail',
      routes: [
        GoRoute(
          path: '/wiki',
          builder: (context, state) => const Scaffold(body: Text('Wiki List View')),
        ),
        GoRoute(
          path: '/wiki/detail',
          builder: (context, state) => WikiDetailScreen(item: item),
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

    expect(find.byType(BackButton), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('Wiki List View'), findsOneWidget);
  });

  testWidgets('WikiTab supports two-tier category & subcategory filtering, grouped section headers, and category switch reset', (WidgetTester tester) async {
    final mockItems = [
      WikiItem(
        id: 'v_adder',
        title: 'Truffade Adder',
        category: 'Vehicles',
        stats: {'Speed': 0.86},
        description: 'Hypercar',
        thumbnailUrl: '',
      ),
      WikiItem(
        id: 'v_elegy_rh8',
        title: 'Annis Elegy RH8',
        category: 'Vehicles',
        stats: {'Speed': 0.80},
        description: 'Sports car',
        thumbnailUrl: '',
      ),
      WikiItem(
        id: 'v_dominator',
        title: 'Vapid Dominator',
        category: 'Vehicles',
        stats: {'Speed': 0.78},
        description: 'Muscle car',
        thumbnailUrl: '',
      ),
      WikiItem(
        id: 'w_pistol',
        title: 'Standard Pistol',
        category: 'Weapons',
        stats: {'Damage': 0.26},
        description: 'Sidearm',
        thumbnailUrl: '',
      ),
      WikiItem(
        id: 'w_pump_shotgun',
        title: 'Pump Shotgun',
        category: 'Weapons',
        stats: {'Damage': 0.67},
        description: 'Shotgun',
        thumbnailUrl: '',
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          wikiItemsProvider.overrideWith((ref) => Future.value(mockItems)),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: WikiTab(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Initially on 'All' top-level category: secondary subcategory bar is hidden,
    // and grouped section headers are displayed
    expect(find.byKey(const Key('wiki_subcategory_filter_bar')), findsNothing);
    expect(find.byKey(const Key('wiki_section_header_Supercars')), findsOneWidget);
    expect(find.byKey(const Key('wiki_section_header_Sports')), findsOneWidget);
    expect(find.byKey(const Key('wiki_section_header_Muscle')), findsOneWidget);
    expect(find.byKey(const Key('wiki_section_header_Pistols')), findsOneWidget);
    expect(find.byKey(const Key('wiki_section_header_Shotguns')), findsOneWidget);
    expect(find.text('Truffade Adder'), findsOneWidget);
    expect(find.text('Standard Pistol'), findsOneWidget);

    // Select 'Vehicles' top-level category chip
    await tester.tap(find.byKey(const Key('wiki_category_chip_Vehicles')));
    await tester.pumpAndSettle();

    // Secondary subcategory FilterChip bar is now visible with Vehicle subcategories
    expect(find.byKey(const Key('wiki_subcategory_filter_bar')), findsOneWidget);
    expect(find.byKey(const Key('wiki_subcat_chip_Supercars')), findsOneWidget);
    expect(find.byKey(const Key('wiki_subcat_chip_Sports')), findsOneWidget);
    expect(find.byKey(const Key('wiki_subcat_chip_Muscle')), findsOneWidget);
    // Weapons are filtered out
    expect(find.text('Standard Pistol'), findsNothing);
    expect(find.text('Truffade Adder'), findsOneWidget);
    expect(find.text('Annis Elegy RH8'), findsOneWidget);
    expect(find.text('Vapid Dominator'), findsOneWidget);

    // Tap 'Supercars' subcategory chip
    await tester.tap(find.byKey(const Key('wiki_subcat_chip_Supercars')));
    await tester.pumpAndSettle();

    // Only Supercars are shown
    expect(find.text('Truffade Adder'), findsOneWidget);
    expect(find.text('Annis Elegy RH8'), findsNothing);
    expect(find.text('Vapid Dominator'), findsNothing);

    // Switch top-level category to 'Weapons' -> resets selected subcategory to All
    await tester.tap(find.byKey(const Key('wiki_category_chip_Weapons')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('wiki_subcat_chip_Pistols')), findsOneWidget);
    expect(find.byKey(const Key('wiki_subcat_chip_Shotguns')), findsOneWidget);
    expect(find.byKey(const Key('wiki_subcat_chip_SMGs')), findsOneWidget);
    // Both weapons are visible because subcategory filter reset to All
    expect(find.text('Standard Pistol'), findsOneWidget);
    expect(find.text('Pump Shotgun'), findsOneWidget);
    expect(find.text('Truffade Adder'), findsNothing);

    // Filter by 'Shotguns' subcategory
    await tester.tap(find.byKey(const Key('wiki_subcat_chip_Shotguns')));
    await tester.pumpAndSettle();

    expect(find.text('Pump Shotgun'), findsOneWidget);
    expect(find.text('Standard Pistol'), findsNothing);
  });

  testWidgets('WikiDetailScreen displays Where to Find & Tips section and View Spawn on Map button navigates with shakeAndOpenCard', (WidgetTester tester) async {
    final adderItem = WikiItem(
      id: 'v_adder',
      title: 'Truffade Adder',
      category: 'Vehicles',
      subCategory: 'Supercars',
      stats: {'Speed': 0.86},
      description: 'Bugatti-inspired hypercar.',
      thumbnailUrl: '',
      relatedPoiId: 'spawn_adder_portola',
      spawnLocations: [
        'Rockford Hills (Portola Drive)',
        'Legendary Motorsport (\$1,000,000)',
      ],
      acquisitionTips: [
        'Spawns parked along the curb on Portola Drive outside Sessanta Nove.',
        'Drive two blocks away and loop back to refresh the parking spot.',
      ],
    );

    final adderSpawnPoi = MapPointOfInterest(
      id: 'spawn_adder_portola',
      name: 'Truffade Adder Rare Spawn (Portola Drive)',
      category: 'secrets_world',
      subCategory: 'vehicle_spawns',
      gameX: -812.0,
      gameY: -120.0,
      description: 'Rare hypercar street spawn in Rockford Hills.',
      isCollectable: false,
    );

    final container = ProviderContainer(
      overrides: [
        mapPoiProvider.overrideWith((ref) => Future.value([adderSpawnPoi])),
      ],
    );

    final router = GoRouter(
      initialLocation: '/wiki/detail',
      routes: [
        GoRoute(
          path: '/wiki/detail',
          builder: (context, state) => WikiDetailScreen(item: adderItem),
        ),
        GoRoute(
          path: '/map',
          builder: (context, state) => const Scaffold(body: Text('Map Spawn Destination')),
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

    // Verify Where to Find & Tips section, spawn locations, and acquisition tips
    expect(find.byKey(const Key('wiki_where_to_find_section')), findsOneWidget);
    expect(find.text('Where to Find & Tips'), findsOneWidget);
    expect(find.text('Rockford Hills (Portola Drive)'), findsOneWidget);
    expect(find.byIcon(Icons.place_outlined), findsWidgets);
    expect(
      find.textContaining('Spawns parked along the curb on Portola Drive'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.lightbulb_outline), findsNWidgets(2));

    // Verify 'View Spawn on Map' button is rendered and tap it
    final viewOnMapButton = find.byKey(const Key('wiki_view_on_map_button'));
    expect(viewOnMapButton, findsOneWidget);
    expect(find.text('View Spawn on Map'), findsOneWidget);

    await tester.ensureVisible(viewOnMapButton);
    await tester.pumpAndSettle();
    await tester.tap(viewOnMapButton);
    await tester.pumpAndSettle();

    expect(find.text('Map Spawn Destination'), findsOneWidget);
    final targetPos = container.read(targetMapPositionProvider);
    expect(targetPos, isNotNull);
    expect(targetPos?.poiId, 'spawn_adder_portola');
    expect(targetPos?.shakeAndOpenCard, isTrue);
  });
}
