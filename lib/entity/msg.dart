enum MsgType { send, receive }

enum ContentType { text, image }

class MsgEntity {
  final int id;
  final String content;
  final bool? confirmed;
  final MsgType type;
  final ContentType contentType;
  final int createAt;

  const MsgEntity({
    required this.id,
    required this.content,
    this.confirmed,
    required this.type,
    required this.contentType,
    required this.createAt,
  });

  MsgEntity copyWith({
    int? id,
    String? content,
    bool? confirmed,
    MsgType? type,
    ContentType? contentType,
    int? createAt,
  }) {
    return MsgEntity(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      contentType: contentType ?? this.contentType,
      confirmed: confirmed ?? this.confirmed,
      createAt: createAt ?? this.createAt,
    );
  }
}
