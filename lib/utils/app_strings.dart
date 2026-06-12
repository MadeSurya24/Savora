import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../providers/app_settings_provider.dart';

extension AppStringsContext on BuildContext {
  AppStrings get strings {
    final code = watch<AppSettingsProvider>().languageCode;
    return AppStrings(code);
  }

  AppStrings get stringsRead {
    final code = read<AppSettingsProvider>().languageCode;
    return AppStrings(code);
  }
}

class AppStrings {
  final String code;

  const AppStrings(this.code);

  bool get isEnglish => code == 'en';

  String get profile => isEnglish ? 'Profile' : 'Profil';
  String get home => isEnglish ? 'Home' : 'Beranda';
  String get insights => isEnglish ? 'Insights' : 'Wawasan';
  String get wallet => isEnglish ? 'Wallet' : 'Dompet';
  String get addTransaction => isEnglish ? 'Add Transaction' : 'Tambah Transaksi';
  String get chooseTransactionType => isEnglish
      ? 'Choose the transaction type you want to add'
      : 'Pilih jenis transaksi yang ingin ditambahkan';
  String get income => isEnglish ? 'Income' : 'Pemasukan';
  String get expense => isEnglish ? 'Expense' : 'Pengeluaran';
  String get savings => isEnglish ? 'Savings' : 'Tabungan';
  String get analysis => isEnglish ? 'Analysis' : 'Analisis';
  String get quickMenu => isEnglish ? 'Quick Menu' : 'Menu Cepat';
  String get recentTransactions =>
      isEnglish ? 'Recent Transactions' : 'Transaksi Terakhir';
  String get viewAll => isEnglish ? 'View All' : 'Lihat Semua';
  String get noTransactions =>
      isEnglish ? 'No Transactions Yet' : 'Belum Ada Transaksi';
  String get startTracking => isEnglish
      ? 'Start recording your income and expenses'
      : 'Mulai catat pemasukan dan pengeluaranmu';
  String get totalBalance => isEnglish ? 'Total Balance' : 'Total Saldo';
  String get healthyFinance => isEnglish
      ? 'Your finances look healthy today.'
      : 'Keuangan Anda terlihat sehat hari ini.';
  String get googleAccount => isEnglish ? 'Google Account' : 'Akun Google';
  String get transactions => isEnglish ? 'Transactions' : 'Transaksi';
  String get editProfile => isEnglish ? 'Edit Profile' : 'Edit Profil';
  String get security => isEnglish ? 'Security' : 'Keamanan';
  String get backupRestore => isEnglish ? 'Backup & Restore' : 'Backup & Restore';
  String get language => isEnglish ? 'Language' : 'Bahasa';
  String get helpSupport =>
      isEnglish ? 'Help & Support' : 'Bantuan & Dukungan';
  String get aboutSavora => isEnglish ? 'About Savora' : 'Tentang Savora';
  String get logout => isEnglish ? 'Sign Out' : 'Keluar';
  String get signOutTitle =>
      isEnglish ? 'Sign out of your account?' : 'Keluar dari akun?';
  String get signOutMessage => isEnglish
      ? 'You can sign in again with the same Google account.'
      : 'Kamu bisa masuk lagi dengan akun Google yang sama.';
  String get cancel => isEnglish ? 'Cancel' : 'Batal';
  String get save => isEnglish ? 'Save' : 'Simpan';
  String get signOut => isEnglish ? 'Sign Out' : 'Keluar';

  String greeting(DateTime now) {
    final hour = now.hour;
    if (isEnglish) {
      if (hour < 12) return 'Good Morning';
      if (hour < 18) return 'Good Afternoon';
      return 'Good Evening';
    }
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }
}
