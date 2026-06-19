import 'package:flutter/material.dart';

import '../../../core/routing/routes.dart';
import '../../cities/services/favorite_cities_service.dart';
import '../data/quiz_questions.dart';
import '../data/romania_cities.dart';
import '../models/quiz_question.dart';
import '../models/tour_city.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final Map<CityTag, int> _scores = {};
  final Set<CityTag> _requiredTags = {};
  final Set<CityTag> _blockedTags = {};
  final Set<CityArea> _preferredAreas = {};

  int _currentIndex = 0;
  int _distanceBias = 0;
  TourCity? _result;

  void _answer(List<QuizOption> options) {
    if (options.isEmpty) {
      _goNext();
      return;
    }

    for (final option in options) {
      _applyOption(option);
    }

    _goNext();
  }

  void _applyOption(QuizOption option) {
    for (final tag in option.tags) {
      _scores[tag] = (_scores[tag] ?? 0) + option.weight;
    }

    for (final tag in option.requiredTags) {
      final hasSeasideFilter = _requiredTags.contains(CityTag.seaside);
      final hasMountainFilter = _requiredTags.contains(CityTag.mountain);

      if (tag == CityTag.mountain && hasSeasideFilter) continue;
      if (tag == CityTag.seaside && hasMountainFilter) continue;

      _requiredTags.add(tag);
    }
    _blockedTags.addAll(option.blockedTags);
    _preferredAreas.addAll(option.preferredAreas);

    if (_currentIndex == 1) {
      _distanceBias = option.weight > _distanceBias
          ? option.weight
          : _distanceBias;
    }
  }

  void _goNext() {
    if (_currentIndex == quizQuestions.length - 1) {
      setState(() {
        _result = _recommendCity();
      });
      return;
    }

    setState(() {
      _currentIndex++;
    });
  }

  TourCity _recommendCity() {
    TourCity bestCity = romaniaCities.first;
    var bestScore = -999999;

    for (final city in romaniaCities) {
      final score = _scoreCity(city);

      if (score > bestScore) {
        bestScore = score;
        bestCity = city;
      }
    }

    return bestCity;
  }

  int _scoreCity(TourCity city) {
    if (_requiredTags.isNotEmpty && !city.tags.containsAll(_requiredTags)) {
      return -99999;
    }

    var score = city.tags.fold<int>(
      0,
      (total, tag) => total + (_scores[tag] ?? 0),
    );

    for (final blockedTag in _blockedTags) {
      if (city.tags.contains(blockedTag)) {
        score -= 8;
      }
    }

    if (_preferredAreas.contains(city.area)) {
      score += _distanceBias;
    }

    score += city.tags.length;

    return score;
  }

  void _restart() {
    setState(() {
      _scores.clear();
      _requiredTags.clear();
      _blockedTags.clear();
      _preferredAreas.clear();
      _currentIndex = 0;
      _distanceBias = 0;
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz'), centerTitle: true),
      body: SafeArea(
        child: result == null
            ? _QuestionView(
                question: quizQuestions[_currentIndex],
                key: ValueKey(_currentIndex),
                currentIndex: _currentIndex,
                total: quizQuestions.length,
                onAnswer: _answer,
              )
            : _ResultView(city: result, onRestart: _restart),
      ),
    );
  }
}

class _QuestionView extends StatefulWidget {
  const _QuestionView({
    super.key,
    required this.question,
    required this.currentIndex,
    required this.total,
    required this.onAnswer,
  });

  final QuizQuestion question;
  final int currentIndex;
  final int total;
  final ValueChanged<List<QuizOption>> onAnswer;

  @override
  State<_QuestionView> createState() => _QuestionViewState();
}

class _QuestionViewState extends State<_QuestionView> {
  final Set<int> _selectedIndexes = {};
  bool _noneSelected = false;

  bool get _isSingleChoice => widget.currentIndex < 2;

  void _toggleOption(int index, bool isSelected) {
    setState(() {
      _noneSelected = false;

      if (_isSingleChoice) {
        _selectedIndexes
          ..clear()
          ..add(index);
        return;
      }

      if (isSelected) {
        _selectedIndexes.add(index);
      } else {
        _selectedIndexes.remove(index);
      }
    });
  }

  void _toggleNone(bool isSelected) {
    setState(() {
      _noneSelected = isSelected;

      if (isSelected) {
        _selectedIndexes.clear();
      }
    });
  }

  void _continue() {
    if (_isSingleChoice && _selectedIndexes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alege o variantă ca să continuăm.')),
      );
      return;
    }

    final selectedOptions = _selectedIndexes
        .map((index) => widget.question.options[index])
        .toList(growable: false);

