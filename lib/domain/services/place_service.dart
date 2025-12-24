// domain/services/place_service.dart

import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:pytl_backup/data/models/place_model/mock/place_model_mock.dart';
import 'package:pytl_backup/data/models/place_model/place_model.dart';

class PlaceService {
  static const String _baseUrl = 'http://localhost:8080/api/place';
  static const Duration _timeout = Duration(seconds: 30);

  final http.Client client;

  PlaceService({http.Client? client}) : client = client ?? http.Client();

  // --- 1. READ: Получение всех мест (GET /api/place/all) ---
  Future<List<PlaceModel>> getPlaces() async {
    try {
      final response = await client
          .get(Uri.parse('$_baseUrl/all'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => PlaceModel.fromJson(item)).toList();
      } else {
        throw Exception('Ошибка загрузки мест: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка сети: $e');
    }
  }

  // --- 2. READ: Получение места по ID (GET /api/place/{id}) ---
  Future<PlaceModel> getPlaceById(int id) async {
    try {
      final response = await client
          .get(Uri.parse('$_baseUrl/$id'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return PlaceModel.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Место с ID $id не найдено.');
      } else {
        throw Exception('Ошибка загрузки места: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка сети: $e');
    }
  }

  // --- 3. CREATE: Создание нового места (POST /api/place/add) ---
  Future<PlaceModel> createPlace(PlaceModel place) async {
    try {
      final response = await client
          .post(
            Uri.parse('$_baseUrl/add'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(place.toJson()),
          )
          .timeout(_timeout);

      if (response.statusCode == 201) {
        // 201 Created
        final Map<String, dynamic> data = json.decode(response.body);
        return PlaceModel.fromJson(data);
      } else if (response.statusCode == 400) {
        throw Exception('Ошибка создания: Некорректные данные.');
      } else {
        throw Exception('Ошибка создания места: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка сети: $e');
    }
  }

  // --- 4. UPDATE: Обновление места (PUT /api/place/{id}) ---
  Future<PlaceModel> updatePlace(PlaceModel place) async {
    // В Dart-модели ID — int. В Spring-контроллере — Long. Передаем как int.
    final String url = '$_baseUrl/${place.id}';

    try {
      final response = await client
          .put(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(place.toJson()),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return PlaceModel.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception(
          'Обновление не удалось: Место с ID ${place.id} не найдено.',
        );
      } else {
        throw Exception('Ошибка обновления места: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка сети: $e');
    }
  }

  // --- 5. DELETE: Удаление места (DELETE /api/place/{id}) ---
  Future<void> deletePlace(int id) async {
    try {
      final response = await client
          .delete(Uri.parse('$_baseUrl/$id'))
          .timeout(_timeout);

      if (response.statusCode == 204) {
        // 204 No Content
        return;
      } else if (response.statusCode == 404) {
        throw Exception('Удаление не удалось: Место с ID $id не найдено.');
      } else {
        throw Exception('Ошибка удаления места: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка сети: $e');
    }
  }

  // --- Поиск ---
  Future<List<PlaceModel>> searchPlaces(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    final String url = '$_baseUrl/search?q=$encodedQuery';

    try {
      final response = await client.get(Uri.parse(url)).timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => PlaceModel.fromJson(item)).toList();
      } else {
        throw Exception('Ошибка поиска мест: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка сети: $e');
    }
  }

  void dispose() {
    client.close();
  }
}

Future<void> main() async {
  PlaceService service = PlaceService();

  log(service.createPlace(placesMock[6]).toString());
}
