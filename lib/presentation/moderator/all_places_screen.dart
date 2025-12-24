import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pytl_backup/data/models/place_model/place_model.dart';
import 'package:pytl_backup/data/styles/colors.dart';
import 'package:pytl_backup/domain/services/image_service.dart';
import 'package:pytl_backup/domain/services/place_service.dart';
import 'package:pytl_backup/presentation/moderator/edit_place_screen.dart';
import 'package:pytl_backup/presentation/start_screen/start_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllPlacesScreen extends StatefulWidget {
  const AllPlacesScreen({super.key});

  @override
  State<AllPlacesScreen> createState() => _AllPlacesScreenState();
}

class _AllPlacesScreenState extends State<AllPlacesScreen> {
  final PlaceService _placeService = PlaceService();

  List<PlaceModel> _allPlaces = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadAllPlaces();
  }

  @override
  void dispose() {
    _placeService.dispose();
    super.dispose();
  }

  // --- 1. Логика загрузки данных ---
  Future<void> _loadAllPlaces() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final allPlaces = await _placeService.getPlaces();

      setState(() {
        _allPlaces = allPlaces;
        _isLoading = false;
      });
    } catch (e) {
      log('Ошибка загрузки всех мест: $e');
      setState(() {
        _error =
            'Ошибка загрузки: ${e.toString().replaceFirst('Exception: ', '')}';
        _isLoading = false;
      });
    }
  }

  // --- 2. Обработчик успешного сохранения/редактирования места ---
  void _handlePlaceSaved(PlaceModel savedPlace) {
    _loadAllPlaces();
  }

  // --- 3. Открытие экрана редактирования/создания ---
  void _openEditScreen({PlaceModel? place}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            EditPlaceScreen(place: place, onPlaceSaved: _handlePlaceSaved),
      ),
    );
  }

  Future<void> _backToStart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => StartScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Все достопримечательности'),
        backgroundColor: Colors.white,
        elevation: 1.0,
        actionsIconTheme: IconThemeData(color: primaryRed, size: 25),
        actionsPadding: EdgeInsets.only(right: 5),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadAllPlaces,
          ),
          IconButton(
            onPressed: _backToStart,
            icon: Icon(Icons.exit_to_app_outlined),
          ),
        ],
      ),
      body: _buildBody(),

      // Кнопка "+" для создания нового места
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditScreen(place: null), // Открываем для создания
        backgroundColor: primaryRed,
        foregroundColor: appWhite,
        child: const Icon(Icons.add),
      ),
    );
  }

  // --- 4. Виджеты состояний и списка ---

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: primaryRed),
            SizedBox(height: 16),
            Text('Загрузка достопримечательностей...'),
          ],
        ),
      );
    }

    if (_error.isNotEmpty) {
      return _buildErrorState();
    }

    if (_allPlaces.isEmpty) {
      return _buildEmptyState();
    }

    // --- Отображение общего списка ---
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _allPlaces.length,
            itemBuilder: (context, index) {
              final place = _allPlaces[index];
              return _buildPlaceCard(place);
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
          Icon(Icons.location_city, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Список мест пуст',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Нажмите "+" для создания нового места.',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadAllPlaces,
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
            onPressed: _loadAllPlaces,
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

  // --- 5. Карточка места с кнопкой редактирования ---
  Widget _buildPlaceCard(PlaceModel place) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Открываем экран редактирования при нажатии
          _openEditScreen(place: place);
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Изображение и кнопки
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

                // Кнопка "Редактировать"
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _openEditScreen(place: place),
                    child: const CircleAvatar(
                      radius: 18,
                      backgroundColor: appWhite,
                      child: Icon(Icons.edit, color: primaryRed, size: 20),
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
