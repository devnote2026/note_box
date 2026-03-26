import 'package:flutter/material.dart';
import '../features/search/viewer_screen.dart';
import '../constants/note_type.dart';
import '../widgets/label_button.dart';

class NoteCard extends StatelessWidget {
  final String noteId;
  final String subject;
  final String noteType;
  final String term;
  final String nickname;
  final String? profileImageUrl;
  final DateTime? updatedAt;

  const NoteCard({
    super.key,
    required this.noteId,
    required this.subject,
    required this.noteType,
    required this.term,
    required this.nickname,
    required this.profileImageUrl,
    required this.updatedAt,
  });

  @override
  Widget build(BuildContext context) {
    final noteTypeText =
        NoteType.displayMap[noteType] ?? noteType;

    final titleText = term.isNotEmpty
        ? "$subjectの$noteTypeText($term)"
        : "$subjectの$noteTypeText";

    final timeText = _formatDate(updatedAt);

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.black, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ViewerScreen(
                noteId: noteId,
                subject: subject,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 左アイコン
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.menu_book, color: Colors.white),
              ),

              const SizedBox(width: 12),

              /// メインコンテンツ
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// タイトル
                    Text(
                      titleText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    /// ユーザー情報
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 10,
                          backgroundImage: profileImageUrl != null
                              ? NetworkImage(profileImageUrl!)
                              : null,
                          child: profileImageUrl == null
                              ? const Icon(Icons.person, size: 12)
                              : null,
                        ),
                        const SizedBox(width: 6),

                        /// ニックネーム
                        Expanded(
                          child: Text(
                            nickname,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),

                        const SizedBox(width: 6),

                        /// 時間
                        Flexible(
                          child: Text(
                            "・ $timeText",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              /// 右ボタン（潰れない）
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 40),
                child: LabelButton(noteId: noteId),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "";

    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 0) return "${diff.inDays}日前";
    if (diff.inHours > 0) return "${diff.inHours}時間前";
    if (diff.inMinutes > 0) return "${diff.inMinutes}分前";
    return "たった今";
  }
}