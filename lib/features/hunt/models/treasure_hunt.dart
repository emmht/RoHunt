class TreasureHunt {
  const TreasureHunt({
    required this.id,
    required this.cityId,
    required this.cityName,
    required this.title,
    required this.story,
    required this.startPoint,
    required this.estimatedTime,
    required this.rewardName,
    required this.objectives,
  });

  final String id;
  final String cityId;
  final String cityName;
  final String title;
  final String story;
  final String startPoint;
  final String estimatedTime;
  final String rewardName;
  final List<HuntObjective> objectives;
}

class HuntObjective {
  const HuntObjective({
    required this.name,
    required this.story,
    required this.hints,
    required this.reward,
    required this.photoInstruction,
    this.latitude,
    this.longitude,
    this.officialImageUrl,
    this.officialImageAsset,
  });

  final String name;
  final String story;
  final List<String> hints;
  final String reward;
  final String photoInstruction;
  final double? latitude;
  final double? longitude;
  final String? officialImageUrl;
  final String? officialImageAsset;
}
