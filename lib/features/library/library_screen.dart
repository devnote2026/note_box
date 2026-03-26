import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/library_service.dart';
import '../../widgets/note_type_selector.dart';
import '../../widgets/grade_selector.dart';
import '../../widgets/bottom_navbar.dart';
import '../../widgets/note_card.dart';

import '../library/labeled_note_screen.dart';
import '../../constants/profile_constants.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _MyLibraryScreenState();
}

class _MyLibraryScreenState extends State<LibraryScreen> {
  final LibraryService _service = LibraryService();

  String selectedGrade = "";
  String selectedNoteType = "";

  List<QueryDocumentSnapshot> notes = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    /// 🔥 横画面禁止（この画面だけ）
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    loadNotes();
  }

  @override
  void dispose() {
    /// 🔥 元に戻す（これ忘れると他画面も縦固定になる）
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  /// 🔥 レスポンシブ対応版
  Widget _buildLabeledNotes() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const LabeledNotesScreen(),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(12),
          ),

          /// 👇ここが重要
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.bookmark, color: Colors.black),

              const SizedBox(width: 12),

              /// 🔥 文字がでかくなっても絶対崩れない
              Expanded(
                child: Text(
                  "保存したノート",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> loadNotes() async {
    setState(() {
      isLoading = true;
    });

    final result = await _service.fetchMyNotes(
      grade: selectedGrade,
      noteType: selectedNoteType,
    );

    if (!mounted) return;

    setState(() {
      notes = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const BottomNavbar(),
      appBar: AppBar(
        title: const Text(""),
        backgroundColor: Colors.white,
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),

          /// 🔥 Column + Expandedで安全
          child: Column(
            children: [
              /// 学年フィルター
              GradeSelector(
                values: grades,
                selected: selectedGrade,
                onChanged: (value) async {
                  setState(() {
                    selectedGrade = value;
                  });
                  await loadNotes();
                },
              ),

              const SizedBox(height: 12),

              /// ノートタイプフィルター
              NoteTypeSelector(
                selected: selectedNoteType,
                onChanged: (value) async {
                  setState(() {
                    selectedNoteType = value;
                  });
                  await loadNotes();
                },
              ),

              const SizedBox(height: 16),

              /// 保存したノートボタン
              _buildLabeledNotes(),

              const SizedBox(height: 8),

              /// 🔥 一覧（ここが一番重要）
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : notes.isEmpty
                        ? const Center(child: Text("ノートがありません"))
                        : ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: notes.length,
                            itemBuilder: (context, index) {
                              final note = notes[index];
                              final data =
                                  note.data() as Map<String, dynamic>;

                              return NoteCard(
                                noteId: note.id,
                                subject: data['subject'] ?? "",
                                noteType: data['noteType'] ?? "",
                                term: data['term'] ?? "",
                                nickname: data['nickname'] ?? "名無し",
                                profileImageUrl:
                                    data['profileImageUrl'],
                                updatedAt:
                                    (data['updatedAt'] as Timestamp?)
                                        ?.toDate(),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}