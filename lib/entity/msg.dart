enum MsgType { send, receive }

class MsgEntity {
  final int id;
  final String content;
  final bool? confirmed;
  final MsgType type;
  final int createAt;

  const MsgEntity({
    required this.id,
    required this.content,
    this.confirmed,
    required this.type,
    required this.createAt,
  });

  MsgEntity copyWith({
    int? id,
    String? content,
    bool? confirmed,
    MsgType? type,
    int? createAt,
  }) {
    return MsgEntity(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      confirmed: confirmed ?? this.confirmed,
      createAt: createAt ?? this.createAt,
    );
  }
}
