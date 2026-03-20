import 'package:flutter/material.dart';
import '../services/subject_service.dart';

//学年・学科から教科一覧を取得してListViewでまとめるウィジェット。
//選ばれた要素を返す処理はまだ。

class SubjectsList extends StatefulWidget {  //親ウィジェットから学年・学科は受け取る。
  final String grade;
  final String department;
  final Function(String) onSubjectSelected;

  const SubjectsList({
    super.key,
    required this.grade,
    required this.department,
    required this.onSubjectSelected
  });

  @override
  State<SubjectsList> createState() => _SubjectsListState();
}
 
class _SubjectsListState extends State<SubjectsList> {  
  List<String> subjects = [];                             // 取得した教科リスト
  String? selectedSubject;                                // 選択された教科
  bool isLoading = true;                                  // 読み込み中か (初期値: 読み込み中)

  final subjectService = SubjectService();                // 教科を取得するインスタンス

  @override                                               // 初期化関数、初期化時に教科を取得する
  void initState() {
    super.initState();
    fetchSubjects();
  }

  @override
  void didUpdateWidget(covariant SubjectsList oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.grade != widget.grade ||
        oldWidget.department != widget.department) {
      fetchSubjects();
    }
  }

  Future<void> fetchSubjects() async {                    // 教科を取得する関数

    setState(() {
      isLoading = true;
    });
    try {
      final result = await subjectService.getSubjects(    // ここで取得
        widget.grade,
        widget.department,
      );

      setState(() {                                       // 教科を取得して読み込み済みにする
        subjects = result;
        selectedSubject = null;                           // 👈追加（前の選択をリセット）
        isLoading = false;
      });
    } catch (e) {                                         // エラーが出たらリストは空に、読み込み中のまま
      setState(() {
        subjects = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔄 ローディング中
    if (isLoading) {                                     // 読み込み中ののUI
      return const SizedBox(
        height: 50,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // ❌ データなし
    if (subjects.isEmpty) {                              // エラーが出てリストがからの場合のUI
      return const Center(
        child: Text("教科の一覧の取得に失敗しちゃったよ。ごめんね🥺")
      );
    }

    // ✅ データあり
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: subjects.map((subject) {
          final isSelected = subject == selectedSubject;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                side: BorderSide(
                  color: isSelected ? Colors.white : Colors.black
                ),
                backgroundColor:
                    isSelected ? Colors.black :  Colors.white,
              ),
              onPressed: () {                                       //アイテムが選択された時の処理
                setState(() {
                  selectedSubject = subject;
                });

                widget.onSubjectSelected(subject);
              },
              child: Text(subject,style: TextStyle(color: isSelected ? Colors.white : Colors.black),),
            ),
          );
        }).toList(),
      ),
    );
  }
}