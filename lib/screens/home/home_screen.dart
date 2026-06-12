import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/saving_goal_provider.dart';
import '../../AppTheme/app_theme.dart';
import '../../utils/app_strings.dart';
import '../../utils/formatters.dart';
import '../../widgets/common_widgets.dart';
import '../../models/transaction_model.dart';
import '../transaction/add_transaction_screen.dart';
import '../transaction/transaction_list_screen.dart';
import '../savings/savings_screen.dart';
import '../insights/insights_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<TransactionModel> _recentTransactions = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final txProvider = Provider.of<TransactionProvider>(context, listen: false);
    await txProvider.loadTransactions();

    final recent = await txProvider.getRecentTransactions(limit: 5);

    if (mounted) {
      setState(() => _recentTransactions = recent);
    }

    await Provider.of<SavingGoalProvider>(context, listen: false).loadGoals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: AppColors.primaryGreen,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppBar(),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildGreeting(),
                      const SizedBox(height: 20),
                      _buildBalanceCard(),
                      const SizedBox(height: 24),
                      _buildQuickMenu(),
                      const SizedBox(height: 24),
                      _buildRecentTransactions(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryGreen, AppColors.darkGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'S',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Savora',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  final name = auth.currentUser?.name ?? 'Savora';
                  final initial = name.isNotEmpty ? name[0].toUpperCase() : 'S';

                  return Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    final strings = context.strings;
    final user = context.watch<AuthProvider>().currentUser;
    final firstName = (user?.name ?? 'Teman').trim().split(' ').first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${strings.greeting(DateTime.now())}, $firstName',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
        const SizedBox(height: 4),
        Text(
          strings.healthyFinance,
          style: const TextStyle(
            fontSize: 13.5,
            color: AppColors.textSecondary,
          ),
        ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
      ],
    );
  }

  Widget _buildBalanceCard() {
    final strings = context.strings;
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryGreen, AppColors.darkGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen.withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 10),
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
                  Text(
                    strings.totalBalance,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 11,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormatter.formatMonthYear(DateTime.now()),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
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
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                height: 1,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildBalanceStat(
                      label: strings.income,
                      amount: provider.totalIncome,
                      icon: Icons.arrow_downward_rounded,
                      isIncome: true,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  Expanded(
                    child: _buildBalanceStat(
                      label: strings.expense,
                      amount: provider.totalExpense,
                      icon: Icons.arrow_upward_rounded,
                      isIncome: false,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(delay: 150.ms, duration: 500.ms).slideY(begin: 0.1);
      },
    );
  }

  Widget _buildBalanceStat({
    required String label,
    required double amount,
    required IconData icon,
    required bool isIncome,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  CurrencyFormatter.formatShort(amount),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMenu() {
    final strings = context.strings;
    final menus = [
      _QuickMenu(
        icon: Icons.add_circle_rounded,
        label: strings.income,
        color: AppColors.primaryGreen,
        bgColor: AppColors.lightGreen,
        onTap: () => _navigateToAddTransaction('income'),
      ),
      _QuickMenu(
        icon: Icons.remove_circle_rounded,
        label: strings.expense,
        color: AppColors.expense,
        bgColor: AppColors.expenseLight,
        onTap: () => _navigateToAddTransaction('expense'),
      ),
      _QuickMenu(
        icon: Icons.savings_rounded,
        label: strings.savings,
        color: const Color(0xFF3B82F6),
        bgColor: const Color(0xFFEFF6FF),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SavingsScreen()),
        ),
      ),
      _QuickMenu(
        icon: Icons.bar_chart_rounded,
        label: strings.analysis,
        color: const Color(0xFF8B5CF6),
        bgColor: const Color(0xFFF5F3FF),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const InsightsScreen()),
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: strings.quickMenu),
        const SizedBox(height: 14),
        Row(
          children: menus.asMap().entries.map((e) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: e.key < menus.length - 1 ? 8 : 0,
                ),
                child: _buildQuickMenuItem(e.value)
                    .animate()
                    .fadeIn(delay: Duration(milliseconds: 200 + e.key * 80))
                    .scale(begin: const Offset(0.95, 0.95)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickMenuItem(_QuickMenu menu) {
    return GestureDetector(
      onTap: menu.onTap,
      child: Container(
        height: 104,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: menu.bgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                menu.icon,
                color: menu.color,
                size: 21,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  menu.label,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.visible,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    final strings = context.strings;
    return Column(
      children: [
        SectionHeader(
          title: strings.recentTransactions,
          actionText: strings.viewAll,
          onAction: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const TransactionListScreen(),
            ),
          ),
        ),
        const SizedBox(height: 14),
        if (_recentTransactions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: EmptyStateWidget(
              title: strings.noTransactions,
              subtitle: strings.startTracking,
              icon: Icons.receipt_long_rounded,
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentTransactions.length,
            itemBuilder: (context, index) {
              return TransactionTile(
                transaction: _recentTransactions[index],
              )
                  .animate()
                  .fadeIn(delay: Duration(milliseconds: 300 + index * 80))
                  .slideX(begin: 0.05);
            },
          ),
      ],
    );
  }

  void _navigateToAddTransaction(String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(initialType: type),
      ),
    ).then((_) => _loadData());
  }
}

class _QuickMenu {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  _QuickMenu({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });
}
