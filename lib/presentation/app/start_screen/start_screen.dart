import 'package:flutter/material.dart';
import 'package:pytl_backup/domain/services/cache_service.dart';
import 'package:pytl_backup/presentation/auth/login_screen/login_screen.dart';
import 'package:pytl_backup/presentation/user/navigation/navigation_screen/navigation_screen.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  bool checkSign() {
    final prefs = CacheService.instance;
    return prefs.getString("email")?.isNotEmpty ?? false;
  }

  @override
  Widget build(BuildContext context) {
    if (checkSign()) {
      return const NavigationScreen();
    } else {
      return const LoginScreen();
    }
  }
}
