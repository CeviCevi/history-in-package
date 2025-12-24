// domain/services/user_service.dart

import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:pytl_backup/data/models/user_model/mock/user_model_mock.dart';
import 'package:pytl_backup/data/models/user_model/user_model.dart';

class UserService {
  static const String _baseUrl = 'http://localhost:8080/api/user';
  static const Duration _timeout = Duration(seconds: 30);

  final http.Client client;

  UserService({http.Client? client}) : client = client ?? http.Client();

  Future<UserModel> getUserByEmail(String email) async {
    try {
      final response = await client
          .get(Uri.parse('$_baseUrl/$email'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return UserModel.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Пользователь с email $email не найден.');
      } else {
        throw Exception('Ошибка загрузки пользователя: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка сети или таймаут: $e');
    }
  }

  Future<UserModel> updateUser(UserModel user) async {
    final String url = '$_baseUrl/${user.email}';

    try {
      final response = await client
          .put(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(user.toJson()),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return UserModel.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Обновление не удалось: пользователь не найден.');
      } else if (response.statusCode == 400) {
        throw Exception('Обновление не удалось: некорректные данные.');
      } else {
        throw Exception('Ошибка обновления: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка сети или таймаут: $e');
    }
  }

  Future<UserModel> registerUser(UserModel user) async {
    final Map<String, dynamic> requestBody = user.toJson();

    try {
      final response = await client
          .post(
            Uri.parse('$_baseUrl/register'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(requestBody),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return UserModel.fromJson(data);
      } else if (response.statusCode == 400) {
        throw Exception(
          'Регистрация не удалась: Пользователь с таким email уже существует.',
        );
      } else {
        throw Exception('Ошибка регистрации: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка сети или таймаут при регистрации: $e');
    }
  }

  Future<UserModel> authUser(String email, String password) async {
    final String url = '$_baseUrl/auth/$email/$password';

    try {
      final response = await client.post(Uri.parse(url)).timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return UserModel.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Ошибка входа: Неверный email или пароль.');
      } else if (response.statusCode == 404) {
        throw Exception('Ошибка входа: Пользователь не найден.');
      } else {
        throw Exception('Ошибка входа: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка сети или таймаут при входе: $e');
    }
  }

  // --- Операции, связанные с коллекциями (Saved Places) ---
  Future<void> addToSavedPlaces(String userEmail, int placeId) async {
    try {
      final response = await client
          .post(
            Uri.parse('$_baseUrl/saved-places/add'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'email': userEmail, 'place_id': placeId}),
          )
          .timeout(_timeout);

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          'Failed to add to saved places: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Ошибка сети или таймаут: $e');
    }
  }

  Future<void> removeFromSavedPlaces(String userEmail, int placeId) async {
    try {
      final response = await client
          .delete(
            Uri.parse('$_baseUrl/saved-places/delete'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'email': userEmail, 'place_id': placeId}),
          )
          .timeout(_timeout);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'Failed to remove from saved places: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Ошибка сети или таймаут: $e');
    }
  }

  void dispose() {
    client.close();
  }
}

Future<void> main(List<String> args) async {
  UserService service = UserService();
  log(service.authUser(userModelMock.email, userModelMock.password).toString());
}