    widget.onAnswer(selectedOptions);
  }

  @override
  Widget build(BuildContext context) {
    final progress = (widget.currentIndex + 1) / widget.total;
    final palette = _questionPalette(widget.currentIndex);
    final showNoneOption =
        !_isSingleChoice &&
        !widget.question.options.any(
          (option) => option.label.toLowerCase().contains('nimic'),
        );

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: palette.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Întrebarea ${widget.currentIndex + 1} din ${widget.total}',
                      style: TextStyle(color: palette.foreground),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withValues(alpha: 0.35),
                        color: palette.accent,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      widget.question.question,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: palette.foreground,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isSingleChoice
                          ? 'Alege o singură variantă.'
                          : 'Poți alege mai multe variante.',
                      style: TextStyle(color: palette.foreground),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ...widget.question.options.asMap().entries.map((entry) {
                final index = entry.key;
                final option = entry.value;
                final isSelected = _selectedIndexes.contains(index);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _QuizOptionTile(
                    label: option.label,
                    value: isSelected,
                    accent: palette.accent,
                    singleChoice: _isSingleChoice,
                    onChanged: (value) => _toggleOption(index, value),
                  ),
                );
              }),
              if (showNoneOption)
                _QuizOptionTile(
                  label: 'Niciuna de mai sus',
                  value: _noneSelected,
                  accent: palette.accent,
                  singleChoice: false,
                  onChanged: _toggleNone,
                ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: SizedBox(
              height: 52,
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _continue,
                icon: const Icon(Icons.arrow_forward),
                label: Text(
                  widget.currentIndex == widget.total - 1
                      ? 'Vezi recomandarea'
                      : 'Mai departe',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuizOptionTile extends StatelessWidget {
  const _QuizOptionTile({
    required this.label,
    required this.value,
    required this.accent,
    required this.singleChoice,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final Color accent;
  final bool singleChoice;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: value ? accent.withValues(alpha: 0.13) : null,
          border: Border.all(
            color: value
                ? accent
                : Theme.of(context).colorScheme.outlineVariant,
            width: value ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              height: 28,
              width: 28,
              decoration: BoxDecoration(
                color: value ? const Color(0xFFFFC857) : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: value
                      ? const Color(0xFFFFC857)
                      : Theme.of(context).colorScheme.outline,
                  width: 2,
                ),
              ),
              child: value
                  ? Icon(Icons.star, size: 18, color: const Color(0xFF3A2A00))
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label)),
          ],
        ),
      ),
    );
  }
}

_QuizPalette _questionPalette(int index) {
  const palettes = [
    _QuizPalette(
      background: Color(0xFFE4D7FF),
      foreground: Color(0xFF3D2772),
      accent: Color(0xFF7252C7),
    ),
    _QuizPalette(
      background: Color(0xFFDDF4ED),
      foreground: Color(0xFF174C3C),
      accent: Color(0xFF2E9A74),
    ),
    _QuizPalette(
      background: Color(0xFFFFE8D6),
      foreground: Color(0xFF653615),
      accent: Color(0xFFE98B3A),
    ),
    _QuizPalette(
      background: Color(0xFFDCEEFF),
      foreground: Color(0xFF163B61),
      accent: Color(0xFF3D86D6),
    ),
    _QuizPalette(
      background: Color(0xFFFFDDEA),
      foreground: Color(0xFF67243D),
      accent: Color(0xFFD94C7B),
    ),
  ];

  return palettes[index % palettes.length];
}

class _QuizPalette {
  const _QuizPalette({
    required this.background,
    required this.foreground,
    required this.accent,
  });

  final Color background;
  final Color foreground;
  final Color accent;
}

class _ResultView extends StatelessWidget {
  const _ResultView({required this.city, required this.onRestart});

  final TourCity city;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(radius: 28, child: Icon(city.icon, size: 30)),
              const SizedBox(height: 18),
              Text(
                city.name,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                city.region,
                style: TextStyle(color: colorScheme.onPrimaryContainer),
              ),
              const SizedBox(height: 12),
              Text(
                city.description,
                style: TextStyle(color: colorScheme.onPrimaryContainer),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'RoHunt îți recomandă acest oraș pentru o excursie viitoare. Îl poți salva la favorite și îl poți deschide mai târziu din Home.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        ValueListenableBuilder<Set<String>>(
          valueListenable: FavoriteCitiesService.favoriteCityNames,
          builder: (context, favorites, _) {
            final isFavorite = favorites.contains(city.name);

            return FilledButton.icon(
              onPressed: () => FavoriteCitiesService.toggle(city.name),
              icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
              label: Text(
                isFavorite ? 'Salvat la favorite' : 'Adaugă la favorite',
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () =>
              Navigator.pushNamed(context, Routes.cityDetails, arguments: city),
          icon: const Icon(Icons.location_city),
          label: const Text('Vezi orașul'),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: onRestart,
          icon: const Icon(Icons.refresh),
          label: const Text('Refă quiz-ul'),
        ),
      ],
    );
  }
}
