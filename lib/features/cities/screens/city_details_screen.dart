import 'package:flutter/material.dart';

import '../../../core/routing/routes.dart';
import '../../hunt/services/hunt_repository.dart';
import '../../quiz/models/tour_city.dart';
import '../services/favorite_cities_service.dart';

class CityDetailsScreen extends StatefulWidget {
  const CityDetailsScreen({super.key, required this.city});

  final TourCity city;

  @override
  State<CityDetailsScreen> createState() => _CityDetailsScreenState();
}

class _CityDetailsScreenState extends State<CityDetailsScreen> {
  final HuntRepository _huntRepository = HuntRepository();

  bool _isLoadingHunt = false;

  String? get _cityHeroImageAsset {
    return switch (widget.city.name) {
      'Iași' => 'assets/official_images/iasi/fundal_iasi.jfif',
      _ => null,
    };
  }

  bool get _hasCompleteHunt => widget.city.name == 'Iași';

  Future<void> _startTreasureHunt() async {
    final cityId = _cityIdFromName(widget.city.name);

    if (!_hasCompleteHunt) {
      return;
    }

    setState(() {
      _isLoadingHunt = true;
    });

    final hunt = await _huntRepository.getHuntWithFallback(cityId);

    if (!mounted) return;

    setState(() {
      _isLoadingHunt = false;
    });

    Navigator.pushNamed(context, Routes.hunt, arguments: hunt);
  }

  @override
  Widget build(BuildContext context) {
    final city = widget.city;

    return Scaffold(
      appBar: AppBar(title: Text(city.name), centerTitle: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _CityHeroCard(city: city, imageAsset: _cityHeroImageAsset),
            const SizedBox(height: 20),
            _Section(
              title: 'Despre oraș',
              child: Text(
                '${city.description} Aici poți descoperi obiective turistice, locuri bune pentru fotografii și trasee care pot fi transformate în treasure hunt-uri.',
              ),
            ),
            _Section(
              title: 'Ce poți descoperi',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: city.tags
                    .map((tag) => Chip(label: Text(tag.label)))
                    .toList(),
              ),
            ),
            _Section(
              title: 'Recomandat pentru',
              child: Row(
                children: [
                  Icon(
                    Icons.group_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(_recommendedFor(city))),
                ],
              ),
            ),
            ValueListenableBuilder<Set<String>>(
              valueListenable: FavoriteCitiesService.favoriteCityNames,
              builder: (context, favorites, _) {
                final isFavorite = favorites.contains(city.name);

                return OutlinedButton.icon(
                  onPressed: () => FavoriteCitiesService.toggle(city.name),
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                  ),
                  label: Text(
                    isFavorite ? 'Șterge din favorite' : 'Adaugă la favorite',
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            if (_hasCompleteHunt)
              FilledButton.icon(
                onPressed: _isLoadingHunt ? null : _startTreasureHunt,
                icon: const Icon(Icons.map_outlined),
                label: _isLoadingHunt
                    ? const Text('Se încarcă traseul...')
                    : const Text('Începe treasure hunt-ul'),
              )
            else
              _ComingSoonNotice(cityName: city.name),
          ],
        ),
      ),
    );
  }

  String _recommendedFor(TourCity city) {
    final tags = city.tags;
    final recommendations = <String>[];

    if (tags.contains(CityTag.family)) recommendations.add('familie');
    if (tags.contains(CityTag.nightlife) || tags.contains(CityTag.festivals)) {
      recommendations.add('prieteni');
    }
    if (tags.contains(CityTag.romantic)) recommendations.add('cupluri');
    if (tags.contains(CityTag.mountain) || tags.contains(CityTag.active)) {
      recommendations.add('exploratori activi');
    }
    if (tags.contains(CityTag.culture) || tags.contains(CityTag.museums)) {
      recommendations.add('pasionați de cultură');
    }

    if (recommendations.isEmpty) {
      recommendations.addAll(['familie', 'prieteni', 'exploratori curioși']);
    }

    return recommendations.join(', ');
  }

  String _cityIdFromName(String cityName) {
    return switch (cityName) {
      'Iași' => 'iasi',
      _ => cityName.toLowerCase(),
    };
  }
}

class _ComingSoonNotice extends StatelessWidget {
  const _ComingSoonNotice({required this.cityName});

  final String cityName;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.construction_outlined, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Traseul pentru $cityName este în pregătire. Momentan, treasure hunt-ul complet disponibil este cel din Iași.',
              style: TextStyle(color: colorScheme.onSecondaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _CityHeroCard extends StatelessWidget {
  const _CityHeroCard({required this.city, required this.imageAsset});

  final TourCity city;
  final String? imageAsset;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasImage = imageAsset != null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 230,
        decoration: BoxDecoration(color: colorScheme.primaryContainer),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasImage)
              Image.asset(imageAsset!, fit: BoxFit.cover)
            else
              ColoredBox(color: colorScheme.primaryContainer),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: hasImage ? 0.05 : 0),
                    Colors.black.withValues(alpha: hasImage ? 0.62 : 0),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: hasImage
                        ? Colors.white.withValues(alpha: 0.92)
                        : null,
                    child: Icon(city.icon, size: 30),
                  ),
                  const Spacer(),
                  Text(
                    city.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: hasImage
                          ? Colors.white
                          : colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    city.region,
                    style: TextStyle(
                      color: hasImage
                          ? Colors.white.withValues(alpha: 0.9)
                          : colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension CityTagLabel on CityTag {
  String get label {
    return switch (this) {
      CityTag.history => 'istorie',
      CityTag.culture => 'cultură',
      CityTag.mountain => 'munte',
      CityTag.nature => 'natură',
      CityTag.urban => 'urban',
      CityTag.seaside => 'mare',
      CityTag.nightlife => 'viață de seară',
      CityTag.family => 'familie',
      CityTag.photography => 'fotografie',
      CityTag.medieval => 'medieval',
      CityTag.food => 'food',
      CityTag.spiritual => 'spiritual',
      CityTag.quiet => 'liniștit',
      CityTag.romantic => 'romantic',
      CityTag.active => 'activ',
      CityTag.relaxing => 'relaxare',
      CityTag.museums => 'muzee',
      CityTag.architecture => 'arhitectură',
      CityTag.traditions => 'tradiții',
      CityTag.water => 'apă',
      CityTag.festivals => 'festivaluri',
      CityTag.shopping => 'shopping',
    };
  }
}
