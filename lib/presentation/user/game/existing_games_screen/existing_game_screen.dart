import 'package:flutter/material.dart';
import 'package:pytl_backup/presentation/game_in_progres_screen/game_in_progres_screen.dart';
// Предполагаем, что GameInProgressScreen импортирован
// import 'package:pytl_backup/presentation/game_in_progres_screen/game_in_progres_screen.dart';

class ExistingGamesScreen extends StatelessWidget {
  const ExistingGamesScreen({super.key});

  static const Color primaryRed = Color(0xFFE53935);

  // Макетный список активных игр
  final List<Map<String, String>> activeGames = const [
    {"code": "123456", "destination": "Белая Вежа"},
    {"code": "789012", "destination": "Верхний Город - г.Минск"},
    {"code": "345678", "destination": "Площадь Победы - г.Минск"},
    {"code": "901234", "destination": "Мемориал Пушкину - г.Минск"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: const Text("Активные игры"),
        backgroundColor: Colors.white,
        elevation: 1.0,
      ),
      body: activeGames.isEmpty
          ? Center(
              child: Text(
                "Активных игр пока нет.",
                style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: activeGames.length,
              itemBuilder: (context, index) {
                final game = activeGames[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _RoomCard(
                    code: game["code"]!,
                    destination: game["destination"]!,
                    onTap: () {
                      // При нажатии переходим на экран игры в процессе
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GameInProgressScreen(
                            // NOTE: Данные для GameInProgressScreen должны быть переданы
                            // Например, gameId: game["code"]!, destination: game["destination"]!
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

/// Отдельный виджет для отображения информации об одной комнате
class _RoomCard extends StatelessWidget {
  final String code;
  final String destination;
  final VoidCallback onTap;

  const _RoomCard({
    required this.code,
    required this.destination,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Код комнаты
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Код комнаты:",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE53935), // Красный цвет
                  ),
                ),
                Text(
                  code,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE53935),
                  ),
                ),
              ],
            ),
            const Divider(height: 20, thickness: 0.5),
            // Куда нужно добраться
            const Text(
              "Пункт назначения:",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              destination,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
