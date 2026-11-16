import 'package:flutter/material.dart';
import '../../sdk/models/wiki_item.dart';

class WikiItemMetadata {
  final IconData icon;
  final String subType;
  final String subCategory;
  final Color accentColor;

  const WikiItemMetadata({
    required this.icon,
    required this.subType,
    String? subCategory,
    required this.accentColor,
  }) : subCategory = subCategory ?? subType;
}

const List<WikiItemMetadata> kVehicleSubcategories = [
  WikiItemMetadata(
    icon: Icons.speed,
    subType: 'Supercar',
    subCategory: 'Supercars',
    accentColor: Color(0xFFFFB300), // Amber / Gold
  ),
  WikiItemMetadata(
    icon: Icons.directions_car,
    subType: 'Sports',
    subCategory: 'Sports',
    accentColor: Color(0xFF00B0FF), // Light Blue
  ),
  WikiItemMetadata(
    icon: Icons.local_fire_department,
    subType: 'Muscle',
    subCategory: 'Muscle',
    accentColor: Color(0xFFFF6D00), // Deep Orange
  ),
  WikiItemMetadata(
    icon: Icons.two_wheeler,
    subType: 'Motorcycle',
    subCategory: 'Motorcycles',
    accentColor: Color(0xFF00E676), // Green
  ),
  WikiItemMetadata(
    icon: Icons.flight,
    subType: 'Aircraft',
    subCategory: 'Aircraft',
    accentColor: Color(0xFF40C4FF), // Cyan
  ),
  WikiItemMetadata(
    icon: Icons.terrain,
    subType: 'Off-Road',
    subCategory: 'Off-Road',
    accentColor: Color(0xFFA1887F), // Earth Brown
  ),
];

const List<WikiItemMetadata> kWeaponSubcategories = [
  WikiItemMetadata(
    icon: Icons.security,
    subType: 'Handgun',
    subCategory: 'Pistols',
    accentColor: Color(0xFF536DFE), // Indigo
  ),
  WikiItemMetadata(
    icon: Icons.flash_on,
    subType: 'SMG',
    subCategory: 'SMGs',
    accentColor: Color(0xFFE040FB), // Purple
  ),
  WikiItemMetadata(
    icon: Icons.whatshot,
    subType: 'Shotgun',
    subCategory: 'Shotguns',
    accentColor: Color(0xFFFF5722), // Flame Orange
  ),
  WikiItemMetadata(
    icon: Icons.track_changes,
    subType: 'Rifle',
    subCategory: 'Rifles',
    accentColor: Color(0xFF00BFA5), // Teal
  ),
  WikiItemMetadata(
    icon: Icons.filter_center_focus,
    subType: 'Sniper',
    subCategory: 'Snipers',
    accentColor: Color(0xFF448AFF), // Blue
  ),
  WikiItemMetadata(
    icon: Icons.rocket_launch,
    subType: 'Heavy',
    subCategory: 'Heavy',
    accentColor: Color(0xFFFF1744), // Crimson
  ),
  WikiItemMetadata(
    icon: Icons.colorize,
    subType: 'Melee',
    subCategory: 'Melee',
    accentColor: Color(0xFF78909C), // Steel
  ),
];

/// Returns the ordered canonical subcategories for a top-level Wiki category.
List<WikiItemMetadata> getWikiSubcategoriesForCategory(String category) {
  final cat = category.trim().toLowerCase();
  if (cat.contains('vehicle')) {
    return kVehicleSubcategories;
  }
  if (cat.contains('weapon')) {
    return kWeaponSubcategories;
  }
  return const [];
}

/// Resolves subcategory metadata by subcategory or subType name.
WikiItemMetadata? getWikiSubcategoryMetadata(String subCategoryOrType) {
  final normalized = subCategoryOrType.trim().toLowerCase();
  if (normalized.isEmpty) return null;

  for (final meta in [...kVehicleSubcategories, ...kWeaponSubcategories]) {
    if (meta.subCategory.toLowerCase() == normalized ||
        meta.subType.toLowerCase() == normalized) {
      return meta;
    }
  }
  if (normalized == 'pistol' || normalized == 'handguns') {
    return kWeaponSubcategories[0];
  }
  return null;
}

