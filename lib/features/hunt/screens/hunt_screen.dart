import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/treasure_hunt.dart';
import '../services/photo_validation_service.dart';
import '../services/hunt_progress_service.dart';

class HuntScreen extends StatefulWidget {
  const HuntScreen({super.key, required this.hunt});

  final TreasureHunt hunt;

  @override
  State<HuntScreen> createState() => _HuntScreenState();
}

class _HuntScreenState extends State<HuntScreen> {
  final HuntProgressService _progressService = HuntProgressService();
  int _currentIndex = -1;
  int _revealedHints = 0;
  int _finalScore = 0;
  final Map<int, int> _localScores = {};
  bool _isLoadingProgress = true;

  bool get _isIntro => _currentIndex == -1;
  bool get _isFinished => _currentIndex >= widget.hunt.objectives.length;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    try {
      final progress = await _progressService
          .getProgress(widget.hunt.id)
          .timeout(const Duration(seconds: 6));

      if (!mounted) return;

      setState(() {
        if (progress != null) {
          _currentIndex = progress.isCompleted
              ? widget.hunt.objectives.length
              : progress.currentIndex;
          _finalScore = progress.finalScore;
        }

        _isLoadingProgress = false;
        _revealedHints = 0;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoadingProgress = false;
        _revealedHints = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nu am putut încărca progresul salvat. Poți porni traseul de la început.',
          ),
        ),
      );
    }
  }

  Future<void> _startHunt() async {
    try {
      await _progressService
          .startHunt(widget.hunt)
          .timeout(const Duration(seconds: 6));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Progresul nu a putut fi salvat acum, dar poți continua traseul.',
            ),
          ),
        );
      }
    }

    if (!mounted) return;

    setState(() {
      _currentIndex = 0;
      _revealedHints = 0;
      _finalScore = 0;
    });
  }

  Future<void> _revealHint() async {
    final objective = widget.hunt.objectives[_currentIndex];

    if (_revealedHints >= objective.hints.length) return;

    final shouldReveal = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vrei un indiciu?'),
        content: const Text(
          'Indiciile te ajută, dar ultimul îți spune exact locația.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Nu'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Da, arată indiciul'),
          ),
        ],
      ),
    );

    if (shouldReveal != true) return;

    setState(() {
      _revealedHints++;
    });
  }

  Future<void> _validateAndContinue(int score) async {
    final isLastObjective = _currentIndex == widget.hunt.objectives.length - 1;

    HuntProgress? progress;

    try {
      await _progressService
          .saveObjectiveScore(
            hunt: widget.hunt,
            objectiveIndex: _currentIndex,
            score: score,
          )
          .timeout(const Duration(seconds: 6));

      progress = await _progressService
          .getProgress(widget.hunt.id)
          .timeout(const Duration(seconds: 6));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Scorul nu a putut fi salvat în Firestore acum. Continui local.',
            ),
          ),
        );
      }
    }

    if (!mounted) return;

    _localScores[_currentIndex] = score;
    final localFinalScore = _localScores.isEmpty
        ? 0
        : (_localScores.values.reduce((a, b) => a + b) / _localScores.length)
              .round();

    setState(() {
      _currentIndex = isLastObjective
          ? widget.hunt.objectives.length
          : _currentIndex + 1;
      _revealedHints = 0;
      _finalScore =
          progress?.finalScore ??
          (isLastObjective ? localFinalScore : _finalScore);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.hunt.cityName), centerTitle: true),
      body: SafeArea(
        child: _isLoadingProgress
            ? const Center(child: CircularProgressIndicator())
            : _isIntro
            ? _HuntIntroView(hunt: widget.hunt, onStart: _startHunt)
            : _isFinished
            ? _HuntFinishedView(
                hunt: widget.hunt,
                finalScore: _finalScore,
                onRestart: _restartHunt,
              )
            : _HuntStepView(
                hunt: widget.hunt,
                objective: widget.hunt.objectives[_currentIndex],
                currentIndex: _currentIndex,
                revealedHints: _revealedHints,
                onRevealHint: _revealHint,
                onContinue: _validateAndContinue,
              ),
      ),
    );
  }

  Future<void> _restartHunt() async {
    try {
      await _progressService
          .restartHunt(widget.hunt)
          .timeout(const Duration(seconds: 6));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Nu am putut reseta progresul în Firestore. Reiau traseul local.',
            ),
          ),
        );
      }
    }

    if (!mounted) return;

    setState(() {
      _currentIndex = 0;
      _revealedHints = 0;
      _finalScore = 0;
      _localScores.clear();
    });
  }
}

class _HuntIntroView extends StatelessWidget {
  const _HuntIntroView({required this.hunt, required this.onStart});

