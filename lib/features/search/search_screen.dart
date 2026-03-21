// ノートを検索する画面

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

import '../../constants/note_type.dart';


class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});



  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  String? grade;                                           //このクラスで扱う状態
  String? department;                                      //学年、学科、教科、ノートの種類、時期
  String? subject;
  String? noteType = NoteType.lesson;
  String? term;

  List<String> subjects = [];                              //教科リスト、termリスト
  static const List<String> terms = ["前期中間","前期末","後期中間","学年末"];
 
  List<QueryDocumentSnapshot> notes = [];                  //取得したノート一覧


  @override
  void initState(){
    super.initState();
    fetchUserInfo();
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

    try {                                              //
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final uid = user.uid;

      final doc = await FirebaseFirestore.instance
                          .collection("users")
                          .doc(uid)
                          .get();
      
      final g = doc['grade'];
      final d = doc['department'];

      if(!mounted) return;
      
      setState(() {
        grade = g;
        department = d;
      }); 

      await fetchSubjects();
      await fetchNotesData();

    }



    catch (e){
      debugPrint("ユーザー情報の取得に失敗しました。:$e");
      return;
    }
  }

  Future<void> fetchNotesData() async {         //条件に該当するノートの一覧を取得する
    try{
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

    catch(e){
      debugPrint("ノートを取得できませんでした。: $e");
    }
  }

  

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    bottomNavigationBar: BottomNavbar(),
    appBar: AppBar(backgroundColor: Colors.white,),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // =====================
        // 学年・学科
        // =====================
        SearchHeader(
          department: department,
          grade: grade,
          onTapSettings: (){
            // 学年・学科を設定する画面へ。
          },
        ),


        const SizedBox(height: 16),

        // =====================
        // ノートタイプ
        // =====================
        NoteTypeSelector(
          selected: noteType ?? NoteType.lesson,
          onChanged: (value) async{
            setState(() {
              noteType = value;
              term = null;
            });

            await fetchNotesData();
          } ,
        ),


        const SizedBox(height: 16),

        // =====================
        // 教科
        // =====================

        SizedBox(
          height: 40,
          child: SubjectSelector(
            subjects: subjects,
            selectedSubject: subject,
            onSelect: (item) async{
              setState(() {
                subject = item;
                term = null;
              });
              await fetchNotesData();
            },
          )
        ),

        const SizedBox(height: 16),



        // =====================
        // term（過去問のみ）
        // =====================
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

        // =====================
        // ノート一覧
        // =====================
        const Text(
          "検索結果",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        if (notes.isEmpty)
          const Center(child: Text("ノートがありません")),

        ...notes.map((note) {
          return Card(
            child: ListTile(
              title: Text(note["grade"] ?? ""),
              subtitle: Text(note["department"] ?? ""),
            ),
          );
        }),
      ],
    ),
  );
}
}