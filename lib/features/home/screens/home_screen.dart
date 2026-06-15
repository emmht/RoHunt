import 'package:flutter/material.dart';

import '../../../core/routing/routes.dart';
import '../../auth/services/auth_service.dart';
import '../../avatar/widgets/profile_image_avatar.dart';
import '../../cities/services/favorite_cities_service.dart';
import '../../cities/widgets/city_card.dart';
import '../../hunt/services/hunt_progress_service.dart';
import '../../quiz/data/romania_cities.dart';
import '../../quiz/models/tour_city.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final progressService = HuntProgressService();
    final userName = authService.currentUser?.displayName?.trim();
    final firstName = userName == null || userName.isEmpty
        ? 'explorator'
        : userName.split(' ').first;

    return Scaffold(
      appBar: AppBar(
        title: const Text('RoHunt'),
        actions: [
          IconButton(
            tooltip: 'Favorite',
            onPressed: () =>
                Navigator.pushNamed(context, Routes.favoriteCities),
            icon: const Icon(Icons.favorite_border),
          ),
          IconButton(
            tooltip: 'Profil',
            onPressed: () => Navigator.pushNamed(context, Routes.profile),
            icon: const Icon(Icons.person_outline),
          ),
          IconButton(
            tooltip: 'Delogare',
            onPressed: () async {
              await authService.logout();

              if (!context.mounted) return;

              Navigator.pushReplacementNamed(context, Routes.welcome);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                const ProfileImageAvatar(radius: 30),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bună, $firstName',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Alege o aventură și descoperă România.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            _StartQuestCard(
              onPressed: () => Navigator.pushNamed(context, Routes.quiz),
            ),
            const SizedBox(height: 20),
            Text(
              'Progresul tău',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            StreamBuilder<HuntProgressStats>(
              stream: progressService.watchStats(),
              builder: (context, snapshot) {
                final stats =
                    snapshot.data ??
                    const HuntProgressStats(completedHunts: 0, earnedMedals: 0);

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final tileWidth = (constraints.maxWidth - 12) / 2;

                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: tileWidth,
                          child: _ProgressTile(
                            icon: Icons.route,
                            value: '${stats.completedHunts}',
                            label: 'trasee',
                          ),
                        ),
                        SizedBox(
                          width: tileWidth,
                          child: _ProgressTile(
                            icon: Icons.emoji_events_outlined,
                            value: '${stats.earnedMedals}',
                            label: 'medalii',
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Orașe disponibile',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, Routes.favoriteCities),
                  icon: const Icon(Icons.favorite_border),
                  label: const Text('Favorite'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...romaniaCities.map(
              (city) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ValueListenableBuilder<Set<String>>(
                  valueListenable: FavoriteCitiesService.favoriteCityNames,
                  builder: (context, favorites, _) {
                    final isFavorite = favorites.contains(city.name);

                    return CityCard(
                      city: city,
                      onTap: () => _openCity(context, city),
                      trailing: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                        ),
                        onPressed: () =>
                            FavoriteCitiesService.toggle(city.name),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCity(BuildContext context, TourCity city) {
    Navigator.pushNamed(context, Routes.cityDetails, arguments: city);
  }
}

class _StartQuestCard extends StatelessWidget {
  const _StartQuestCard({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.explore, color: colorScheme.onPrimaryContainer, size: 34),
          const SizedBox(height: 14),
          Text(
            'Găsește orașul potrivit pentru tine',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Răspunde la câteva întrebări, apoi RoHunt îți propune un oraș pe care îl poți salva pentru o excursie viitoare.',
            style: TextStyle(color: colorScheme.onPrimaryContainer),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start quiz'),
          ),
        ],
      ),
    );
  }
}

class _ProgressTile extends StatelessWidget {
  const _ProgressTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 132),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