  final TreasureHunt hunt;
  final Future<void> Function() onStart;

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
              Icon(
                Icons.explore,
                color: colorScheme.onPrimaryContainer,
                size: 34,
              ),
              const SizedBox(height: 14),
              Text(
                hunt.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                hunt.story,
                style: TextStyle(color: colorScheme.onPrimaryContainer),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _InfoRow(
          icon: Icons.place_outlined,
          title: 'Locația de start',
          value: hunt.startPoint,
        ),
        const SizedBox(height: 10),
        _InfoRow(
          icon: Icons.flag_outlined,
          title: 'Număr de locații',
          value: '${hunt.objectives.length} locații',
        ),
        const SizedBox(height: 10),
        _InfoRow(
          icon: Icons.schedule,
          title: 'Timp mediu',
          value: hunt.estimatedTime,
        ),
        const SizedBox(height: 10),
        _InfoRow(
          icon: Icons.card_giftcard,
          title: 'Premiu final',
          value: hunt.rewardName,
        ),
        const SizedBox(height: 28),
        FilledButton.icon(
          onPressed: () => onStart(),
          icon: const Icon(Icons.play_arrow),
          label: const Text('Începe aventura'),
        ),
      ],
    );
  }
}

class _HuntStepView extends StatefulWidget {
  const _HuntStepView({
    required this.hunt,
    required this.objective,
    required this.currentIndex,
    required this.revealedHints,
    required this.onRevealHint,
    required this.onContinue,
  });

  final TreasureHunt hunt;
  final HuntObjective objective;
  final int currentIndex;
  final int revealedHints;
  final VoidCallback onRevealHint;
  final Future<void> Function(int score) onContinue;

  @override
  State<_HuntStepView> createState() => _HuntStepViewState();
}

class _HuntStepViewState extends State<_HuntStepView> {
  final ImagePicker _imagePicker = ImagePicker();
  final PhotoValidationService _photoValidationService =
      const PhotoValidationService();
  XFile? _selectedImage;
  PhotoValidationResult? _lastValidationResult;
  bool _isValidating = false;

  @override
  void didUpdateWidget(covariant _HuntStepView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.currentIndex != widget.currentIndex) {
      _selectedImage = null;
      _lastValidationResult = null;
      _isValidating = false;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );

      if (image == null || !mounted) return;

      setState(() {
        _selectedImage = image;
        _lastValidationResult = null;
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nu am putut deschide camera sau galeria.'),
        ),
      );
    }
  }

  Future<void> _validatePhoto() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fă o poză sau încarcă una înainte de validare.'),
        ),
      );
      return;
    }

    setState(() {
      _isValidating = true;
    });

    try {
      final result = await _photoValidationService.validate(
        userImage: File(_selectedImage!.path),
        officialImageUrl: widget.objective.officialImageUrl,
        officialImageAsset: widget.objective.officialImageAsset,
      );

      if (!mounted) return;

      setState(() {
        _isValidating = false;
        _lastValidationResult = result;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isValidating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nu am putut compara poza. Încearcă altă imagine.'),
        ),
      );
    }
  }

  Future<void> _continueAfterAcceptedPhoto() async {
    final result = _lastValidationResult;

    if (result == null || !result.isAccepted) return;

    await widget.onContinue(result.similarityPercent);
  }

  Future<void> _openDirections() async {
    final latitude = widget.objective.latitude;
    final longitude = widget.objective.longitude;
    final destination = latitude != null && longitude != null
        ? '$latitude,$longitude'
        : '${widget.objective.name}, ${widget.hunt.cityName}, Romania';
    final mapsUri = Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination': destination,
      'travelmode': 'walking',
    });

    final didOpen = await launchUrl(
      mapsUri,
      mode: LaunchMode.externalApplication,
    );

    if (didOpen || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nu am putut deschide harta.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.hunt.objectives.length;
    final remaining = total - widget.currentIndex - 1;
    final progress = widget.currentIndex / total;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Locația ${widget.currentIndex + 1} din $total',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: progress),
        const SizedBox(height: 8),
        Text(
          remaining == 0
              ? 'Aceasta este ultima locație.'
              : 'Mai ai încă $remaining locații după aceasta.',
        ),
        const SizedBox(height: 22),
        Text(
          widget.currentIndex == 0
              ? widget.hunt.startPoint
              : 'Următoarea locație',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(widget.objective.story),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: _openDirections,
          icon: const Icon(Icons.directions_outlined),
          label: const Text('Du-mă direct la locație'),
        ),
        const SizedBox(height: 22),
        _HintSection(
          objective: widget.objective,
          revealedHints: widget.revealedHints,
          onRevealHint: widget.onRevealHint,
        ),
        const SizedBox(height: 22),
        _PhotoValidationCard(
          selectedImage: _selectedImage,
          instruction: widget.objective.photoInstruction,
          validationResult: _lastValidationResult,
          isValidating: _isValidating,
          onTakePhoto: () => _pickImage(ImageSource.camera),
          onUploadPhoto: () => _pickImage(ImageSource.gallery),
          onValidate: _validatePhoto,
          onContinue: _continueAfterAcceptedPhoto,
        ),
        const SizedBox(height: 18),
        _InfoRow(
          icon: Icons.workspace_premium_outlined,
          title: 'Recompensa după validare',
          value: widget.objective.reward,
        ),
      ],
    );
  }
}

