class CommentModel {
  final int? id;
  final String creatorEmail;
  final int objectId;
  final String content;

  const CommentModel({
    required this.content,
    required this.creatorEmail,
    required this.objectId,
    this.id,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as int,
      creatorEmail: json['creatorEmail'] as String,
      objectId: json['objectId'] as int,
      content: json['content'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creatorEmail': creatorEmail,
      'objectId': objectId,
      'content': content,
    };
  }

  CommentModel copyWith({
    int? id,
    String? creatorEmail,
    int? objectId,
    String? content,
  }) {
    return CommentModel(
      id: id ?? this.id,
      creatorEmail: creatorEmail ?? this.creatorEmail,
      objectId: objectId ?? this.objectId,
      content: content ?? this.content,
    );
  }
}
