import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// ⚠️ Обновите пути к вашим моделям и сервисам
import 'package:pytl_backup/data/models/place_model/place_model.dart';
import 'package:pytl_backup/data/styles/colors.dart';
import 'package:pytl_backup/domain/services/image_service.dart';
import 'package:pytl_backup/domain/services/place_service.dart';

typedef OnPlaceSaved = void Function(PlaceModel place);
typedef OnPlaceDeleted = void Function(int placeId); // Новый callback

class EditPlaceScreen extends StatefulWidget {
  final PlaceModel? place;
  final OnPlaceSaved onPlaceSaved;
  final OnPlaceDeleted? onPlaceDeleted; // Добавлен для удаления

  const EditPlaceScreen({
    super.key,
    this.place,
    required this.onPlaceSaved,
    this.onPlaceDeleted, // Добавлен в конструктор
  });

  @override
  State<EditPlaceScreen> createState() => _EditPlaceScreenState();
}

class _EditPlaceScreenState extends State<EditPlaceScreen> {
  final _formKey = GlobalKey<FormState>();
  final PlaceService _placeService = PlaceService();

  late PlaceModel _currentPlace;
  bool _isNewPlace = false;
  bool _isSaving = false;
  bool _isDeleting = false;

  String? _base64Image;

  late TextEditingController _labelController;
  late TextEditingController _addressController;
  late TextEditingController _aboutController;
  late TextEditingController _typeNameController;
  late TextEditingController _oXController; // 📍 Новый контроллер
  late TextEditingController _oYController; // 📍 Новый контроллер

  @override
  void initState() {
    super.initState();
    _isNewPlace = widget.place == null;

    _currentPlace =
        widget.place ??
        const PlaceModel(
          id: 0,
          label: '',
          address: '',
          imageBit: null,
          oX: 0.0, // 📍 Инициализация
          oY: 0.0, // 📍 Инициализация
          about: '',
          typeName: '',
          idAR: null,
          idComments: null,
        );

    _base64Image = _currentPlace.imageBit;

    _labelController = TextEditingController(text: _currentPlace.label);
    _addressController = TextEditingController(text: _currentPlace.address);
    _aboutController = TextEditingController(text: _currentPlace.about);
    _typeNameController = TextEditingController(text: _currentPlace.typeName);
    // 📍 Инициализация контроллеров координат
    _oXController = TextEditingController(text: _currentPlace.oX.toString());
    _oYController = TextEditingController(text: _currentPlace.oY.toString());
  }

  @override
  void dispose() {
    _labelController.dispose();
    _addressController.dispose();
    _aboutController.dispose();
    _typeNameController.dispose();
    _oXController.dispose();
    _oYController.dispose();
    _placeService.dispose();
    super.dispose();
  }

