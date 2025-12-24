// data/models/user_model/user_model.dart

class UserModel {
  final double id;
  final String login;
  final String email;
  final String password;
  final String? imageBit;
  final List<int>? idSavedPlaces;
  final List<int>? idWins;
  final List<int>? idVisitedPlaces;
  final List<int>? idMyComments;
  final List<int>? idMyObject;
  final String? role;

  const UserModel({
    required this.id,
    required this.login,
    required this.email,
    required this.password,
    this.role = "user_unsign",
    this.idMyComments,
    this.idMyObject,
    this.idSavedPlaces,
    this.idVisitedPlaces,
    this.idWins,
    this.imageBit,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] as num).toDouble(),
      login: json['login'],
      email: json['email'],
      password: json['password'],
      imageBit: json['image_bit'],
      idSavedPlaces: json['id_saved_places'] != null
          ? List<int>.from(json['id_saved_places'])
          : null,
      idWins: json['id_wins'] != null ? List<int>.from(json['id_wins']) : null,
      idVisitedPlaces: json['id_visited_places'] != null
          ? List<int>.from(json['id_visited_places'])
          : null,
      idMyComments: json['id_my_comments'] != null
          ? List<int>.from(json['id_my_comments'])
          : null,
      idMyObject: json['id_my_object'] != null
          ? List<int>.from(json['id_my_object'])
          : null,
      role: json['role'],
    );
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
      id: id,
      login: login ?? this.login,
      email: email ?? this.email,
      password: password ?? this.password,
      imageBit: imageBit ?? this.imageBit,
      role: role ?? this.role,
      idSavedPlaces: idSavedPlaces ?? this.idSavedPlaces,
      idWins: idWins ?? this.idWins,
      idVisitedPlaces: idVisitedPleces ?? idVisitedPlaces,
      idMyComments: idMyComments ?? this.idMyComments,
      idMyObject: idMyObject ?? this.idMyObject,
    );
  }

  bool get isSignedIn => role != "user_unsign";

  bool get isAdmin => role == "admin";

  int get savedPlacesCount => idSavedPlaces?.length ?? 0;

  int get visitedPlacesCount => idVisitedPlaces?.length ?? 0;

  bool isPlaceSaved(int placeId) {
    return idSavedPlaces?.contains(placeId) ?? false;
  }

  bool isPlaceVisited(int placeId) {
    return idVisitedPlaces?.contains(placeId) ?? false;
  }
}
