import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../AppTheme/app_theme.dart';
import '../../utils/app_strings.dart';
import '../../widgets/common_widgets.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const String supportEmail = 'suryamade428@gmail.com';

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SavoraAppBar(title: strings.helpSupport, showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Panduan cepat',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _HelpItem(
                    icon: Icons.add_circle_rounded,
                    title: 'Mencatat transaksi',
                    description:
                        'Gunakan tombol tambah di tengah navigasi untuk mencatat pemasukan atau pengeluaran.',
                  ),
                  _HelpItem(
                    icon: Icons.savings_rounded,
                    title: 'Mengelola tabungan',
                    description:
                        'Buka menu Tabungan untuk membuat target dan menambahkan nominal yang sudah terkumpul.',
                  ),
                  _HelpItem(
                    icon: Icons.backup_rounded,
                    title: 'Melindungi data',
                    description:
                        'Buat backup secara berkala, terutama sebelum uninstall atau pindah perangkat.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Dukungan',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Jika menemukan kendala, salin email berikut dan kirimkan detail masalah beserta screenshot jika ada.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(
                        const ClipboardData(text: supportEmail),
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Email dukungan disalin.'),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.copy_rounded),
                    label: const Text(supportEmail),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _HelpItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryGreen, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
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
    );
  }
}