WikiItemMetadata getWikiItemMetadata(WikiItem item) {
  if (item.subCategory != null && item.subCategory!.trim().isNotEmpty) {
    final explicit = getWikiSubcategoryMetadata(item.subCategory!);
    if (explicit != null) {
      return explicit;
    }
  }

  final id = item.id.toLowerCase();
  final cat = item.category.toLowerCase();

  // Vehicles
  if (cat.contains('vehicle') || id.startsWith('v_')) {
    // Supercars / Hypercars
    if (id == 'v_adder' ||
        id == 'v_t20' ||
        id == 'v_zentorno' ||
        id == 'v_entity_xf' ||
        id == 'v_turismo_r' ||
        id == 'v_cheetah' ||
        id == 'v_infernus' ||
        id == 'v_osiris') {
      return kVehicleSubcategories[0];
    }
    // Sports & Tuners
    if (id == 'v_elegy_rh8' ||
        id == 'v_banshee' ||
        id == 'v_comet' ||
        id == 'v_jester' ||
        id == 'v_sultan') {
      return kVehicleSubcategories[1];
    }
    // Muscle Cars
    if (id == 'v_dominator' || id == 'v_gauntlet' || id == 'v_sabre_turbo') {
      return kVehicleSubcategories[2];
    }
    // Motorcycles
    if (id == 'v_bati_801' || id == 'v_akuma' || id == 'v_sanchez') {
      return kVehicleSubcategories[3];
    }
    // Aircraft & Attack Choppers
    if (id == 'v_buzzard' || id == 'v_lazer' || id == 'v_hydra') {
      return kVehicleSubcategories[4];
    }
    // Off-Road & SUVs
    if (id == 'v_sandking_xl' || id == 'v_dubsta' || id == 'v_karin_rebel') {
      return kVehicleSubcategories[5];
    }

    return const WikiItemMetadata(
      icon: Icons.directions_car,
      subType: 'Vehicle',
      subCategory: 'Other Vehicles',
      accentColor: Color(0xFFFFB300),
    );
  }

  // Weapons
  if (cat.contains('weapon') || id.startsWith('w_')) {
    // Handguns / Pistols
    if (id == 'w_pistol' ||
        id == 'w_combat_pistol' ||
        id == 'w_ap_pistol' ||
        id == 'w_heavy_revolver') {
      return kWeaponSubcategories[0];
    }
    // Submachine Guns
    if (id == 'w_micro_smg' || id == 'w_smg' || id == 'w_combat_pdw') {
      return kWeaponSubcategories[1];
    }
    // Shotguns
    if (id == 'w_pump_shotgun' ||
        id == 'w_sawed_off_shotgun' ||
        id == 'w_assault_shotgun') {
      return kWeaponSubcategories[2];
    }
    // Rifles
    if (id == 'w_carbine_rifle' ||
        id == 'w_assault_rifle' ||
        id == 'w_special_carbine' ||
        id == 'w_advanced_rifle') {
      return kWeaponSubcategories[3];
    }
    // Snipers
    if (id == 'w_sniper_rifle' ||
        id == 'w_heavy_sniper' ||
        id == 'w_marksman_rifle') {
      return kWeaponSubcategories[4];
    }
    // Heavy / Explosive
    if (id == 'w_rpg' || id == 'w_minigun' || id == 'w_sticky_bomb') {
      return kWeaponSubcategories[5];
    }
    // Melee
    if (id == 'w_combat_knife') {
      return kWeaponSubcategories[6];
    }

    return const WikiItemMetadata(
      icon: Icons.gps_fixed,
      subType: 'Weapon',
      subCategory: 'Other Weapons',
      accentColor: Color(0xFFFF5252),
    );
  }

  return const WikiItemMetadata(
    icon: Icons.category,
    subType: 'General',
    subCategory: 'General',
    accentColor: Colors.grey,
  );
}
