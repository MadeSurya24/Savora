import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../AppTheme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_strings.dart';
import '../../widgets/common_widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SavoraAppBar(title: strings.editProfile, showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: AppColors.lightGreen,
                      child: Text(
                        (_nameController.text.trim().isNotEmpty
                                ? _nameController.text.trim()[0]
                                : 'S')
                            .toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primaryGreen,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Nama tampilan',
                        hintText: 'Masukkan nama Anda',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.isEmpty) return 'Nama tidak boleh kosong';
                        if (text.length < 2) return 'Nama terlalu pendek';
                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      initialValue: user?.email ?? '-',
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: 'Email Google',
                        prefixIcon: Icon(Icons.mail_outline_rounded),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.check_rounded),
                label: Text(strings.save),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await context
        .read<AuthProvider>()
        .updateProfileName(_nameController.text);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Profil berhasil diperbarui.' : 'Profil gagal diperbarui.',
        ),
      ),
    );

    if (success) Navigator.pop(context);
  }
}
