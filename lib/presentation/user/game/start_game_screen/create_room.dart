import 'package:flutter/material.dart';
import 'package:pytl_backup/data/models/place_model/mock/place_model_mock.dart';
import 'package:pytl_backup/data/models/place_model/place_model.dart';
import 'package:pytl_backup/presentation/user/game/game_in_progres_screen/game_in_progres_screen.dart';
// import 'package:pytl_backup/data/styles/colors.dart'; // <-- Больше не нужно, определяем цвет ниже

// 1. Создаем приватный класс для пользователя
class _User {
  final String name;
  final String location;
  _User({required this.name, required this.location});
}

class CreateRoomScreen extends StatefulWidget {
  final String myCode;

  const CreateRoomScreen({super.key, this.myCode = "452673918476"});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  bool randomPlace = false;
  String? selectedPlace;
  PlaceModel? recommendedPlace;
  List<String> placeLabels = [];

  // 2. Используем новый класс _User
  final List<_User> users = [
    _User(name: "Никита", location: "г. Минск"),
    _User(name: "Владислав", location: "село Овсянкино"),
    _User(name: "Максим", location: "г. Москва"),
  ];

  @override
  void initState() {
    super.initState();
    _generateRecommended();
    placeLabels = placesMock.map((element) => element.label).toList();
  }

  void _generateRecommended() {
    if (placesMock.isNotEmpty) {
      final shuffledList = List<PlaceModel>.from(placesMock)..shuffle();
      recommendedPlace = shuffledList.first;
    } else {
      recommendedPlace = null;
    }
  }

  // 3. Метод build теперь чистый и читаемый
  @override
  Widget build(BuildContext context) {
    // Определяем цвет здесь для всего виджета
    const Color primaryRed = Color(0xFFE53935);

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // Каждый блок вынесен в свой метод
              _buildMyCodeSection(),

              const SizedBox(height: 30),
              _buildPlaceSelectionSection(primaryRed),

              const SizedBox(height: 20),
              _buildRecommendedSection(),

              const SizedBox(height: 20),
              _buildUsersSection(),

              const SizedBox(height: 30),
              _buildActionButtons(primaryRed),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- 4. ВСЕ БЛОКИ UI ТЕПЕРЬ ОТДЕЛЬНЫЕ ФУНКЦИИ ---

  /// Блок "Мой код"
  Widget _buildMyCodeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _boxStyle(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Мой код:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          Text(
            widget.myCode,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  /// Блок "Выбор достопримечательности"
  Widget _buildPlaceSelectionSection(Color primaryRed) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _boxStyle(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Выберите достопримечательность",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            // 5. Исправлено на 'value'
            initialValue: randomPlace ? null : selectedPlace,
            items: placeLabels
                .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                .toList(),
            onChanged: randomPlace
                ? null
                : (value) => setState(() {
                    selectedPlace = value;
                  }),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Случайная",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Switch(
                value: randomPlace,
                activeThumbColor: primaryRed,
                onChanged: (v) {
                  setState(() {
                    randomPlace = v;
                    if (v) selectedPlace = null;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Блок "Рекомендованная"
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

  /// Блок "Участники"
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
          // 6. Используем класс _User
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          u.name, // <-- Чисто и безопасно
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          u.location, // <-- Чисто и безопасно
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          users.remove(u);
                        });
                      },
                      child: const Icon(Icons.close, size: 20),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Блок с кнопками "Начать" и "Выйти"
  Widget _buildActionButtons(Color primaryRed) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GameInProgressScreen()),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: primaryRed, // Используем цвет
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
                "Начать",
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
          onTap: () {
            _showExitConfirmationDialog(context, primaryRed); // Передаем цвет
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

  /// Стиль для контейнеров
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

  /// Диалог подтверждения выхода
  void _showExitConfirmationDialog(BuildContext context, Color primaryRed) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Подтверждение"),
          content: const Text("Вы действительно желаете закрыть комнату?"),
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
                "Выйти",
                style: TextStyle(color: primaryRed), // Используем цвет
              ),
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
