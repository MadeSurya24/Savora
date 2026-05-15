import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/saving_goal_provider.dart';
import '../../models/saving_goal_model.dart';
import '../../AppTheme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/common_widgets.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SavingGoalProvider>(context, listen: false).loadGoals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SavoraAppBar(
        title: 'Target Tabungan',
        showBack: ModalRoute.of(context)?.canPop ?? false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => _showAddGoalSheet(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<SavingGoalProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) return const LoadingWidget();

          if (provider.goals.isEmpty) {
            return Column(
              children: [
                _buildSummaryCard(provider),
                const Expanded(
                  child: EmptyStateWidget(
                    title: 'Belum Ada Target',
                    subtitle: 'Tambahkan target tabungan pertamamu!',
                    icon: Icons.savings_rounded,
                  ),
                ),
              ],
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryCard(provider),
                      const SizedBox(height: 24),
                      const SectionHeader(title: 'Target Aktif'),
                      const SizedBox(height: 14),
                      ...provider.goals.asMap().entries.map((e) {
                        return _buildGoalCard(context, provider, e.value)
                            .animate()
                            .fadeIn(
                            delay: Duration(milliseconds: 100 * e.key),
                            duration: 400.ms)
                            .slideY(begin: 0.05);
                      }),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(SavingGoalProvider provider) {
    final totalProgress = provider.totalTargetAmount > 0
        ? provider.totalCurrentAmount / provider.totalTargetAmount
        : 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B82F6).withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total Tabungan',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Text(
              CurrencyFormatter.format(provider.totalCurrentAmount),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'dari target ${CurrencyFormatter.format(provider.totalTargetAmount)}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: totalProgress.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: Colors.white.withOpacity(0.25),
                valueColor:
                const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(totalProgress * 100).toStringAsFixed(1)}% tercapai',
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 12),
                ),
                Text(
                  '${provider.goals.length} target aktif',
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
    );
  }

  Widget _buildGoalCard(
      BuildContext context, SavingGoalProvider provider, SavingGoalModel goal) {
    final colorHex = goal.colorHex ?? '#0FA968';
    final color = Color(int.parse(colorHex.replaceAll('#', '0xFF')));

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      goal.emoji ?? '🎯',
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded,
                              size: 11, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            'Deadline: ${DateFormatter.formatDate(goal.deadline)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded,
                      color: AppColors.textSecondary, size: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  onSelected: (value) {
                    if (value == 'add') {
                      _showAddFundsSheet(context, provider, goal);
                    } else if (value == 'delete') {
                      _confirmDeleteGoal(context, provider, goal.id!);
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'add',
                      child: Row(
                        children: [
                          Icon(Icons.add_circle_outline_rounded,
                              size: 18, color: AppColors.primaryGreen),
                          SizedBox(width: 8),
                          Text('Tambah Dana'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded,
                              size: 18, color: AppColors.expense),
                          SizedBox(width: 8),
                          Text('Hapus Target',
                              style: TextStyle(color: AppColors.expense)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Terkumpul',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textSecondary),
                    ),
                    Text(
                      CurrencyFormatter.formatShort(goal.currentAmount),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Target',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textSecondary),
                    ),
                    Text(
                      CurrencyFormatter.formatShort(goal.targetAmount),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: goal.progress,
                      minHeight: 8,
                      backgroundColor: color.withOpacity(0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${goal.progressPercentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  goal.daysLeft > 30
                      ? Icons.access_time_rounded
                      : Icons.warning_amber_rounded,
                  size: 12,
                  color: goal.daysLeft > 30
                      ? AppColors.textSecondary
                      : AppColors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  goal.isCompleted
                      ? '🎉 Target tercapai!'
                      : goal.daysLeft > 0
                      ? '${goal.daysLeft} hari tersisa'
                      : 'Target melewati deadline',
                  style: TextStyle(
                    fontSize: 11,
                    color: goal.isCompleted
                        ? AppColors.income
                        : goal.daysLeft > 30
                        ? AppColors.textSecondary
                        : AppColors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddGoalSheet(BuildContext context) {
    final titleCtrl = TextEditingController();
    final targetCtrl = TextEditingController();
    DateTime deadline = DateTime.now().add(const Duration(days: 90));
    String emoji = '🎯';
    String colorHex = '#0FA968';

    final emojis = ['🎯', '💻', '🏖️', '🏍️', '🛡️', '🏠', '✈️', '📱', '👗', '🎓'];
    final colors = [
      '#0FA968', '#3B82F6', '#F59E0B', '#8B5CF6',
      '#EC4899', '#EF4444', '#14B8A6',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Target Baru',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                const Text('Pilih Emoji',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: emojis.map((e) => GestureDetector(
                    onTap: () => setS(() => emoji = e),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: emoji == e ? AppColors.lightGreen : AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: emoji == e ? AppColors.primaryGreen : Colors.transparent,
                        ),
                      ),
                      child: Center(child: Text(e, style: const TextStyle(fontSize: 20))),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(hintText: 'Nama target (cth: Laptop Baru)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: targetCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Target nominal',
                    prefixText: 'Rp ',
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    final d = await showDatePicker(
                      context: ctx,
                      initialDate: deadline,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                      builder: (context, child) => Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(primary: AppColors.primaryGreen),
                        ),
                        child: child!,
                      ),
                    );
                    if (d != null) setS(() => deadline = d);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            size: 18, color: AppColors.primaryGreen),
                        const SizedBox(width: 10),
                        Text(
                          'Deadline: ${DateFormatter.formatDate(deadline)}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      if (titleCtrl.text.isEmpty || targetCtrl.text.isEmpty) return;
                      final goal = SavingGoalModel(
                        title: titleCtrl.text,
                        targetAmount: double.tryParse(targetCtrl.text) ?? 0,
                        currentAmount: 0,
                        deadline: deadline,
                        emoji: emoji,
                        colorHex: colorHex,
                      );
                      Provider.of<SavingGoalProvider>(ctx, listen: false).addGoal(goal);
                      Navigator.pop(ctx);
                    },
                    child: const Text('Simpan Target',
                        style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddFundsSheet(
      BuildContext context, SavingGoalProvider provider, SavingGoalModel goal) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Tambah Dana ke "${goal.title}"',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Nominal',
                prefixText: 'Rp ',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(ctrl.text);
                  if (amount != null && amount > 0) {
                    provider.addToGoal(goal.id!, amount);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Tambah Dana',
                    style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteGoal(
      BuildContext context, SavingGoalProvider provider, int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Target'),
        content: const Text('Apakah kamu yakin ingin menghapus target ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.expense,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: const Text('Hapus',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) await provider.deleteGoal(id);
  }
}