import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/routing/routes.dart';
import '../services/avatar_service.dart';

class AvatarSetupScreen extends StatefulWidget {
  const AvatarSetupScreen({super.key});

  @override
  State<AvatarSetupScreen> createState() => _AvatarSetupScreenState();
}

class _AvatarSetupScreenState extends State<AvatarSetupScreen> {
  static const List<String> _presetAvatars = [
    'assets/avatars/avatar_01.jpg.png',
    'assets/avatars/avatar_02.jpg.png',
    'assets/avatars/avatar_03.jpg.png',
    'assets/avatars/avatar_04.jpg.png',
  ];

  final AvatarService _avatarService = AvatarService();
  final ImagePicker _imagePicker = ImagePicker();

  String? _selectedAsset;
  File? _customImage;
  bool _isSaving = false;

  Future<void> _pickCustomImage() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 88,
      maxWidth: 1200,
    );

    if (image == null) return;

    setState(() {
      _customImage = File(image.path);
      _selectedAsset = null;
    });
  }

  Future<void> _saveProfileImage() async {
    if (_selectedAsset == null && _customImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alege un avatar sau încarcă o poză.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      if (_customImage != null) {
        await _avatarService.saveCustomProfileImage(_customImage!);
      } else {
        await _avatarService.savePresetAvatar(_selectedAsset!);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Poza de profil a fost salvată.')),
      );

      Navigator.pushReplacementNamed(context, Routes.profile);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nu am putut salva poza de profil.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Poza de profil'), centerTitle: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Alege cum vrei să apari în RoHunt',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Poți alege unul dintre avatarurile predefinite sau poți încărca o poză din galerie.',
            ),
            const SizedBox(height: 22),
            _SelectedPreview(
              selectedAsset: _selectedAsset,
              customImage: _customImage,
            ),
            const SizedBox(height: 22),
            OutlinedButton.icon(
              onPressed: _isSaving ? null : _pickCustomImage,
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Încarcă poza ta'),
            ),
            const SizedBox(height: 24),
            Text(
              'Avataruri predefinite',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _presetAvatars.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final asset = _presetAvatars[index];
                final isSelected = _selectedAsset == asset;

                return _PresetAvatarTile(
                  asset: asset,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      _selectedAsset = asset;
                      _customImage = null;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _saveProfileImage,
                icon: const Icon(Icons.check),
                label: Text(_isSaving ? 'Se salvează...' : 'Salvează'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedPreview extends StatelessWidget {
  const _SelectedPreview({
    required this.selectedAsset,
    required this.customImage,
  });

  final String? selectedAsset;
  final File? customImage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final imageProvider = customImage != null
        ? FileImage(customImage!) as ImageProvider
        : selectedAsset != null
        ? AssetImage(selectedAsset!)
        : null;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 58,
            backgroundColor: colorScheme.primaryContainer,
            child: imageProvider == null
                ? Icon(
                    Icons.person_outline,
                    size: 54,
                    color: colorScheme.onPrimaryContainer,
                  )
                : ClipOval(
                    child: SizedBox(
                      width: 116,
                      height: 116,
                      child: Image(
                        image: imageProvider,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          Text(
            imageProvider == null
                ? 'Nu ai ales încă o poză.'
                : 'Așa va arăta poza ta de profil.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PresetAvatarTile extends StatelessWidget {
  const _PresetAvatarTile({
    required this.asset,
    required this.isSelected,
    required this.onTap,
  });

  final String asset;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.outlineVariant,
                  width: isSelected ? 3 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  asset,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
            ),
          ),
          if (isSelected)
            Positioned(
              right: 6,
              top: 6,
              child: CircleAvatar(
                radius: 14,
                backgroundColor: colorScheme.primary,
                child: Icon(
                  Icons.check,
                  size: 18,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
