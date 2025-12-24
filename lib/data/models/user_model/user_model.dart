// data/models/user_model/user_model.dart
class UserModel {
  final String login;
  final String email;
  final String password;
  final String? imageBit;
  final List<int>? idSavedPlaces;
  final List<int>? idWins;
  final List<int>? idVisitedPleces;
  final List<int>? idMyComments;
  final List<int>? idMyObject;
  final String? role;

  const UserModel({
    required this.login,
    required this.email,
    required this.password,
    this.role = "user_unsign",
    this.idMyComments,
    this.idMyObject,
    this.idSavedPlaces,
    this.idVisitedPleces,
    this.idWins,
    this.imageBit,
  });

  // Конвертация из JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      login: json['login'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      imageBit: json['image_bit'] as String?,
      role: json['role'] as String? ?? "user_unsign",
      idSavedPlaces: json['id_saved_places'] != null
          ? List<int>.from(json['id_saved_places'])
          : null,
      idWins: json['id_wins'] != null ? List<int>.from(json['id_wins']) : null,
      idVisitedPleces: json['id_visited_places'] != null
          ? List<int>.from(json['id_visited_places'])
          : null,
      idMyComments: json['id_my_comments'] != null
          ? List<int>.from(json['id_my_comments'])
          : null,
      idMyObject: json['id_my_object'] != null
          ? List<int>.from(json['id_my_object'])
          : null,
    );
  }

  // Конвертация в JSON (snake_case для бэкенда)
  Map<String, dynamic> toJson() {
    return {
      'login': login,
      'email': email,
      'password': password,
      'image_bit': imageBit,
      'role': role,
      'id_saved_places': idSavedPlaces,
      'id_wins': idWins,
      'id_visited_places': idVisitedPleces,
      'id_my_comments': idMyComments,
      'id_my_object': idMyObject,
    };
  }

  // Копирование с изменениями
  UserModel copyWith({
    String? login,
    String? email,
    String? password,
    String? imageBit,
    String? role,
    List<int>? idSavedPlaces,
    List<int>? idWins,
    List<int>? idVisitedPleces,
    List<int>? idMyComments,
    List<int>? idMyObject,
  }) {
    return UserModel(
      login: login ?? this.login,
      email: email ?? this.email,
      password: password ?? this.password,
      imageBit: imageBit ?? this.imageBit,
      role: role ?? this.role,
      idSavedPlaces: idSavedPlaces ?? this.idSavedPlaces,
      idWins: idWins ?? this.idWins,
      idVisitedPleces: idVisitedPleces ?? this.idVisitedPleces,
      idMyComments: idMyComments ?? this.idMyComments,
      idMyObject: idMyObject ?? this.idMyObject,
    );
  }

  bool get isSignedIn => role != "user_unsign";

  bool get isAdmin => role == "admin";

  int get savedPlacesCount => idSavedPlaces?.length ?? 0;

  int get visitedPlacesCount => idVisitedPleces?.length ?? 0;

  bool isPlaceSaved(int placeId) {
    return idSavedPlaces?.contains(placeId) ?? false;
  }

  bool isPlaceVisited(int placeId) {
    return idVisitedPleces?.contains(placeId) ?? false;
  }
}
