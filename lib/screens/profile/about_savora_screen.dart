import 'package:flutter/material.dart';

import '../../AppTheme/app_theme.dart';
import '../../utils/app_strings.dart';
import '../../widgets/common_widgets.dart';

class AboutSavoraScreen extends StatelessWidget {
  const AboutSavoraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SavoraAppBar(title: strings.aboutSavora, showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          children: [
            AppCard(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Image.asset(
                      'assets/images/savora_logo.png',
                      width: 96,
                      height: 96,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Savora',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Aplikasi pencatatan keuangan pribadi untuk membantu mengelola pemasukan, pengeluaran, dan tabungan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: const [
                  _InfoTile(label: 'Versi aplikasi', value: '1.0.0 (4)'),
                  _Divider(),
                  _InfoTile(label: 'Package', value: 'com.penacode.savora'),
                  _Divider(),
                  _InfoTile(label: 'Developer', value: 'I Made Surya Kartika'),
                  _Divider(),
                  _InfoTile(label: 'Login', value: 'Google Sign-In'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      title: Text(
        label,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(height: 1, color: AppColors.divider),
    );
  }
}
