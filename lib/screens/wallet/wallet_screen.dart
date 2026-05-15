import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../AppTheme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/common_widgets.dart';
import '../transaction/transaction_list_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionProvider>(context, listen: false)
          .loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const SavoraAppBar(title: 'Dompet Saya'),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWalletCard(provider),
                const SizedBox(height: 24),
                _buildStatsRow(provider),
                const SizedBox(height: 24),
                SectionHeader(
                  title: 'Riwayat Transaksi',
                  actionText: 'Lihat Semua',
                  onAction: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const TransactionListScreen()),
                  ),
                ),
                const SizedBox(height: 14),
                if (provider.isLoading)
                  const LoadingWidget()
                else if (provider.allTransactions.isEmpty)
                  const EmptyStateWidget(
                    title: 'Belum Ada Transaksi',
                    subtitle: 'Mulai catat keuanganmu',
                    icon: Icons.receipt_long_rounded,
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount:
                    provider.allTransactions.take(10).toList().length,
                    itemBuilder: (context, index) {
                      final transactions =
                      provider.allTransactions.take(10).toList();
                      return TransactionTile(
                          transaction: transactions[index]);
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWalletCard(TransactionProvider provider) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Saldo Bersih',
                style: TextStyle(color: Colors.white60, fontSize: 13),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.account_balance_wallet_rounded,
                        size: 12, color: AppColors.primaryGreen),
                    SizedBox(width: 4),
                    Text(
                      'Main Wallet',
                      style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(provider.balance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _CardStat(
                label: 'Total Masuk',
                amount: provider.totalIncome,
                icon: Icons.arrow_circle_down_rounded,
                color: AppColors.income,
              ),
              const SizedBox(width: 16),
              Container(
                  width: 1, height: 36, color: Colors.white.withOpacity(0.2)),
              const SizedBox(width: 16),
              _CardStat(
                label: 'Total Keluar',
                amount: provider.totalExpense,
                icon: Icons.arrow_circle_up_rounded,
                color: AppColors.expense,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(TransactionProvider provider) {
    final savings = provider.totalIncome - provider.totalExpense;
    final savingsRate = provider.totalIncome > 0
        ? ((savings / provider.totalIncome) * 100)
        : 0.0;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Tabungan Bulan Ini',
            value: CurrencyFormatter.formatShort(savings.abs()),
            subtitle: savings >= 0 ? 'Surplus 😊' : 'Defisit 😟',
            color: savings >= 0 ? AppColors.income : AppColors.expense,
            icon: Icons.savings_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Rasio Tabungan',
            value: '${savingsRate.toStringAsFixed(1)}%',
            subtitle: savingsRate >= 20 ? 'Sangat Baik! 🎉' : 'Perlu Ditingkatkan',
            color: savingsRate >= 20 ? AppColors.income : AppColors.orange,
            icon: Icons.percent_rounded,
          ),
        ),
      ],
    );
  }
}

class _CardStat extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;

  const _CardStat({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(color: Colors.white54, fontSize: 11)),
            Text(
              CurrencyFormatter.formatShort(amount),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(height: 10),
          Text(title,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 3),
          Text(value,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(subtitle,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}