import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/transaction_provider.dart';
import '../../models/category_model.dart';
import '../../AppTheme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/common_widgets.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _weeklyData = [];
  List<Map<String, dynamic>> _monthlyData = [];
  bool _isLoading = true;
  int _touchedPieIndex = -1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    await provider.loadTransactions();
    final weekly = await provider.getWeeklyExpenses();
    final monthly = await provider.getMonthlyExpenses();
    if (mounted) {
      setState(() {
        _weeklyData = weekly;
        _monthlyData = monthly;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SavoraAppBar(
        title: 'Wawasan Keuangan',
        showBack: ModalRoute.of(context)?.canPop ?? false,
      ),
      body: _isLoading
          ? const LoadingWidget()
          : Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCards(provider)
                    .animate()
                    .fadeIn(duration: 400.ms),
                const SizedBox(height: 24),
                _buildChartSection(provider)
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 400.ms),
                const SizedBox(height: 24),
                _buildPieChartSection(provider)
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 400.ms),
                const SizedBox(height: 24),
                _buildCategoryBreakdown(provider)
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 400.ms),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(TransactionProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            label: 'Total Pengeluaran',
            amount: provider.totalExpense,
            icon: Icons.arrow_upward_rounded,
            color: AppColors.expense,
            bgColor: AppColors.expenseLight,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            label: 'Total Pemasukan',
            amount: provider.totalIncome,
            icon: Icons.arrow_downward_rounded,
            color: AppColors.income,
            bgColor: AppColors.lightGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String label,
    required double amount,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.formatShort(amount),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(TransactionProvider provider) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Tren Pengeluaran'),
          const SizedBox(height: 6),
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primaryGreen,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primaryGreen,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: 'Mingguan'),
              Tab(text: 'Bulanan'),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBarChart(isWeekly: true),
                _buildBarChart(isWeekly: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart({required bool isWeekly}) {
    final data = isWeekly ? _weeklyData : _monthlyData;

    if (data.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada data',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    final List<BarChartGroupData> barGroups = [];
    double maxY = 0;

    for (int i = 0; i < data.length; i++) {
      final total = (data[i]['total'] as num).toDouble();
      if (total > maxY) maxY = total;
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: total,
              color: AppColors.primaryGreen,
              width: isWeekly ? 28 : 22,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              gradient: const LinearGradient(
                colors: [AppColors.primaryGreen, AppColors.darkGreen],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY * 1.3,
        barGroups: barGroups,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (_) => FlLine(
            color: AppColors.divider,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= data.length) return const SizedBox.shrink();
                final label = isWeekly
                    ? DateFormatter.getDayName(
                    DateTime.parse(data[index]['date'] as String).weekday)
                    : DateFormatter.getMonthName(
                    data[index]['month'] as String);
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipRoundedRadius: 10,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                CurrencyFormatter.formatShort(rod.toY),
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPieChartSection(TransactionProvider provider) {
    final data = provider.expenseByCategory;
    if (data.isEmpty) return const SizedBox.shrink();

    final total = data.values.fold(0.0, (a, b) => a + b);
    final colors = [
      const Color(0xFFF59E0B),
      const Color(0xFF3B82F6),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFF14B8A6),
      const Color(0xFFEF4444),
      const Color(0xFF6366F1),
      const Color(0xFF94A3B8),
    ];

    final sections = data.entries.toList().asMap().entries.map((e) {
      final idx = e.key;
      final entry = e.value;
      final percent = total > 0 ? (entry.value / total * 100) : 0.0;
      final isTouched = idx == _touchedPieIndex;
      return PieChartSectionData(
        value: entry.value,
        color: colors[idx % colors.length],
        radius: isTouched ? 72 : 60,
        title: isTouched ? '${percent.toStringAsFixed(1)}%' : '',
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      );
    }).toList();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Distribusi Pengeluaran'),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                height: 160,
                width: 160,
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: 36,
                    sectionsSpace: 3,
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              response == null ||
                              response.touchedSection == null) {
                            _touchedPieIndex = -1;
                            return;
                          }
                          _touchedPieIndex = response
                              .touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: data.entries.toList().asMap().entries.map((e) {
                    final idx = e.key;
                    final entry = e.value;
                    final cat = AppCategories.findById(entry.key);
                    final pct = total > 0
                        ? (entry.value / total * 100).toStringAsFixed(1)
                        : '0';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: colors[idx % colors.length],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              cat?.name ?? entry.key,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '$pct%',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(TransactionProvider provider) {
    final data = provider.expenseByCategory;
    if (data.isEmpty) return const SizedBox.shrink();

    final total = data.values.fold(0.0, (a, b) => a + b);
    final sorted = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Rincian per Kategori'),
          const SizedBox(height: 16),
          ...sorted.map((entry) {
            final cat = AppCategories.findById(entry.key);
            final progress = total > 0 ? entry.value / total : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: (cat?.color ?? AppColors.primaryGreen)
                              .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          cat?.icon ?? Icons.circle_rounded,
                          color: cat?.color ?? AppColors.primaryGreen,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  cat?.name ?? entry.key,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  CurrencyFormatter.formatShort(entry.value),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 6,
                                backgroundColor:
                                (cat?.color ?? AppColors.primaryGreen)
                                    .withOpacity(0.15),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  cat?.color ?? AppColors.primaryGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}