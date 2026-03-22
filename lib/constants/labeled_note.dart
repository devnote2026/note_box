import 'package:cloud_firestore/cloud_firestore.dart';

class LabeledNote {
  final String id;
  final String subject;
  final String noteType;
  final String? term;
  final String? imageUrl;
  final String nickname;
  final String? profileImageUrl;
  final int labelCount;
  final DateTime? createdAt;
  final DocumentSnapshot doc;

  LabeledNote({
    required this.id,
    required this.subject,
    required this.noteType,
    this.term,
    this.imageUrl,
    required this.nickname,
    this.profileImageUrl,
    required this.labelCount,
    this.createdAt,
    required this.doc
  });

  factory LabeledNote.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return LabeledNote(
      id: doc.id,
      subject: data['subject'] ?? '',
      noteType: data['noteType'] ?? '',
      term: data['term'],
      imageUrl: data['imageUrl'],
      nickname: data['nickname'] ?? '名無し',
      profileImageUrl: data['profileImageUrl'],
      labelCount: data['labelCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      doc:doc
    );
  }
}