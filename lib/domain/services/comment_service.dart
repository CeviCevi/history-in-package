// lib/domain/services/comment_service.dart

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pytl_backup/data/models/comment_model.dart';

class CommentService {
  static const String _baseUrl = 'http://localhost:8080/api/comments';
  static const Duration _timeout = Duration(seconds: 30);
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  final http.Client client;

  CommentService({http.Client? client}) : client = client ?? http.Client();

  // --- Вспомогательные методы для обработки ответов ---

  List<CommentModel> _parseCommentList(http.Response response) {
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => CommentModel.fromJson(json)).toList();
    } else {
      throw Exception(
        'Ошибка загрузки комментариев: ${response.statusCode}. Тело: ${response.body}',
      );
    }
  }

  CommentModel _parseSingleComment(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = json.decode(response.body);
      return CommentModel.fromJson(data);
    } else if (response.statusCode == 404) {
      throw Exception('Комментарий не найден.');
    } else if (response.statusCode == 400) {
      throw Exception('Некорректные данные запроса: ${response.body}');
    } else {
      throw Exception(
        'Ошибка сервера: ${response.statusCode}. Тело: ${response.body}',
      );
    }
  }

  // --- CRUD Операции ---

  Future<List<CommentModel>> getAllComments() async {
    try {
      final response = await client.get(Uri.parse(_baseUrl)).timeout(_timeout);
      return _parseCommentList(response);
    } catch (e) {
      throw Exception('Ошибка сети при получении всех комментариев: $e');
    }
  }

  Future<CommentModel> getCommentById(int id) async {
    try {
      final response = await client
          .get(Uri.parse('$_baseUrl/$id'))
          .timeout(_timeout);
      return _parseSingleComment(response);
    } catch (e) {
      throw Exception('Ошибка сети при получении комментария с ID $id: $e');
    }
  }

  Future<CommentModel> createComment(CommentModel comment) async {
    try {
      final response = await client
          .post(
            Uri.parse(_baseUrl),
            headers: _headers,
            body: json.encode(comment.toJson()),
          )
          .timeout(_timeout);
      return _parseSingleComment(response);
    } catch (e) {
      throw Exception('Ошибка сети при создании комментария: $e');
    }
  }

  Future<CommentModel> updateComment(CommentModel comment) async {
    try {
      final response = await client
          .put(
            Uri.parse('$_baseUrl/${comment.id}'),
            headers: _headers,
            body: json.encode(comment.toJson()),
          )
          .timeout(_timeout);
      return _parseSingleComment(response);
    } catch (e) {
      throw Exception(
        'Ошибка сети при обновлении комментария с ID ${comment.id}: $e',
      );
    }
  }

  Future<void> deleteComment(int id) async {
    try {
      final response = await client
          .delete(Uri.parse('$_baseUrl/$id'))
          .timeout(_timeout);

      if (response.statusCode == 204) {
        return;
      } else if (response.statusCode == 404) {
        throw Exception('Удаление не удалось: Комментарий с ID $id не найден.');
      } else {
        throw Exception(
          'Ошибка удаления: ${response.statusCode}. Тело: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Ошибка сети при удалении комментария с ID $id: $e');
    }
  }

  // --- Методы поиска ---

  Future<List<CommentModel>> getCommentsByObjectId(int objectId) async {
    try {
      final response = await client
          .get(Uri.parse('$_baseUrl/by-object/$objectId'))
          .timeout(_timeout);
      return _parseCommentList(response);
    } catch (e) {
      throw Exception(
        'Ошибка сети при поиске комментариев по ID объекта $objectId: $e',
      );
    }
  }

  Future<List<CommentModel>> getCommentsByCreatorEmail(int creatorEmail) async {
    try {
      final response = await client
          .get(Uri.parse('$_baseUrl/by-creator/$creatorEmail'))
          .timeout(_timeout);
      return _parseCommentList(response);
    } catch (e) {
      throw Exception(
        'Ошибка сети при поиске комментариев по ID создателя $creatorEmail: $e',
      );
    }
  }

  Future<List<CommentModel>> getCommentsByObjectAndCreator({
    required int objectId,
    required int creatorEmail,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/by-object-and-creator').replace(
        queryParameters: {
          'objectId': objectId.toString(),
          'creatorEmail': creatorEmail.toString(),
        },
      );
      final response = await client.get(uri).timeout(_timeout);
      return _parseCommentList(response);
    } catch (e) {
      throw Exception('Ошибка сети при поиске комментариев по обоим ID: $e');
    }
  }

  /// Закрывает HTTP-клиент
  void dispose() {
    client.close();
  }
}
