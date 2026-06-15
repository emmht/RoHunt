import 'tour_city.dart';

class QuizQuestion {
  const QuizQuestion({required this.question, required this.options});

  final String question;
  final List<QuizOption> options;
}

class QuizOption {
  const QuizOption({
    required this.label,
    this.tags = const {},
    this.requiredTags = const {},
    this.preferredAreas = const {},
    this.blockedTags = const {},
    this.weight = 1,
  });

  final String label;
  final Set<CityTag> tags;
  final Set<CityTag> requiredTags;
  final Set<CityArea> preferredAreas;
  final Set<CityTag> blockedTags;
  final int weight;
}
