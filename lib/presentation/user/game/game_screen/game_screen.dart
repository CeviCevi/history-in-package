import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pytl_backup/data/styles/colors.dart';
import 'package:pytl_backup/presentation/existing_games_screen/existing_game_screen.dart';
import 'package:pytl_backup/presentation/room_joined_screen/room_joined_screen.dart';
import 'package:pytl_backup/presentation/start_game_screen/create_room.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //TODO
    final myCode = ("email").hashCode.toString().replaceAll("-", "");

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // ---------- TITLE ----------
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        "ГОНКА",
                        style: GoogleFonts.monteCarlo(
                          fontSize: 55,
                          fontWeight: FontWeight.w900,
                          color: primaryRed,
                          letterSpacing: 3,
                          wordSpacing: 0,
                          shadows: [
                            Shadow(
                              color: const Color.fromARGB(
                                255,
                                69,
                                38,
                                38,
                              ).withAlpha(75),
                              blurRadius: 5,
                              offset: Offset(6, 6),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      "во времени",
                      style: GoogleFonts.manrope(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: primaryRed,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            color: const Color.fromARGB(
                              255,
                              74,
                              26,
                              26,
                            ).withAlpha(75),
                            blurRadius: 3,
                            offset: Offset(6, 6),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // ---------- MY CODE CARD ----------
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Мой код:",
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      myCode,
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ---------- CREATE GAME BUTTON ----------
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateRoomScreen()),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Создать",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ---------- JOIN GAME BUTTON ----------
              GestureDetector(
                onTap: () => _showEnterCodeDialog(context, primaryRed),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Присоединиться",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ---------- EXISTING GAME BUTTON ----------
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExistingGamesScreen(),
                  ),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Проходящие игры",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showEnterCodeDialog(BuildContext context, Color primaryRed) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Введите код комнаты"),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "4729303...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
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
              child: Text("Войти", style: TextStyle(color: primaryRed)),
              onPressed: () {
                // 1. Получаем код
                final enteredCode = " ";

                if (enteredCode.isNotEmpty) {
                  // 2. Закрываем диалог
                  Navigator.of(dialogContext).pop();

                  // 3. Переходим на экран комнаты вошедшего пользователя
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RoomJoinedScreen(
                        roomCode: enteredCode,
                        // TODO: Достопримечательность должна быть получена с сервера по коду
                        selectedPlace: "Музей современного искусства",
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
