import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../AppTheme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'add_transaction_screen.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionProvider>(context, listen: false)
          .loadTransactions();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SavoraAppBar(
        title: 'Semua Transaksi',
        showBack: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add_rounded,
                    color: Colors.white, size: 20),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                    const AddTransactionScreen(initialType: 'expense')),
              ).then((_) => Provider.of<TransactionProvider>(context,
                  listen: false)
                  .loadTransactions()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Column(
              children: [
                _buildSearchBar(),
                const SizedBox(height: 12),
                _buildFilterChips(),
              ],
            ),
          ),
          Expanded(child: _buildTransactionList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        return TextField(
          controller: _searchController,
          onChanged: provider.setSearchQuery,
          decoration: InputDecoration(
            hintText: 'Cari transaksi...',
            prefixIcon: const Icon(Icons.search_rounded,
                color: AppColors.textSecondary, size: 20),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.close_rounded,
                  color: AppColors.textSecondary, size: 18),
              onPressed: () {
                _searchController.clear();
                provider.setSearchQuery('');
              },
            )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildFilterChips() {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        return Row(
          children: [
            _FilterChip(
              label: 'Semua',
              isSelected: provider.filterType == 'all',
              onTap: () => provider.setFilterType('all'),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Pemasukan',
              isSelected: provider.filterType == 'income',
              color: AppColors.income,
              onTap: () => provider.setFilterType('income'),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Pengeluaran',
              isSelected: provider.filterType == 'expense',
              color: AppColors.expense,
              onTap: () => provider.setFilterType('expense'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTransactionList() {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) return const LoadingWidget();

        final transactions = provider.transactions;

        if (transactions.isEmpty) {
          return const EmptyStateWidget(
            title: 'Tidak Ada Transaksi',
            subtitle: 'Coba ubah filter atau kata kunci pencarian',
            icon: Icons.receipt_long_rounded,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            return TransactionTile(
              transaction: transactions[index],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddTransactionScreen(
                    editTransaction: transactions[index],
                  ),
                ),
              ).then((_) => provider.loadTransactions()),
              onDelete: () => _confirmDelete(context, provider, transactions[index].id!),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, TransactionProvider provider, int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Transaksi'),
        content: const Text('Apakah kamu yakin ingin menghapus transaksi ini?'),
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
            child:
            const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await provider.deleteTransaction(id);
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppColors.primaryGreen;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : AppColors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}