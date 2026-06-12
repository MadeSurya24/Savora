import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../AppTheme/app_theme.dart';
import '../../providers/app_settings_provider.dart';
import '../../utils/app_strings.dart';
import '../../widgets/common_widgets.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final settings = context.watch<AppSettingsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SavoraAppBar(title: strings.language, showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _LanguageTile(
                title: 'Bahasa Indonesia',
                subtitle: 'Gunakan bahasa Indonesia di menu utama.',
                value: 'id',
                groupValue: settings.languageCode,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Divider(height: 1, color: AppColors.divider),
              ),
              _LanguageTile(
                title: 'English',
                subtitle: 'Use English in the main menus.',
                value: 'en',
                groupValue: settings.languageCode,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final String groupValue;

  const _LanguageTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.groupValue,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      value: value,
      groupValue: groupValue,
      activeColor: AppColors.primaryGreen,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
      ),
      onChanged: (code) {
        if (code == null) return;
        context.read<AppSettingsProvider>().setLanguageCode(code);
      },
    );
  }
}
