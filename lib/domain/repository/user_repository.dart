// domain/services/user_service.dart

import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:pytl_backup/data/models/user_model/mock/user_model_mock.dart';
import 'package:pytl_backup/data/models/user_model/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserRepository {
  static const String _baseUrl = 'http://localhost:8080/api/user';
  static const Duration _timeout = Duration(seconds: 30);
  final SupabaseClient _supa = Supabase.instance.client;

  final http.Client client;

  UserRepository({http.Client? client}) : client = client ?? http.Client();

  Future<UserModel?> getUserByEmail(String email) async {
    final response = await _supa
        .from('users')
        .select()
        .eq('email', email)
        .maybeSingle();

    return response == null ? null : UserModel.fromJson(response);
  }

  Future<UserModel?> getUserById(double id) async {
    final response = await _supa
        .from('users')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;

    return UserModel.fromJson(response);
  }

  Future<UserModel?> addUser(
    String login,
    String email,
    String password,
  ) async {
    final data = await _supa
        .from('users')
        .insert({'login': login, 'email': email, 'password': password})
        .select()
        .single();

    return data.isNotEmpty ? UserModel.fromJson(data) : null;
  }

  Future<UserModel?> updateUser(UserModel user) async {
    final data = await _supa
        .from('users')
        .update({
          'login': user.login,
          'email': user.email,
          'password': user.password,
          'image_bit': user.imageBit,
          'id_saved_places': user.idSavedPlaces,
          'id_wins': user.idWins,
          'id_visited_places': user.idVisitedPlaces,
          'id_my_comments': user.idMyComments,
          'id_my_object': user.idMyObject,
          'role': user.role,
        })
        .eq('id', user.id)
        .select()
        .maybeSingle();

    if (data == null) return null;
    return UserModel.fromJson(data);
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
  UserRepository service = UserRepository();
  log(service.authUser(userModelMock.email, userModelMock.password).toString());
}
