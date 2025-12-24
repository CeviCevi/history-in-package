import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pytl_backup/data/models/place_model/place_model.dart';
import 'package:pytl_backup/data/models/user_model/user_model.dart'; // Предполагаем наличие UserModel
import 'package:pytl_backup/data/styles/colors.dart';
import 'package:pytl_backup/domain/repository/user_repository.dart'; // Добавлен UserService
import 'package:pytl_backup/domain/services/image_service.dart';
import 'package:pytl_backup/presentation/user/comments_screen/comments_screen.dart';
import 'package:pytl_backup/presentation/user/object/object_screen/widgets/actions_menu.dart';
import 'package:pytl_backup/presentation/user/object/object_screen/widgets/comments_button.dart';
import 'package:pytl_backup/presentation/user/object/object_screen/widgets/expandable_facts_menu.dart';
import 'package:pytl_backup/presentation/user/object/object_screen/widgets/object_label_text.dart';
import 'package:pytl_backup/presentation/widgets/castle_text_field/style/shadow_style.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef OnFavoriteRemoved = void Function(int placeId);
// TODO <- решение не совсекм правильное. так делать не надо

class DetailObjectScreen extends StatefulWidget {
  final OnFavoriteRemoved? onFavoriteRemoved; // Новый параметр

  const DetailObjectScreen({
    super.key,
    required this.place,
    this.back = false,
    this.onFavoriteRemoved, // Добавлен в конструктор
  });

  final PlaceModel place;
  final bool back;

  @override
  State<DetailObjectScreen> createState() => _DetailObjectScreenState();
}

class _DetailObjectScreenState extends State<DetailObjectScreen> {
  final UserRepository _userService = UserRepository();

  // Состояние загрузки данных пользователя
  bool _isLoading = true;
  // Состояние, показывающее, сохранено ли текущее место
  bool _isSaved = false;
  // Модель пользователя
  UserModel? _userModel;
  // Email пользователя для API-запросов
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // --- 1. Асинхронная загрузка данных пользователя и статуса избранного ---
  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString("email");

      _userEmail = email ?? "mock@model.com";
      //_userEmail = "mock@model.com";

      // 2. Получаем данные пользователя с бэкенда по email
      final user = await _userService.getUserByEmail(_userEmail!);

      setState(() {
        _userModel = user;
        // 3. Проверяем, сохранено ли место
        _isSaved = user?.idSavedPlaces!.contains(widget.place.id) ?? false;
        _isLoading = false;
      });
    } catch (e) {
      // Обработка ошибок сети или парсинга
      log("Ошибка загрузки данных пользователя: $e");
      setState(() {
        _isLoading = false;
        _isSaved = false;
      });
    }
  }

  // --- 4. Логика сохранения/удаления избранного ---
  void _onSavePressed() async {
    if (_userEmail == null || _userModel == null) {
      // Возможно, нужно показать диалог с просьбой авторизоваться
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Для сохранения войдите в систему.')),
      );
      return;
    } else {
      // Удалить из избранного
      await _userService.removeFromSavedPlaces(_userEmail!, widget.place.id);

      // Обновляем локальную модель после успеха
      _userModel!.idSavedPlaces?.remove(widget.place.id);

      // --- Вызов callback для уведомления FavScreen ---
      if (widget.onFavoriteRemoved != null) {
        widget.onFavoriteRemoved!(widget.place.id);
      }
    }

    try {
      setState(() {
        _isSaved = !_isSaved; // Оптимистичное обновление UI
      });

      if (_isSaved) {
        // Добавить в избранное
        await _userService.addToSavedPlaces(_userEmail!, widget.place.id);
      } else {
        // Удалить из избранного
        await _userService.removeFromSavedPlaces(_userEmail!, widget.place.id);
      }
    } catch (e) {
      // Если API-запрос не удался, откатываем UI
      setState(() {
        _isSaved = !_isSaved;
      });
    }
  }

  // ^! - UI -
  @override
  Widget build(BuildContext context) {
    Base64ImageService imageService = Base64ImageService(
      widget.place.imageBit ?? "",
    );

    // Пока загружаем данные, показываем индикатор загрузки, чтобы избежать ошибок
    if (_isLoading) {
      return const Material(child: Center(child: CircularProgressIndicator()));
    }

    return Material(
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              color: bgcolor.withAlpha(255),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
            ),
          ),
          Column(
            children: [
              Stack(
                children: [
                  imageService.getImageWidget(
                    height: 300,
                    width: MediaQuery.of(context).size.width,
                  ),
                  Positioned(
                    top: 220,
                    child: ObjectLabelText(
                      label: widget.place.label,
                      address: widget.place.address,
                    ),
                  ),
                  widget.back
                      ? Positioned(
                          top: 20,
                          left: 0,
                          child: Container(
                            margin: const EdgeInsets.only(left: 20),
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: appWhite,
                              boxShadow: [textFieldShadow],
                            ),
                            child: InkWell(
                              onTap: () => Navigator.pop(context),
                              child: Icon(
                                Icons.arrow_back_outlined,
                                color: primaryRed,
                              ),
                            ),
                          ),
                        )
                      : const Center(),
                ],
              ),

              // --- Обновленный ActionsMenu с логикой избранного ---
              ActionsMenu(
                onQuizPressed: () {},
                onRoutePressed: () {},
                onSavePressed: _onSavePressed,
                isSaved: _isSaved,
                onSharePressed: () {},
              ),

              ExpandableFactsMenu(factsText: widget.place.about),

              CommentsButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CommentsScreen(
                      objectId: widget.place.id,
                      email: _userEmail!,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height),
        ],
      ),
    );
  }
}
