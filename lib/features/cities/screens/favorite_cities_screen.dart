import 'package:flutter/material.dart';

import '../../../core/routing/routes.dart';
import '../../quiz/data/romania_cities.dart';
import '../../quiz/models/tour_city.dart';
import '../services/favorite_cities_service.dart';
import '../widgets/city_card.dart';

class FavoriteCitiesScreen extends StatelessWidget {
  const FavoriteCitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orașe favorite'), centerTitle: true),
      body: SafeArea(
        child: ValueListenableBuilder<Set<String>>(
          valueListenable: FavoriteCitiesService.favoriteCityNames,
          builder: (context, favorites, _) {
            final favoriteCities = romaniaCities
                .where((city) => favorites.contains(city.name))
                .toList();

            if (favoriteCities.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Nu ai orașe favorite încă. Adaugă orașe din lista principală sau din rezultatul quiz-ului.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemBuilder: (context, index) {
                final city = favoriteCities[index];

                return CityCard(
                  city: city,
                  onTap: () => _openCity(context, city),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite),
                    onPressed: () => FavoriteCitiesService.toggle(city.name),
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemCount: favoriteCities.length,
            );
          },
        ),
      ),
    );
  }

  void _openCity(BuildContext context, TourCity city) {
    Navigator.pushNamed(context, Routes.cityDetails, arguments: city);
  }
}
