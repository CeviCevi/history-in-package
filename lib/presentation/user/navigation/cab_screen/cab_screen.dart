import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pytl_backup/data/models/place_model/place_model.dart';
import 'package:pytl_backup/data/models/user_model/user_model.dart';
import 'package:pytl_backup/data/styles/colors.dart';
import 'package:pytl_backup/domain/repository/user_repository.dart';
import 'package:pytl_backup/domain/services/cache_service.dart';
import 'package:pytl_backup/presentation/app/start_screen/start_screen.dart';
import 'package:pytl_backup/presentation/user/game/game_screen/game_screen.dart';
import 'package:pytl_backup/presentation/user/navigation/cab_screen/widgets/add_place_screen/add_place_screen.dart';
import 'package:pytl_backup/presentation/user/user_edit_screen/user_edit_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersonalCabinetScreen extends StatefulWidget {
  const PersonalCabinetScreen({super.key});

  @override
  State<PersonalCabinetScreen> createState() => _PersonalCabinetScreenState();
}

class _PersonalCabinetScreenState extends State<PersonalCabinetScreen> {
  // --- Единственный источник данных для UI ---
  UserModel? _user;

  // --- Управление состоянием загрузки ---
  bool _isLoading = true;
  String? _error;

  final UserRepository userService = UserRepository();

  @override
  void initState() {
    super.initState();
    _refreshUserData();
  }

  Future<void> _refreshUserData() async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final prefs = CacheService.instance;
      final email = prefs.getString('email');

      if (email == null || email.isEmpty) {
        throw Exception("Пользователь не авторизован. Email не найден.");
      }

      final user = await userService.getUserByEmail(email);

      await prefs.setString('login', user!.login);
      if (user.imageBit != null) {
        await prefs.setString('image', user.imageBit!);
      } else {
        await prefs.remove('image');
      }

      setState(() {
        _user = user;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      log(e.toString());
      setState(() {
        _error = e.toString().replaceFirst("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToEdit() async {
    if (_user == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserEditScreen(user: _user!)),
    );

    _refreshUserData();
  }

  Future<void> _unsing() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const StartScreen(),
          transitionDuration: Duration.zero,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return child;
          },
        ),
      );
    }
  }

  //^!  UI

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.grey.shade200, body: _buildBody());
  }

  Widget _buildBody() {
    // --- 1. Состояние Загрузки ---
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: primaryRed));
    }

    // --- 2. Состояние Ошибки ---
    if (_error != null && _user == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Ошибка загрузки профиля:", style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red[800]),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _refreshUserData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryRed,
                  foregroundColor: appWhite,
                ),
                child: Text("Попробовать снова"),
              ),
            ],
          ),
        ),
      );
    }

    if (_user == null) {
      return Center(child: Text("Не удалось загрузить пользователя."));
    }

    // --- 4. ОСНОВНОЙ UI ---
    final String? image = _user!.imageBit;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 70),
          // --- АВАТАР + ИНФО ---
          Row(
            children: [
              GestureDetector(
                onTap: _refreshUserData,
                child: CircleAvatar(
                  radius: 34,
                  backgroundColor: Colors.grey.shade400,
                  backgroundImage: image != null
                      ? MemoryImage(base64Decode(image))
                      : null,
                  child: image == null
                      ? const Icon(Icons.person, size: 38, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _user!.login,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _user!.email,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 40),

          /// --- КНОПКИ ---
          _settingsButton(
            title: "Изменить данные аккаунта",
            onTap: _navigateToEdit,
          ),
          const SizedBox(height: 12),

          _settingsButton(title: "Моя активность", onTap: () {}),
          const SizedBox(height: 12),

          _settingsButton(
            title: "Предложить новый объект",
            onTap: () async {
              await showModalBottomSheet<PlaceModel>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => AddPlaceModal(user: _user!),
              );
            },
          ),

          const SizedBox(height: 20),
          const SizedBox(height: 20),

          /// --- БЛОК «Статистика» ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: appWhite,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((255 * 0.05).toInt()),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Статистика",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),

                _infoRow(
                  title: "Мест посещено:",
                  value: "${_user!.idVisitedPlaces?.length ?? 0}",
                ),
                _infoRow(
                  title: "Добрался первым:",
                  value: "${_user!.idWins?.length ?? 0}",
                ),
                _infoRow(
                  title: "Сохранено:",
                  value: "${_user!.idSavedPlaces?.length ?? 0}",
                ),

                const SizedBox(height: 12),

                _accentButton(
                  title: "Играть",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GameScreen()),
                  ),
                  color: primaryRed,
                  textColor: appWhite,
                ),
              ],
            ),
          ),

          SizedBox(height: 40),

          // --- Кнопка выхода ---
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: _unsing,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((255 * 0.05).toInt()),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text("Выйти из аккаунта"),
                    const Icon(Icons.logout_outlined, size: 16),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 40),
        ],
      ),
    );
  }

  /// --- СТРОКА СТАТИСТИКИ ---
  Widget _infoRow({required String title, required String value}) {
    // ... (без изменений)
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  /// --- КНОПКА НАСТРОЕК ---
  Widget _settingsButton({required String title, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((255 * 0.05).toInt()),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  // --- красная кнопка ---
  Widget _accentButton({
    required String title,
    required VoidCallback onTap,
    required Color color,
    Color textColor = Colors.black,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.transparent,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((255 * 0.08).toInt()),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: textColor),
            ],
          ),
        ),
      ),
    );
  }
}
