import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:note_box/widgets/term_selector.dart';
import '../../widgets/bottom_navbar.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '../../services/subject_service.dart';
import '../../services/note_service.dart';

import '../../widgets/search_header.dart';
import '../../widgets/subject_selector.dart';
import '../../widgets/note_type_selector.dart';
import '../../widgets/note_card.dart';
import '../../widgets/grade_department_change_widget.dart';

import '../../constants/note_type.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  String? grade;
  String? department;
  String? subject;
  String? noteType = NoteType.lesson;
  String? term;

  List<String> subjects = [];
  static const List<String> terms = ["前期中間","前期末","後期中間","学年末"];

  List<QueryDocumentSnapshot> notes = [];

  @override
  void initState(){
    super.initState();
    fetchUserInfo();
  }

  Future<void> onSettings() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GradeDepartmentChangeWidget()
      )
    );

    if(result != null){
      setState(() {
        grade = result['grade'];
        department = result['department'];
      });
    }

    await fetchSubjects();
    await fetchNotesData();
  }

  Future<void> fetchSubjects() async {
    if (grade == null || department == null) return;

    final result = await SubjectService().getSubjects(grade!, department!);

    if(!mounted) return;
    setState(() {
      subjects = result;
      subject = null;
    });
  }

  Future<void> fetchUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    if(!mounted) return;

    setState(() {
      grade = doc['grade'];
      department = doc['department'];
    });

    await fetchSubjects();
    await fetchNotesData();
  }

  Future<void> fetchNotesData() async {
    final snapshot = await fetchNotes(
      grade: grade,
      department: department,
      subject: subject,
      term: term,
      noteType: noteType,
    );

    if(!mounted) return;

    setState(() {
      notes = snapshot;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const BottomNavbar(),
      appBar: AppBar(backgroundColor: Colors.white),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SearchHeader(
              department: department,
              grade: grade,
              onTapSettings: onSettings,
            ),

            const SizedBox(height: 16),

            NoteTypeSelector(
              selected: noteType ?? NoteType.lesson,
              onChanged: (value) async {
                setState(() {
                  noteType = value;
                  term = null;
                });
                await fetchNotesData();
              },
            ),

            const SizedBox(height: 16),

            SubjectSelector(
              subjects: subjects,
              selectedSubject: subject,
              onSelect: (item) async {
                setState(() {
                  subject = item;
                  term = null;
                });
                await fetchNotesData();
              },
            ),

            const SizedBox(height: 16),

            TermSelector(
              terms: terms,
              selectedTerm: term,
              enabled: noteType == NoteType.pastExam,
              onSelected: (value) async {
                setState(() {
                  term = value;
                });
                await fetchNotesData();
              },
            ),

            const SizedBox(height: 16),

            const Text(
              "検索結果",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            if (notes.isEmpty)
              const Center(child: Text("ノートがありません")),

            ...notes.map((note) {
              final data = note.data() as Map<String, dynamic>;

              return NoteCard(
                noteId: note.id,
                subject: data['subject'] ?? "",
                noteType: data['noteType'] ?? "",
                term: data['term'] ?? "",
                nickname: data['nickname'] ?? "名無し",
                profileImageUrl: data['profileImageUrl'],
                updatedAt:
                    (data['updatedAt'] as Timestamp?)?.toDate(),
              );
            }),
          ],
        ),
      ),
    );
  }
}