class _HintSection extends StatelessWidget {
  const _HintSection({
    required this.objective,
    required this.revealedHints,
    required this.onRevealHint,
  });

  final HuntObjective objective;
  final int revealedHints;
  final VoidCallback onRevealHint;

  @override
  Widget build(BuildContext context) {
    final canRevealMore = revealedHints < objective.hints.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Indicii',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text('$revealedHints/${objective.hints.length}'),
            ],
          ),
          const SizedBox(height: 12),
          if (revealedHints == 0)
            const Text('Nu ai deschis niciun indiciu încă.'),
          ...objective.hints
              .take(revealedHints)
              .map(
                (hint) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('- '),
                      Expanded(child: Text(hint)),
                    ],
                  ),
                ),
              ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: canRevealMore ? onRevealHint : null,
            icon: const Icon(Icons.visibility_outlined),
            label: Text(
              canRevealMore ? 'Arată un indiciu' : 'Toate indiciile deschise',
            ),
          ),
        ],
      ),
    );
  }
}

class _HuntFinishedView extends StatelessWidget {
  const _HuntFinishedView({
    required this.hunt,
    required this.finalScore,
    required this.onRestart,
  });

  final TreasureHunt hunt;
  final int finalScore;
  final Future<void> Function() onRestart;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.emoji_events,
                color: colorScheme.onTertiaryContainer,
                size: 38,
              ),
              const SizedBox(height: 14),
              Text(
                'Treasure hunt complet!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onTertiaryContainer,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ai terminat traseul ${hunt.title}. Scor final: $finalScore%. ${finalScore >= PhotoValidationService.minimumAcceptedScore ? 'Ai câștigat medalia ${hunt.cityName}.' : 'Ai nevoie de minimum ${PhotoValidationService.minimumAcceptedScore}% pentru medalie.'}',
                style: TextStyle(color: colorScheme.onTertiaryContainer),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        FilledButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.check),
          label: const Text('Înapoi la oraș'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onRestart,
          icon: const Icon(Icons.replay),
          label: const Text('Începe din nou treasure hunt-ul'),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.labelMedium),
                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoValidationCard extends StatelessWidget {
  const _PhotoValidationCard({
    required this.selectedImage,
    required this.instruction,
    required this.validationResult,
    required this.isValidating,
    required this.onTakePhoto,
    required this.onUploadPhoto,
    required this.onValidate,
    required this.onContinue,
  });

  final XFile? selectedImage;
  final String instruction;
  final PhotoValidationResult? validationResult;
  final bool isValidating;
  final VoidCallback onTakePhoto;
  final VoidCallback onUploadPhoto;
  final VoidCallback onValidate;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Validare locație',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Fă o poză la locul în care ai ajuns sau încarcă o imagine din galerie.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          _PhotoInstructionBox(instruction: instruction),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: selectedImage == null
                  ? Container(
                      color: colorScheme.surfaceContainerHighest,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add_a_photo_outlined,
                            color: colorScheme.primary,
                            size: 38,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Poza ta va apărea aici.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : Image.file(File(selectedImage!.path), fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isValidating ? null : onTakePhoto,
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Fă poză'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isValidating ? null : onUploadPhoto,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Galerie'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (validationResult != null) ...[
            _ValidationResultBox(result: validationResult!),
            const SizedBox(height: 12),
          ],
          if (validationResult?.isAccepted == true)
            FilledButton.icon(
              onPressed: isValidating ? null : onContinue,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Mergi mai departe'),
            )
          else
            FilledButton.icon(
              onPressed: isValidating ? null : onValidate,
              icon: isValidating
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.verified_outlined),
              label: Text(
                isValidating ? 'Se verifică poza...' : 'Validează poza',
              ),
            ),
        ],
      ),
    );
  }
}

class _PhotoInstructionBox extends StatelessWidget {
  const _PhotoInstructionBox({required this.instruction});

  final String instruction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.photo_camera_outlined,
            color: colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              instruction,
              style: TextStyle(color: colorScheme.onSecondaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _ValidationResultBox extends StatelessWidget {
  const _ValidationResultBox({required this.result});

  final PhotoValidationResult result;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isAccepted = result.isAccepted;
    final backgroundColor = isAccepted
        ? colorScheme.tertiaryContainer
        : colorScheme.errorContainer;
    final foregroundColor = isAccepted
        ? colorScheme.onTertiaryContainer
        : colorScheme.onErrorContainer;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isAccepted ? Icons.check_circle_outline : Icons.error_outline,
            color: foregroundColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isAccepted
                  ? 'Poza acceptată. Scor similaritate: ${result.similarityPercent}%. Apasă "Mergi mai departe" când ești pregătită.'
                  : 'Locația nu a fost acceptată. Imaginea încărcată nu corespunde obiectivului curent. Verifică dacă ai ajuns la locul corect și încearcă din nou.',
              style: TextStyle(
                color: foregroundColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
