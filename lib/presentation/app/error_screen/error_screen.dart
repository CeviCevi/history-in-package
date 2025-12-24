import 'package:flutter/material.dart';
import 'package:pytl_backup/data/styles/colors.dart';
import 'package:pytl_backup/presentation/start_screen/start_screen.dart';
import 'package:pytl_backup/presentation/start_screen/widgets/restart_button.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning_rounded, color: primaryRed),
              SizedBox(width: 10),
              Flexible(
                child: Text(
                  "При загрузке приложения произошла ошибка",
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              ),
            ],
          ),
          SizedBox(height: 25),
          RestartButton(
            function: () => Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) =>
                    const StartScreen(),
                transitionDuration: Duration.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
