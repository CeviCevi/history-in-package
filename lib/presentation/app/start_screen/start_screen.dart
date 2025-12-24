import 'package:flutter/material.dart';
import 'package:pytl_backup/presentation/error_screen/error_screen.dart';
import 'package:pytl_backup/presentation/login_screen/login_screen.dart';
import 'package:pytl_backup/presentation/navigation_screen/navigation_screen.dart';
import 'package:pytl_backup/presentation/start_screen/wait_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  Future<bool> checkSign() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    //await prefs.clear();
    return prefs.getString("email")?.isNotEmpty ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: checkSign(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return WaitScreen();
        }

        if (snapshot.hasData) {
          if (snapshot.data!) {
            return const NavigationScreen();
          } else {
            return const LoginScreen();
          }
        }

        if (snapshot.hasError) {
          return ErrorScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
