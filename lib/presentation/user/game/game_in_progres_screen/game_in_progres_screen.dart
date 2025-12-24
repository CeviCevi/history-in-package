import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pytl_backup/data/styles/colors.dart';

class GameInProgressScreen extends StatelessWidget {
  const GameInProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // ------------------ ИНФО-БЛОК ------------------
            SizedBox(height: 80),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: _boxStyle(color: primaryRed), // Красный контейнер
              child: Column(
                children: [
                  Text(
                    "Игра 389803834\nв самом разгаре!",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Нужно добраться до:\nСквер Василя Цветкова",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // Этот виджет "растягивается" и прижимает кнопки к низу
            const Spacer(),

            // ------------------ КНОПКИ ДЕЙСТВИЙ ------------------

            // Кнопка "В главное меню" (основное действие)
            _buildButton(
              text: "В главное меню",
              color: primaryRed,
              onTap: () {
                // TODO: Добавить логику перехода в главное меню
                // Например, pop() до самого первого экрана
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),

            const SizedBox(height: 15),

            // Кнопка "Покинуть игру" (вторичное действие)
            _buildButton(
              text: "Досрочно покинуть игру",
              color: Colors.grey.shade600,
              onTap: () {
                // Показываем диалог подтверждения
                _showLeaveConfirmationDialog(context);
              },
            ),

            const SizedBox(height: 10), // Небольшой отступ снизу
          ],
        ),
      ),
    );
  }

  /// Универсальный виджет для кнопки
  Widget _buildButton({
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: _boxStyle(color: color),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.manrope(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  /// Стиль для контейнеров (кнопок и инфо-блока)
  BoxDecoration _boxStyle({required Color color}) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Диалог подтверждения выхода из игры
  void _showLeaveConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Покинуть игру?"),
          content: const Text("Вы уверены, что хотите досрочно покинуть игру?"),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          actions: [
            TextButton(
              child: const Text("Отмена"),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text(
                "Покинуть",
                style: GoogleFonts.manrope(color: primaryRed), // Красный акцент
              ),
              onPressed: () {
                // TODO: Добавить логику выхода из игры

                // Закрыть диалог
                Navigator.of(dialogContext).pop();
                // Вернуться на главный экран (предположительно)
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        );
      },
    );
  }
}
