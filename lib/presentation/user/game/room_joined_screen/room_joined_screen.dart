import 'package:flutter/material.dart';
import 'package:pytl_backup/data/models/place_model/mock/place_model_mock.dart';
import 'package:pytl_backup/data/models/place_model/place_model.dart';
import 'package:pytl_backup/data/styles/colors.dart';
// NOTE: Assuming GameInProgressScreen is imported if needed, but for this screen,
// it's not strictly necessary unless the "Готов" button leads there.
// import 'package:pytl_backup/presentation/game_in_progres_screen/game_in_progres_screen.dart';

// Класс пользователя остается прежним
class _User {
  final String name;
  final String location;
  _User({required this.name, required this.location});
}

class RoomJoinedScreen extends StatefulWidget {
  final String roomCode;
  final String selectedPlace; // Предварительно выбранная достопримечательность

  const RoomJoinedScreen({
    super.key,
    this.roomCode = "452673918476",
    this.selectedPlace = "Несвижский замок",
  });

  @override
  State<RoomJoinedScreen> createState() => _RoomJoinedScreenState();
}

class _RoomJoinedScreenState extends State<RoomJoinedScreen> {
  PlaceModel? recommendedPlace;

  // Пример списка участников (можно сделать его частью widget, если он динамический)
  final List<_User> users = [
    _User(name: "Никита", location: "г. Минск"),
    _User(name: "Владислав", location: "село Овсянкино"),
    _User(name: "Максим", location: "г. Москва"),
    _User(name: "ВЫ", location: "г. Минск"), // Добавлен вошедший пользователь
  ];

  @override
  void initState() {
    super.initState();
    _generateRecommended();
  }

  void _generateRecommended() {
    // Логика может отличаться, но для примера оставляем генерацию
    if (placesMock.isNotEmpty) {
      final shuffledList = List<PlaceModel>.from(placesMock)..shuffle();
      recommendedPlace = shuffledList.first;
    } else {
      recommendedPlace = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              _buildRoomCodeSection(), // Мой код -> Код комнаты

              const SizedBox(height: 30),
              // НОВЫЙ БЛОК: Отображение выбранного места
              _buildSelectedPlaceSection(),

              const SizedBox(height: 20),
              _buildRecommendedSection(),

              const SizedBox(height: 20),
              // Обновленный блок: Участники без крестиков
              _buildUsersSection(),

              const SizedBox(height: 30),
              // Обновленный блок: Кнопки "Готов" и "Выйти"
              _buildActionButtons(primaryRed),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- БЛОКИ UI ---

  /// Блок "Код комнаты"
  Widget _buildRoomCodeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _boxStyle(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Код комнаты:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          Text(
            widget.roomCode,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  /// Блок "Выбранная достопримечательность" (ВМЕСТО выпадающего списка)
  Widget _buildSelectedPlaceSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _boxStyle(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Выбранная достопримечательность:",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.selectedPlace,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 5), // Уменьшенный отступ
          const Text(
            "Ожидаем подтверждения от создателя комнаты.",
            style: TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  /// Блок "Рекомендованная" (Без изменений)
  Widget _buildRecommendedSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _boxStyle(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Рекомендованная достопримечательность",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Text(
            recommendedPlace?.label ?? "—",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  /// Блок "Участники" (УБРАНЫ КРЕСТИКИ)
  Widget _buildUsersSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _boxStyle(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Участники",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...users.map(
            (u) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start, // Изменено
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          u.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          u.location,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    // !!! КРЕСТИК УДАЛЕН !!!
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Блок с кнопками "Готов" и "Выйти"
  Widget _buildActionButtons(Color primaryRed) {
    return Column(
      children: [
        GestureDetector(
          // Кнопка "ГОТОВ"
          onTap: () {
            // TODO: Логика "Я готов". В этом примере просто закрываем экран.
            Navigator.of(context).pop();
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: primaryRed,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                "Готов", // ИЗМЕНЕНО
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        GestureDetector(
          // Кнопка "Выйти" (Логика диалога сохранена)
          onTap: () {
            _showExitConfirmationDialog(context, primaryRed);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: Colors.grey.shade600,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                "Выйти",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Стиль для контейнеров (Без изменений)
  BoxDecoration _boxStyle() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Диалог подтверждения выхода (Без изменений)
  void _showExitConfirmationDialog(BuildContext context, Color primaryRed) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Подтверждение"),
          content: const Text("Вы действительно желаете покинуть комнату?"),
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
              child: Text("Выйти", style: TextStyle(color: primaryRed)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
