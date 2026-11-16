import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../sdk/models/wiki_item.dart';
import '../providers/scroll_providers.dart';
import '../providers/wiki_providers.dart';
import '../utils/wiki_icon_helper.dart';
import '../widgets/wiki_item_thumbnail.dart';

class WikiTab extends ConsumerStatefulWidget {
  const WikiTab({super.key});

  @override
  ConsumerState<WikiTab> createState() => _WikiTabState();
}

class _WikiSubcategoryGroup {
  final String subCategory;
  final WikiItemMetadata meta;
  final List<WikiItem> items;

  const _WikiSubcategoryGroup({
    required this.subCategory,
    required this.meta,
    required this.items,
  });
}

class _WikiTabState extends ConsumerState<WikiTab> {
  String? _selectedCategory;
  String? _selectedSubcategory;

  IconData _getCategoryIcon(String? category) {
    if (category == null) return Icons.grid_view;
    final cat = category.toLowerCase();
    if (cat.contains('vehicle')) return Icons.directions_car;
    if (cat.contains('weapon')) return Icons.gps_fixed;
    return Icons.category;
  }

  List<_WikiSubcategoryGroup> _groupItemsBySubcategory(List<WikiItem> items) {
    final Map<String, List<WikiItem>> grouped = {};
    final Map<String, WikiItemMetadata> metaBySubcat = {};

    for (final item in items) {
      final meta = getWikiItemMetadata(item);
      grouped.putIfAbsent(meta.subCategory, () => []).add(item);
      metaBySubcat.putIfAbsent(meta.subCategory, () => meta);
    }

    final canonicalOrder = [
      ...kVehicleSubcategories.map((m) => m.subCategory),
      ...kWeaponSubcategories.map((m) => m.subCategory),
    ];

    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        final idxA = canonicalOrder.indexOf(a);
        final idxB = canonicalOrder.indexOf(b);
        if (idxA != -1 && idxB != -1) return idxA.compareTo(idxB);
        if (idxA != -1) return -1;
        if (idxB != -1) return 1;
        return a.compareTo(b);
      });

    return sortedKeys
        .map(
          (key) => _WikiSubcategoryGroup(
            subCategory: key,
            meta: metaBySubcat[key]!,
            items: grouped[key]!,
          ),
        )
        .toList();
  }

  Widget _buildCountBadge(BuildContext context, int count, {Color? color}) {
    final badgeColor = color ?? Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: badgeColor,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, _WikiSubcategoryGroup group) {
    return Padding(
      key: Key('wiki_section_header_${group.subCategory}'),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: group.meta.accentColor.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(
              group.meta.icon,
              size: 16,
              color: group.meta.accentColor,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${group.subCategory} (${group.items.length})',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: group.meta.accentColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWikiItemCard(BuildContext context, WikiItem item) {
    final meta = getWikiItemMetadata(item);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1.5,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: WikiItemThumbnail(item: item),
        title: Text(
          item.title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: meta.accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: meta.accentColor.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      meta.icon,
                      size: 12,
                      color: meta.accentColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      meta.subType,
                      style: TextStyle(
                        color: meta.accentColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                item.category,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: meta.accentColor.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
              ),
            ],
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          size: 20,
        ),
        onTap: () {
          context.push('/wiki/detail', extra: item);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wikiItemsAsyncValue = ref.watch(wikiItemsProvider);

    return wikiItemsAsyncValue.when(
      data: (allItems) {
        final categories = allItems.map((i) => i.category).toSet().toList();

        final categoryItems = _selectedCategory == null
            ? allItems
            : allItems.where((i) => i.category == _selectedCategory).toList();

        final availableSubcategories = _selectedCategory == null
            ? const <WikiItemMetadata>[]
            : getWikiSubcategoriesForCategory(_selectedCategory!);

        final items = _selectedSubcategory == null
            ? categoryItems
            : categoryItems
                .where((i) => getWikiItemMetadata(i).subCategory == _selectedSubcategory)
                .toList();

        final groups = _groupItemsBySubcategory(items);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tier 1: Top-Level Category Filter Bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: [
                  FilterChip(
                    key: const Key('wiki_category_chip_All'),
                    avatar: Icon(
                      _getCategoryIcon(null),
                      size: 16,
                      color: _selectedCategory == null
                          ? Theme.of(context).colorScheme.onSecondaryContainer
                          : null,
                    ),
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('All'),
                        const SizedBox(width: 6),
                        _buildCountBadge(context, allItems.length),
                      ],
                    ),
                    selected: _selectedCategory == null,
                    onSelected: (_) {
                      setState(() {
                        _selectedCategory = null;
                        _selectedSubcategory = null;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  ...categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    final catCount = allItems.where((i) => i.category == cat).length;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        key: Key('wiki_category_chip_$cat'),
                        avatar: Icon(
                          _getCategoryIcon(cat),
                          size: 16,
                          color: isSelected
                              ? Theme.of(context).colorScheme.onSecondaryContainer
                              : null,
                        ),
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(cat),
                            const SizedBox(width: 6),
                            _buildCountBadge(context, catCount),
                          ],
                        ),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() {
                            _selectedCategory = cat;
                            _selectedSubcategory = null;
                          });
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Tier 2: Contextual Subcategory Filter Bar (when Vehicles or Weapons is active)
            if (availableSubcategories.isNotEmpty)
              SingleChildScrollView(
                key: const Key('wiki_subcategory_filter_bar'),
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 6),
                child: Row(
                  children: [
                    FilterChip(
                      key: const Key('wiki_subcat_chip_All'),
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('All Subcategories'),
                          const SizedBox(width: 6),
                          _buildCountBadge(context, categoryItems.length),
                        ],
                      ),
                      selected: _selectedSubcategory == null,
                      onSelected: (_) {
                        setState(() {
                          _selectedSubcategory = null;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    ...availableSubcategories.map((subMeta) {
                      final isSubSelected = _selectedSubcategory == subMeta.subCategory;
                      final subCount = categoryItems
                          .where((i) => getWikiItemMetadata(i).subCategory == subMeta.subCategory)
                          .length;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          key: Key('wiki_subcat_chip_${subMeta.subCategory}'),
                          avatar: Icon(
                            subMeta.icon,
                            size: 15,
                            color: subMeta.accentColor,
                          ),
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(subMeta.subCategory),
                              const SizedBox(width: 6),
                              _buildCountBadge(
                                context,
                                subCount,
                                color: subMeta.accentColor,
                              ),
                            ],
                          ),
                          selected: isSubSelected,
                          selectedColor: subMeta.accentColor.withValues(alpha: 0.22),
                          onSelected: (_) {
                            setState(() {
                              _selectedSubcategory =
                                  isSubSelected ? null : subMeta.subCategory;
                            });
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),

            Expanded(
              child: ListView(
                controller: ref.watch(wikiScrollControllerProvider),
                children: [
                  for (final group in groups) ...[
                    _buildSectionHeader(context, group),
                    for (final item in group.items) _buildWikiItemCard(context, item),
                  ],
                ],
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
