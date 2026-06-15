import 'package:flutter/material.dart';

class TourCity {
  const TourCity({
    required this.name,
    required this.region,
    required this.description,
    required this.tags,
    this.area = CityArea.center,
    required this.icon,
  });

  final String name;
  final String region;
  final String description;
  final Set<CityTag> tags;
  final CityArea area;
  final IconData icon;
}

enum CityArea { north, south, east, west, center, southeast }

enum CityTag {
  history,
  culture,
  mountain,
  nature,
  urban,
  seaside,
  nightlife,
  family,
  photography,
  medieval,
  food,
  spiritual,
  quiet,
  romantic,
  active,
  relaxing,
  museums,
  architecture,
  traditions,
  water,
  festivals,
  shopping,
}
