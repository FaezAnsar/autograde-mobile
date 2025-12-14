enum ChatContentType {
  gif,
  image,
  video,
  link,
  // ignore: constant_identifier_names
  meeting_purchase,
  text;

  static ChatContentType fromJson(String json) {
    return ChatContentType.values.firstWhere(
      (e) => e.name == json,
      orElse: () => ChatContentType.text,
    );
  }
}
