import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a note document in Firestore.
class NoteModel {
  final String id;
  final String title;
  final String content;
  final String category;  // 'study' | 'personal' | 'work' | 'idea'
  final String cardColor; // 'blue' | 'green' | 'amber' | 'mauve' | 'cream'
  final String cardType;  // 'normal' | 'wide' | 'tall'
  final bool isPinned;
  final int order;        // sort position (lower = higher in list)
  final Timestamp createdAt;
  final String userId;

  const NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.cardColor,
    required this.cardType,
    required this.isPinned,
    required this.order,
    required this.createdAt,
    required this.userId,
  });

  /// Creates a [NoteModel] from a Firestore document snapshot.
  factory NoteModel.fromJson(Map<String, dynamic> json, String id) {
    return NoteModel(
      id: id,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      category: json['category'] as String? ?? 'personal',
      cardColor: json['cardColor'] as String? ?? 'blue',
      cardType: json['cardType'] as String? ?? 'normal',
      isPinned: json['isPinned'] as bool? ?? false,
      order: json['order'] as int? ?? 0,
      createdAt: json['createdAt'] as Timestamp? ?? Timestamp.now(),
      userId: json['userId'] as String? ?? '',
    );
  }

  /// Converts this model to a Firestore-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'category': category,
      'cardColor': cardColor,
      'cardType': cardType,
      'isPinned': isPinned,
      'order': order,
      'createdAt': createdAt,
      'userId': userId,
    };
  }

  /// Creates a copy of this model with the provided fields overridden.
  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    String? category,
    String? cardColor,
    String? cardType,
    bool? isPinned,
    int? order,
    Timestamp? createdAt,
    String? userId,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      cardColor: cardColor ?? this.cardColor,
      cardType: cardType ?? this.cardType,
      isPinned: isPinned ?? this.isPinned,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
