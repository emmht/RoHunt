import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/routing/routes.dart';
import '../../../core/theme/theme_mode_service.dart';
import '../../auth/services/auth_service.dart';
import '../../avatar/widgets/profile_image_avatar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();

  bool _isDeleting = false;
  String? _displayName;

  @override
  void initState() {
    super.initState();
    _displayName = _authService.currentUser?.displayName?.trim();
  }

  Future<void> _editName() async {
    final controller = TextEditingController(text: _displayName ?? '');

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Schimbă numele'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Nume',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anulează'),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();

              if (value.length < 2) return;

              Navigator.pop(context, value);
            },
            child: const Text('Salvează'),
          ),
        ],
      ),
    );

    if (newName == null) return;

    await _authService.updateName(newName);

    if (!mounted) return;

    setState(() {
      _displayName = newName;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Numele a fost actualizat.')));
  }

  Future<void> _deleteAccount() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ștergi contul?'),
        content: const Text(
          'Această acțiune șterge definitiv contul tău RoHunt și datele asociate profilului.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Anulează'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Șterge'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      await _authService.deleteAccount();

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.welcome,
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      final message = switch (e.code) {
        'requires-recent-login' =>
          'Pentru siguranță, deloghează-te și autentifică-te din nou înainte să ștergi contul.',
        _ => 'Nu am putut șterge contul: ${e.code}',
      };

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final email = user?.email ?? 'Email indisponibil';

    return Scaffold(
      appBar: AppBar(title: const Text('Profil'), centerTitle: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 14),
                const ProfileImageAvatar(radius: 46, fit: BoxFit.contain),
                const SizedBox(height: 28),
                _ProfileInfoTile(
                  label: 'Nume',
                  value: _displayName == null || _displayName!.isEmpty
                      ? 'Fără nume'
                      : _displayName!,
                ),
                const SizedBox(height: 14),
                _ProfileInfoTile(label: 'Email', value: email),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, Routes.medals),
                  icon: const Icon(Icons.emoji_events_outlined),
                  label: const Text('Medaliile mele'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, Routes.avatarSetup),
                  icon: const Icon(Icons.face),
                  label: const Text('Schimbă poza de profil'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _editName,
                  icon: const Icon(Icons.edit),
                  label: const Text('Schimbă numele'),
                ),
                const SizedBox(height: 12),
                ValueListenableBuilder<ThemeMode>(
                  valueListenable: ThemeModeService.notifier,
                  builder: (context, themeMode, _) {
                    return _ThemeModeTile(
                      isDarkMode: themeMode == ThemeMode.dark,
                      onChanged: ThemeModeService.setDarkMode,
                    );
                  },
                ),
                const SizedBox(height: 34),
                FilledButton.icon(
                  onPressed: _isDeleting ? null : _deleteAccount,
                  icon: const Icon(Icons.delete_outline),
                  label: _isDeleting
                      ? const Text('Se șterge...')
                      : const Text('Șterge contul'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeModeTile extends StatelessWidget {
  const _ThemeModeTile({required this.isDarkMode, required this.onChanged});

  final bool isDarkMode;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Tema întunecată',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Switch(value: isDarkMode, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _ProfileInfoTile extends StatelessWidget {
  const _ProfileInfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
