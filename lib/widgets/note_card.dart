import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/note_type.dart';

class NoteCard extends StatelessWidget {
  final QueryDocumentSnapshot note;

  const NoteCard({
    super.key,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    final data = note.data() as Map<String, dynamic>;

    final nickname = data["nickname"] ?? "名無し";
    final subject = data["subject"] ?? "";
    final noteType = data["noteType"] ?? "";
    final term = data["term"] ?? "";
    final userImage = data["profileImageUrl"];
    final updatedAt = data["updatedAt"] as Timestamp?;
    final noteTypeText = NoteType.displayMap[noteType] ?? noteType;


    final titleText = "$subjectの$noteTypeText";
    final timeText = _formatDate(updatedAt);

    return Card(
      color: Colors.white,
      
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.black,
          width: 1
        )
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),

        // 📚 左アイコン
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.menu_book,
            color: Colors.white,
          ),
        ),

        // 📝 タイトル
        title: Text(
          titleText,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),

        // 👤 サブ情報
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),

            // 👤 + 🕒
            Row(
              children: [
                CircleAvatar(
                  radius: 10,
                  backgroundImage: userImage != null
                      ? NetworkImage(userImage)
                      : null,
                  child: userImage == null
                      ? const Icon(Icons.person, size: 12)
                      : null,
                ),
                const SizedBox(width: 6),

                Text(
                  nickname,
                  style: const TextStyle(fontSize: 12),
                ),

                const Spacer(),

                Text(
                  "・ $timeText",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),

            // 📅 term（あれば）
            if (term.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  "📅 $term",
                  style: const TextStyle(fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 🔥 時間フォーマット
  String _formatDate(Timestamp? ts) {
    if (ts == null) return "";

    final date = ts.toDate();
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 0) return "${diff.inDays}日前";
    if (diff.inHours > 0) return "${diff.inHours}時間前";
    if (diff.inMinutes > 0) return "${diff.inMinutes}分前";
    return "たった今";
  }

}