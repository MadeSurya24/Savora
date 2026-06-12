import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../AppTheme/app_theme.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_strings.dart';
import '../../widgets/common_widgets.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final settings = context.watch<AppSettingsProvider>();
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SavoraAppBar(title: strings.security, showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppCard(
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.lightGreen,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.verified_user_rounded,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Akun Google terhubung',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.email ?? '-',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  SwitchListTile(
                    value: settings.appLockEnabled,
                    activeColor: AppColors.primaryGreen,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 6,
                    ),
                    secondary: const Icon(
                      Icons.lock_outline_rounded,
                      color: AppColors.primaryGreen,
                    ),
                    title: const Text(
                      'Kunci aplikasi dengan PIN',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: const Text(
                      'Minta PIN saat Savora dibuka kembali.',
                      style: TextStyle(fontSize: 12),
                    ),
                    onChanged: (enabled) => enabled
                        ? _enablePin(context)
                        : _disablePin(context),
                  ),
                  if (settings.appLockEnabled) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Divider(height: 1, color: AppColors.divider),
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 4,
                      ),
                      leading: const Icon(
                        Icons.lock_clock_rounded,
                        color: AppColors.primaryGreen,
                      ),
                      title: const Text(
                        'Kunci sekarang',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: const Text(
                        'Coba layar PIN tanpa keluar akun.',
                        style: TextStyle(fontSize: 12),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        context.read<AppSettingsProvider>().lock();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'PIN tersimpan secara lokal di perangkat ini. Akun Google tetap menjadi pengaman utama untuk identitas pengguna.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _enablePin(BuildContext context) async {
    final pin = await _showPinDialog(
      context,
      title: 'Buat PIN',
      message: 'Masukkan PIN 4-6 digit untuk mengunci Savora.',
      confirmLabel: 'Lanjut',
    );
    if (pin == null || !context.mounted) return;

    final confirm = await _showPinDialog(
      context,
      title: 'Konfirmasi PIN',
      message: 'Masukkan PIN yang sama sekali lagi.',
      confirmLabel: 'Aktifkan',
    );
    if (confirm == null || !context.mounted) return;

    if (pin != confirm) {
      _showMessage(context, 'PIN tidak sama.');
      return;
    }

    final success = await context.read<AppSettingsProvider>().enablePin(pin);
    if (context.mounted) {
      _showMessage(
        context,
        success ? 'Kunci aplikasi aktif.' : 'PIN harus berisi 4-6 digit.',
      );
    }
  }

  Future<void> _disablePin(BuildContext context) async {
    final pin = await _showPinDialog(
      context,
      title: 'Nonaktifkan PIN',
      message: 'Masukkan PIN saat ini.',
      confirmLabel: 'Nonaktifkan',
    );
    if (pin == null || !context.mounted) return;

    final success = await context.read<AppSettingsProvider>().disablePin(pin);
    if (context.mounted) {
      _showMessage(
        context,
        success ? 'Kunci aplikasi dinonaktifkan.' : 'PIN salah.',
      );
    }
  }

  Future<String?> _showPinDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
  }) {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              autofocus: true,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: const InputDecoration(
                counterText: '',
                hintText: 'PIN',
              ),
              onSubmitted: (_) => Navigator.pop(ctx, controller.text.trim()),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
