import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../navigation/main_navigation.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common_widgets.dart';
import 'auth_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isLoading) {
          return const Scaffold(
            body: LoadingWidget(),
          );
        }

        if (auth.isLoggedIn) {
          return const MainNavigation();
        }

        return const AuthScreen();
      },
    );
  }
}
