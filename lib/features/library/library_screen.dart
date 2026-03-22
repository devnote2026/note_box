import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/library_service.dart';
import '../../widgets/note_type_selector.dart';
import '../../widgets/grade_selector.dart';
import '../../widgets/bottom_navbar.dart';
import '../../widgets/note_card.dart';

import '../library/labeled_note_screen.dart';

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

  /// 🔥 ラベルノート導線（分離済み）
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
            border: Border()
          ),
          child: Row(
            children: const [
              Icon(Icons.bookmark,color: Colors.black,),
              SizedBox(width: 12),
              Text(
                "保存したノート",
                style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  Future<void> loadNotes() async {
    setState(() {
      isLoading = true;
    });

    final result = await _service.fetchMyNotes(
      grade: selectedGrade,
      noteType: selectedNoteType,
    );

    setState(() {
      notes = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavbar(),
      appBar: AppBar(
        title: const Text(""),
        backgroundColor: Colors.white,
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              /// 学年フィルター
              GradeSelector(
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

              /// 🔥 保存したノート導線（ここに固定）
              _buildLabeledNotes(),

              const SizedBox(height: 16),

              /// ノート一覧
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : notes.isEmpty
                        ? const Center(child: Text("ノートがありません"))
                        : ListView.builder(
                            itemCount: notes.length,
                            itemBuilder: (context, index) {
                              final note = notes[index];
                              return NoteCard(note: note);
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