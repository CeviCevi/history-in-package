import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pytl_backup/data/models/place_model/place_model.dart';
import 'package:pytl_backup/data/models/user_model/user_model.dart';
import 'package:pytl_backup/data/styles/colors.dart';
import 'package:pytl_backup/domain/services/image_service.dart';
import 'package:pytl_backup/domain/services/place_service.dart';
import 'package:pytl_backup/domain/services/user_service.dart';
import 'package:pytl_backup/presentation/detail_object_screen/detail_object_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavScreen extends StatefulWidget {
  const FavScreen({super.key});

  @override
  State<FavScreen> createState() => _FavScreenState();
}

class _FavScreenState extends State<FavScreen> {
  final UserService _userService = UserService();

  List<PlaceModel> _favPlaces = [];
  bool _isLoading = true;
  String _error = '';

  UserModel? _currentUser;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _loadFavoritePlaces();
  }

  // --- 1. Асинхронная загрузка избранных мест пользователя ---
  Future<void> _loadFavoritePlaces() async {
    //final placeService = context.read<PlaceService>();
    final PlaceService placeService = PlaceService();

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      _userEmail = prefs.getString('email');

      final emailToUse = _userEmail ?? "mock@model.com";

      if (emailToUse.isEmpty) {
        throw Exception('Пользователь не авторизован. Email не найден.');
      }

      final UserModel user = await _userService.getUserByEmail(emailToUse);
      _currentUser = user;

      if (user.idSavedPlaces == null || user.idSavedPlaces!.isEmpty) {
        setState(() {
          _favPlaces = [];
          _isLoading = false;
        });
        return;
      }

      final allPlaces = await placeService.getPlaces();

      final favoritePlaces = allPlaces.where((place) {
        return user.idSavedPlaces!.contains(place.id);
      }).toList();

      setState(() {
        _favPlaces = favoritePlaces;
        _isLoading = false;
      });
    } catch (e) {
      log('Ошибка загрузки избранного: $e');
      setState(() {
        _error =
            'Ошибка загрузки: ${e.toString().replaceFirst('Exception: ', '')}';
        _isLoading = false;
      });
    }
  }

  // --- 2. Локальный метод для обновления UI после удаления ---
  void _onRemoveFavorite(int placeId) {
    setState(() {
      _favPlaces.removeWhere((place) => place.id == placeId);
      _currentUser?.idSavedPlaces?.remove(placeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Stack(children: [_buildBody()]));
  }

  // --- 3. Виджеты состояний и списка ---

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: primaryRed),
            SizedBox(height: 16),
            Text('Загрузка избранного...'),
          ],
        ),
      );
    }

    if (_error.isNotEmpty) {
      return _buildErrorState();
    }

    if (_favPlaces.isEmpty) {
      return _buildEmptyState();
    }

    // --- Отображение списка избранного с Dismissible (Swipe to Delete) ---
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _favPlaces.length,
            itemBuilder: (context, index) {
              final place = _favPlaces[index];

              return Dismissible(
                key: ValueKey<int>(place.id),
                direction: DismissDirection.endToStart, // Свайп влево
                // Фон, который появляется при свайпе
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  decoration: BoxDecoration(
                    color: Colors.red[700],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: const Icon(Icons.delete, color: appWhite, size: 32),
                ),

                // Диалог подтверждения перед удалением
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Подтверждение удаления"),
                        content: Text(
                          "Вы уверены, что хотите удалить \"${place.label}\" из избранного?",
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text("Отмена"),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryRed,
                              foregroundColor: appWhite,
                            ),
                            child: const Text("Удалить"),
                          ),
                        ],
                      );
                    },
                  );
                },

                onDismissed: (direction) async {
                  final dismissedPlaceId = place.id;

                  setState(() {
                    _favPlaces.removeAt(index);
                  });

                  try {
                    if (_userEmail != null) {
                      await _userService.removeFromSavedPlaces(
                        _userEmail!,
                        dismissedPlaceId,
                      );
                    } else {
                      throw Exception("User email not found.");
                    }
                  } catch (e) {
                    log('Ошибка удаления: $e');
                    _loadFavoritePlaces();
                  }
                },

                child: _buildPlaceCard(place),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'В избранном пока ничего нет',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Добавляйте понравившиеся места в избранное',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadFavoritePlaces,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryRed,
              foregroundColor: appWhite,
            ),
            child: const Text('Обновить'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _error,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadFavoritePlaces,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryRed,
              foregroundColor: appWhite,
            ),
            child: const Text('Попробовать снова'),
          ),
        ],
      ),
    );
  }

  // --- 4. Карточка места (без кнопки удаления) ---
  Widget _buildPlaceCard(PlaceModel place) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SingleChildScrollView(
                child: DetailObjectScreen(
                  place: place,
                  back: true,
                  onFavoriteRemoved: _onRemoveFavorite,
                ),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Изображение места
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: place.imageBit != null
                      ? Image.memory(
                          Base64ImageService(place.imageBit!).getImageBytes()!,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 180,
                          width: double.infinity,
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.photo,
                            size: 50,
                            color: Colors.grey[400],
                          ),
                        ),
                ),

                // Бейдж типа места
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: primaryRed,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      place.typeName,
                      style: const TextStyle(
                        color: appWhite,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Информация о месте
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          place.address,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    place.about,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
