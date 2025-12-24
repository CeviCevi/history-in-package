// data/models/place_model/place_model.dart
class PlaceModel {
  final int id;
  final String label;
  final String address;
  final String? imageBit;
  final double oX;
  final double oY;
  final String about;
  final String typeName;
  final List<int>? idAR;
  final List<int>? idComments;

  const PlaceModel({
    required this.id,
    required this.label,
    required this.address,
    required this.oX,
    required this.oY,
    required this.about,
    required this.typeName,
    this.idAR,
    this.imageBit,
    this.idComments,
  });

  // Конвертация из JSON (snake_case с бэкенда)
  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    return PlaceModel(
      id: json['id'] as int,
      label: json['label'] as String,
      address: json['address'] as String,
      oX: (json['o_x'] as num).toDouble(),
      oY: (json['o_y'] as num).toDouble(),
      about: json['about'] as String,
      typeName: json['type_name'] as String,
      imageBit: json['image_bit'] as String?,
      idAR: json['id_ar'] != null ? List<int>.from(json['id_ar']) : null,
      idComments:
          json['id_comments'] != null
              ? List<int>.from(json['id_comments'])
              : null,
    );
  }

  // Конвертация в JSON (snake_case для бэкенда)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'address': address,
      'o_x': oX,
      'o_y': oY,
      'about': about,
      'type_name': typeName,
      'image_bit': imageBit,
      'id_ar': idAR,
      'id_comments': idComments,
    };
  }

  // Копирование с изменениями
  PlaceModel copyWith({
    int? id,
    String? label,
    String? address,
    String? imageBit,
    double? oX,
    double? oY,
    String? about,
    String? typeName,
    List<int>? idAR,
    List<int>? idComments,
  }) {
    return PlaceModel(
      id: id ?? this.id,
      label: label ?? this.label,
      address: address ?? this.address,
      imageBit: imageBit ?? this.imageBit,
      oX: oX ?? this.oX,
      oY: oY ?? this.oY,
      about: about ?? this.about,
      typeName: typeName ?? this.typeName,
      idAR: idAR ?? this.idAR,
      idComments: idComments ?? this.idComments,
    );
  }
}
