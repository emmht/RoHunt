import 'package:flutter/material.dart';

import '../../hunt/services/hunt_progress_service.dart';

class MedalsScreen extends StatelessWidget {
  const MedalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progressService = HuntProgressService();

    return Scaffold(
      appBar: AppBar(title: const Text('Medaliile mele'), centerTitle: true),
      body: SafeArea(
        child: StreamBuilder<List<EarnedMedal>>(
          stream: progressService.watchEarnedMedals(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final medals = snapshot.data ?? const [];

            if (medals.isEmpty) {
              return const _EmptyMedalsView();
            }

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: medals.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                return _MedalCard(medal: medals[index]);
              },
            );
          },
        ),
      ),
    );
  }
}

class _EmptyMedalsView extends StatelessWidget {
  const _EmptyMedalsView();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.emoji_events_outlined,
                size: 46,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Nu ai medalii încă',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Finalizează primul treasure hunt cu un scor de cel puțin 90% ca să câștigi prima medalie.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _MedalCard extends StatelessWidget {
  const _MedalCard({required this.medal});

  final EarnedMedal medal;

  @override
  Widget build(BuildContext context) {
    final style = _MedalStyle.forCity(medal.cityId);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          _MedalIcon(style: style),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Medalia ${medal.cityName}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(medal.huntTitle),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.verified_outlined, size: 18),
                    const SizedBox(width: 6),
                    Text('Scor final: ${medal.finalScore}%'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MedalIcon extends StatelessWidget {
  const _MedalIcon({required this.style});

  final _MedalStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: style.backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: style.borderColor, width: 3),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.workspace_premium, color: style.borderColor, size: 64),
          Icon(style.icon, color: style.iconColor, size: 30),
        ],
      ),
    );
  }
}

class _MedalStyle {
  const _MedalStyle({
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.icon,
  });

  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final IconData icon;

  factory _MedalStyle.forCity(String cityId) {
    return switch (cityId) {
      'iasi' => const _MedalStyle(
        backgroundColor: Color(0xFFE5DEF8),
        borderColor: Color(0xFF7658B5),
        iconColor: Color(0xFF4F348C),
        icon: Icons.account_balance,
      ),

      _ => const _MedalStyle(
        backgroundColor: Color(0xFFE8EEF7),
        borderColor: Color(0xFF6B7FA6),
        iconColor: Color(0xFF32496B),
        icon: Icons.location_city,
      ),
    };
  }
}
