import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../AppTheme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/saving_goal_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../services/backup_service.dart';
import '../../utils/app_strings.dart';
import '../../widgets/common_widgets.dart';

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  final BackupService _backupService = BackupService();
  final TextEditingController _restoreController = TextEditingController();
  bool _isWorking = false;

  @override
  void dispose() {
    _restoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final transactions = context.watch<TransactionProvider>().allTransactions;
    final goals = context.watch<SavingGoalProvider>().goals;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SavoraAppBar(title: strings.backupRestore, showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppCard(
              child: Row(
                children: [
                  _SummaryPill(
                    icon: Icons.receipt_long_rounded,
                    label: 'Transaksi',
                    value: '${transactions.length}',
                    color: AppColors.primaryGreen,
                  ),
                  const SizedBox(width: 10),
                  _SummaryPill(
                    icon: Icons.savings_rounded,
                    label: 'Tabungan',
                    value: '${goals.length}',
                    color: AppColors.blue,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _SectionTitle(
                    icon: Icons.backup_rounded,
                    title: 'Backup data',
                    subtitle:
                        'Buat salinan data transaksi dan tabungan akun ini.',
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _isWorking ? null : _copyBackup,
                    icon: const Icon(Icons.copy_rounded),
                    label: const Text('Salin backup ke clipboard'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _SectionTitle(
                    icon: Icons.restore_rounded,
                    title: 'Restore data',
                    subtitle:
                        'Tempel JSON backup Savora untuk mengembalikan data.',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _restoreController,
                    minLines: 6,
                    maxLines: 10,
                    decoration: const InputDecoration(
                      hintText: 'Tempel backup JSON di sini',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: _isWorking ? null : _pasteFromClipboard,
                    icon: const Icon(Icons.content_paste_rounded),
                    label: const Text('Tempel dari clipboard'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _isWorking ? null : _restoreBackup,
                    icon: const Icon(Icons.restore_rounded),
                    label: const Text('Pulihkan data'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _copyBackup() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    setState(() => _isWorking = true);
    try {
      final backup = await _backupService.createBackup(user);
      await Clipboard.setData(ClipboardData(text: backup));
      if (mounted) {
        _showMessage('Backup berhasil disalin. Simpan teks ini di tempat aman.');
      }
    } catch (e) {
      if (mounted) _showMessage('Backup gagal dibuat.');
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null || text.isEmpty) {
      _showMessage('Clipboard kosong.');
      return;
    }
    _restoreController.text = text;
  }

  Future<void> _restoreBackup() async {
    final user = context.read<AuthProvider>().currentUser;
    final userId = user?.id;
    if (userId == null) return;

    final text = _restoreController.text.trim();
    if (text.isEmpty) {
      _showMessage('Tempel backup terlebih dahulu.');
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pulihkan data?'),
        content: const Text(
          'Data transaksi dan tabungan akun ini akan diganti dengan isi backup.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Pulihkan'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final transactionProvider = context.read<TransactionProvider>();
    final savingGoalProvider = context.read<SavingGoalProvider>();

    setState(() => _isWorking = true);
    try {
      final summary = await _backupService.restoreBackup(
        userId: userId,
        backupText: text,
      );
      if (!mounted) return;
      await transactionProvider.loadTransactions();
      await savingGoalProvider.loadGoals();
      _restoreController.clear();
      _showMessage(
        'Restore berhasil: ${summary.transactionCount} transaksi, ${summary.savingGoalCount} tabungan.',
      );
    } catch (e) {
      if (mounted) {
        _showMessage('Restore gagal. Pastikan backup JSON benar.');
      }
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
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

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primaryGreen),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
