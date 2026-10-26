import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_theme.dart';
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _email = TextEditingController(text: 'mahasiswa@jti.polinema.ac.id');
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref
        .read(authStateProvider.notifier)
        .login(_email.text.trim(), _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);
    final loading = auth.isLoading;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
          children: [
            const CircleAvatar(
              radius: 28,
              backgroundColor: AppTheme.brand,
              child: Icon(Icons.school_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 16),
            const Text(
              'Campus LMS',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppTheme.text,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Masuk untuk membuka kelas, tugas, dan pengumuman.',
              style: TextStyle(color: AppTheme.muted, height: 1.4),
            ),
            const SizedBox(height: 28),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    enabled: !loading,
                    decoration: _field('Email kampus'),
                    validator: (value) {
                      if (value == null || !value.contains('@')) {
                        return 'Masukkan email yang valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    enabled: !loading,
                    onFieldSubmitted: (_) => _submit(),
                    decoration: _field('Kata sandi (min. 6 karakter)'),
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Kata sandi minimal 6 karakter';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            if (auth.hasError) ...[
              const SizedBox(height: 12),
              Text(
                auth.error.toString().replaceFirst('Exception: ', ''),
                style: const TextStyle(color: Color(0xFFB42318)),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: loading ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.brand,
                foregroundColor: AppTheme.onBrand,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Masuk'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ini mock login. Token yang tersimpan adalah simulasi, bukan JWT server.',
              style: TextStyle(
                color: AppTheme.muted,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _field(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: AppTheme.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTheme.hairline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTheme.hairline),
      ),
    );
  }
}
