import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../navigation/main_navigation.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common_widgets.dart';
import '../security/app_lock_screen.dart';
import 'auth_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, AppSettingsProvider>(
      builder: (context, auth, settings, _) {
        if (auth.isLoading || settings.isLoading) {
          return const Scaffold(
            body: LoadingWidget(),
          );
        }

        if (auth.isLoggedIn) {
          if (settings.appLockEnabled && settings.isLocked) {
            return const AppLockScreen();
          }
          return const MainNavigation();
        }

        return const AuthScreen();
      },
    );
  }
}
