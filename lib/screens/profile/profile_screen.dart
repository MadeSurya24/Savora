import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../AppTheme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/common_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const SavoraAppBar(title: 'Profil'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildStatsCard(context),
            const SizedBox(height: 24),
            _buildMenuSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return AppCard(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667EEA).withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'M',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 32,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Made Bagas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'madebagas@email.com',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Premium Member 🌟',
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        return AppCard(
          child: Row(
            children: [
              _ProfileStat(
                label: 'Transaksi',
                value: '${provider.allTransactions.length}',
                icon: Icons.receipt_long_rounded,
                color: AppColors.primaryGreen,
              ),
              _buildDivider(),
              _ProfileStat(
                label: 'Pemasukan',
                value: CurrencyFormatter.formatShort(provider.totalIncome),
                icon: Icons.trending_up_rounded,
                color: AppColors.income,
              ),
              _buildDivider(),
              _ProfileStat(
                label: 'Pengeluaran',
                value: CurrencyFormatter.formatShort(provider.totalExpense),
                icon: Icons.trending_down_rounded,
                color: AppColors.expense,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDivider() {
    return Container(
        width: 1, height: 40, color: AppColors.divider,
        margin: const EdgeInsets.symmetric(horizontal: 8));
  }

  Widget _buildMenuSection() {
    final items = [
      _MenuItem(
          icon: Icons.person_outline_rounded,
          label: 'Edit Profil',
          color: AppColors.primaryGreen),
      _MenuItem(
          icon: Icons.notifications_outlined,
          label: 'Notifikasi',
          color: const Color(0xFF3B82F6)),
      _MenuItem(
          icon: Icons.security_rounded,
          label: 'Keamanan',
          color: const Color(0xFF8B5CF6)),
      _MenuItem(
          icon: Icons.backup_rounded,
          label: 'Backup & Restore',
          color: const Color(0xFFF59E0B)),
      _MenuItem(
          icon: Icons.language_rounded,
          label: 'Bahasa',
          color: const Color(0xFF14B8A6)),
      _MenuItem(
          icon: Icons.help_outline_rounded,
          label: 'Bantuan & Dukungan',
          color: const Color(0xFF6366F1)),
      _MenuItem(
          icon: Icons.info_outline_rounded,
          label: 'Tentang Savora',
          color: const Color(0xFF94A3B8)),
    ];

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: items.asMap().entries.map((e) {
          final item = e.value;
          final isLast = e.key == items.length - 1;
          return Column(
            children: [
              ListTile(
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: item.color, size: 20),
                ),
                title: Text(item.label,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textLight, size: 20),
                onTap: () {},
              ),
              if (!isLast)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(height: 1, color: AppColors.divider),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _ProfileStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;

  _MenuItem({required this.icon, required this.label, required this.color});
}