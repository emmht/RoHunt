import 'package:flutter/material.dart';

import '../../../core/routing/routes.dart';
import '../services/auth_service.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final AuthService _authService = AuthService();

  bool _isChecking = false;
  bool _isResending = false;

  Future<void> _checkVerification() async {
    setState(() {
      _isChecking = true;
    });

    final isVerified = await _authService.isCurrentUserEmailVerified();

    if (!mounted) return;

    setState(() {
      _isChecking = false;
    });

    if (isVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email verificat cu succes!')),
      );

      Navigator.pushReplacementNamed(context, Routes.home);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Emailul nu este verificat încă. Verifică inbox-ul.'),
      ),
    );
  }

  Future<void> _resendEmail() async {
    setState(() {
      _isResending = true;
    });

    await _authService.resendVerificationEmail();

    if (!mounted) return;

    setState(() {
      _isResending = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dacă Firebase permite, emailul a fost retrimis.'),
      ),
    );
  }

  Future<void> _logout() async {
    await _authService.logout();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      Routes.welcome,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verificare email'), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.mark_email_unread, size: 80),
              const SizedBox(height: 24),
              const Text(
                'Verifică emailul',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Ți-am trimis un link de verificare. Deschide emailul, apasă pe link, apoi revino aici.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Verifică și folderul Spam sau Promotions.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isChecking ? null : _checkVerification,
                  child: _isChecking
                      ? const CircularProgressIndicator()
                      : const Text('Am verificat emailul'),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _isResending ? null : _resendEmail,
                child: _isResending
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Retrimite emailul'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _logout,
                child: const Text('Folosește alt cont'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
