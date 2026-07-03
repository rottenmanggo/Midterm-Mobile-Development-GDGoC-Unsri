/// Pure Dart note entity — no Firebase imports.
/// This is the domain representation of a note.
class Note {
  final String id;
  final String title;
  final String content;
  final String category;  // 'kuliah' | 'pribadi' | 'kerja' | 'ide'
  final String cardColor; // 'blue' | 'green' | 'amber' | 'mauve' | 'cream'
  final String cardType;  // 'normal' | 'wide' | 'tall'
  final bool isPinned;
  final DateTime createdAt;
  final String userId;

  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.cardColor,
    required this.cardType,
    required this.isPinned,
    required this.createdAt,
    required this.userId,
  });

  Note copyWith({
    String? id,
    String? title,
    String? content,
    String? category,
    String? cardColor,
    String? cardType,
    bool? isPinned,
    DateTime? createdAt,
    String? userId,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      cardColor: cardColor ?? this.cardColor,
      cardType: cardType ?? this.cardType,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Note && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Note(id: $id, title: $title, isPinned: $isPinned)';
}
