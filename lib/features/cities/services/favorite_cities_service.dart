import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteCitiesService {
  FavoriteCitiesService._();

  static const _storageKey = 'favorite_city_names';

  static final ValueNotifier<Set<String>> favoriteCityNames = ValueNotifier(
    <String>{},
  );

  static Future<void> initialize() async {
    final preferences = await SharedPreferences.getInstance();
    final storedFavorites = preferences.getStringList(_storageKey) ?? [];

    favoriteCityNames.value = storedFavorites.toSet();
  }

  static bool isFavorite(String cityName) {
    return favoriteCityNames.value.contains(cityName);
  }

  static Future<void> toggle(String cityName) async {
    final nextFavorites = Set<String>.from(favoriteCityNames.value);

    if (nextFavorites.contains(cityName)) {
      nextFavorites.remove(cityName);
    } else {
      nextFavorites.add(cityName);
    }

    favoriteCityNames.value = nextFavorites;

    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(_storageKey, nextFavorites.toList());
  }
}
