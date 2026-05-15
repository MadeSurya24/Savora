import 'package:flutter/material.dart';
import '../AppTheme/app_theme.dart';

class CategoryModel {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String type; // 'income', 'expense', or 'both'

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });
}

class AppCategories {
  static const List<CategoryModel> expense = [
    CategoryModel(
      id: 'food',
      name: 'Makanan & Minuman',
      icon: Icons.restaurant_rounded,
      color: Color(0xFFF59E0B),
      type: 'expense',
    ),
    CategoryModel(
      id: 'transport',
      name: 'Transportasi',
      icon: Icons.directions_car_rounded,
      color: Color(0xFF3B82F6),
      type: 'expense',
    ),
    CategoryModel(
      id: 'lifestyle',
      name: 'Gaya Hidup',
      icon: Icons.spa_rounded,
      color: Color(0xFF8B5CF6),
      type: 'expense',
    ),
    CategoryModel(
      id: 'entertainment',
      name: 'Hiburan',
      icon: Icons.movie_rounded,
      color: Color(0xFFEC4899),
      type: 'expense',
    ),
    CategoryModel(
      id: 'shopping',
      name: 'Belanja',
      icon: Icons.shopping_bag_rounded,
      color: Color(0xFF14B8A6),
      type: 'expense',
    ),
    CategoryModel(
      id: 'health',
      name: 'Kesehatan',
      icon: Icons.favorite_rounded,
      color: Color(0xFFEF4444),
      type: 'expense',
    ),
    CategoryModel(
      id: 'education',
      name: 'Pendidikan',
      icon: Icons.school_rounded,
      color: Color(0xFF6366F1),
      type: 'expense',
    ),
    CategoryModel(
      id: 'other_expense',
      name: 'Lainnya',
      icon: Icons.more_horiz_rounded,
      color: Color(0xFF94A3B8),
      type: 'expense',
    ),
  ];

  static const List<CategoryModel> income = [
    CategoryModel(
      id: 'salary',
      name: 'Gaji',
      icon: Icons.account_balance_wallet_rounded,
      color: AppColors.primaryGreen,
      type: 'income',
    ),
    CategoryModel(
      id: 'freelance',
      name: 'Freelance',
      icon: Icons.laptop_rounded,
      color: Color(0xFF0EA5E9),
      type: 'income',
    ),
    CategoryModel(
      id: 'investment',
      name: 'Investasi',
      icon: Icons.trending_up_rounded,
      color: Color(0xFF10B981),
      type: 'income',
    ),
    CategoryModel(
      id: 'gift',
      name: 'Hadiah',
      icon: Icons.card_giftcard_rounded,
      color: Color(0xFFF472B6),
      type: 'income',
    ),
    CategoryModel(
      id: 'other_income',
      name: 'Lainnya',
      icon: Icons.add_circle_rounded,
      color: Color(0xFF94A3B8),
      type: 'income',
    ),
  ];

  static CategoryModel? findById(String id) {
    try {
      return [...expense, ...income].firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<CategoryModel> getAll() => [...expense, ...income];
}