  // --- 📸 Метод выбора изображения ---
  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result == null) return;

    final bytes = result.files.first.bytes;
    String newBase64Image;

    try {
      if (bytes != null) {
        newBase64Image = base64Encode(bytes);
      } else {
        // Запасной вариант для Windows/Linux/macOS, если bytes == null
        final file = File(result.files.first.path!);
        final fileBytes = await file.readAsBytes();
        newBase64Image = base64Encode(fileBytes);
      }

      setState(() {
        _base64Image = newBase64Image;
      });
    } catch (e) {
      log('Ошибка при обработке изображения: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при загрузке файла: ${e.toString()}')),
      );
    }
  }

  // --- 💾 Логика сохранения ---
  Future<void> _savePlace() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    // 1. Конвертируем координаты из текста в double
    final double oX = double.tryParse(_oXController.text) ?? 0.0;
    final double oY = double.tryParse(_oYController.text) ?? 0.0;

    // 2. Создаем обновленную модель
    final updatedPlace = _currentPlace.copyWith(
      label: _labelController.text,
      address: _addressController.text,
      about: _aboutController.text,
      typeName: _typeNameController.text,
      imageBit: _base64Image,
      oX: oX, // 📍 Сохранение координат
      oY: oY, // 📍 Сохранение координат
    );

    try {
      PlaceModel savedPlace;
      if (_isNewPlace) {
        savedPlace = await _placeService.createPlace(updatedPlace);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Место успешно добавлено!')),
        );
      } else {
        savedPlace = await _placeService.updatePlace(updatedPlace);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Изменения успешно сохранены!')),
        );
      }

      widget.onPlaceSaved(savedPlace);
      Navigator.of(context).pop();
    } catch (e) {
      log('Ошибка сохранения: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка сохранения: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  // --- 🗑️ Логика удаления ---
  Future<void> _deletePlace() async {
    if (_isNewPlace) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Подтверждение"),
          content: Text(
            "Вы уверены, что хотите удалить место \"${_currentPlace.label}\"?",
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Отмена"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Удалить"),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() {
        _isDeleting = true;
      });
      try {
        await _placeService.deletePlace(_currentPlace.id);
        widget.onPlaceDeleted?.call(_currentPlace.id);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Место успешно удалено!')));
        Navigator.of(context).pop();
      } catch (e) {
        log('Ошибка удаления: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка удаления: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  // --- UI Виджеты ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isNewPlace ? 'Добавить новое место' : 'Редактировать место',
        ),
        backgroundColor: primaryRed,
        foregroundColor: appWhite,
        actions: [
          if (!_isNewPlace) // Кнопка удаления только для существующих мест
            IconButton(
              onPressed: _isDeleting ? null : _deletePlace,
              icon: _isDeleting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: appWhite,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.delete),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildImagePicker(Base64ImageService(_base64Image ?? "")),
              const SizedBox(height: 16),

              // --- Поля для текста ---
              _buildTextField(
                controller: _labelController,
                labelText: 'Название места',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _addressController,
                labelText: 'Адрес',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _typeNameController,
                labelText: 'Тип места',
              ),
              const SizedBox(height: 16),

              // --- 📍 Поля для координат ---
              Row(
                children: [
                  Expanded(
                    child: _buildCoordinateField(
                      controller: _oXController,
                      labelText: 'Координата X',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildCoordinateField(
                      controller: _oYController,
                      labelText: 'Координата Y',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _aboutController,
                labelText: 'Описание',
                maxLines: 5,
              ),
              const SizedBox(height: 24),

              // --- Кнопка "Сохранить" (перенесена в тело) ---
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _savePlace,
                icon: const Icon(Icons.save),
                label: Text(_isNewPlace ? 'Создать' : 'Сохранить изменения'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: primaryRed,
                  foregroundColor: appWhite,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Виджет для выбора и отображения изображения ---
  Widget _buildImagePicker(Base64ImageService imageService) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: imageService.getImageWidget(
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.folder_open),
              label: Text(
                _base64Image == null
                    ? 'Выбрать изображение'
                    : 'Заменить изображение',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryRed,
                side: const BorderSide(color: primaryRed),
              ),
            ),
            if (_base64Image != null) ...[
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _base64Image = null;
                  });
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Удалить'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  // --- Вспомогательный виджет для текстовых полей ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    int maxLines = 1,
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        floatingLabelStyle: GoogleFonts.manrope(color: primaryRed),
        labelStyle: GoogleFonts.manrope(),
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: primaryRed),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: primaryRed, width: 2),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: primaryRed, width: 1),
        ),
        disabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: primaryRed, width: 1),
        ),
        alignLabelWithHint: true,
      ),
      validator: (value) {
        if (required && (value == null || value.isEmpty)) {
          return 'Поле $labelText не может быть пустым';
        }
        return null;
      },
    );
  }

  // --- Вспомогательный виджет для полей координат ---
  Widget _buildCoordinateField({
    required TextEditingController controller,
    required String labelText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        floatingLabelStyle: GoogleFonts.manrope(color: primaryRed),
        labelStyle: GoogleFonts.manrope(),
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: primaryRed),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: primaryRed, width: 2),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: primaryRed, width: 1),
        ),
        disabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: primaryRed, width: 1),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Введите значение';
        }
        if (double.tryParse(value) == null) {
          return 'Некорректное число';
        }
        return null;
      },
    );
  }
}
