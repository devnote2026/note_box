import 'dart:io';
import 'package:flutter/material.dart';
import 'package:note_box/services/profile_storage_service.dart';
import 'package:note_box/services/post_storage_service.dart';
import 'package:note_box/utils/image_utils.dart';
import 'package:note_box/widgets/subject_selector.dart';

import '../../services/profile_service.dart';
import '../../services/post_service.dart';
import '../../services/subject_service.dart';
import '../../widgets/grade_department_change_widget.dart';
import '../../widgets/note_type_selector.dart';
import '../../widgets/term_selector.dart';
import '../../constants/note_type.dart';
import '../../widgets/custom_button.dart';

//ノートの情報を登録する画面

class PostScreen extends StatefulWidget {
  final File imageFile;

  const PostScreen({
    super.key,
    required this.imageFile,
  });

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  String? grade;
  String? department;
  String? subject;
  String? noteType = NoteType.lesson;
  String? term;

  bool isLoading = false;

  List<String> subjects = [];
  bool isLoadingSubjects = false;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  /// 🔥 プロフィール取得
  Future<void> fetchProfile() async {
    final profileService = ProfileService(ProfileStorageService());
    final data = await profileService.getProfile();

    if (!mounted) return;

    setState(() {
      grade = data['grade'];
      department = data['department'];
    });

    await fetchSubjects();
  }

  /// 🔥 投稿処理（UIから分離）
  Future<void> handlePost() async {
    if (isLoading) return;

    /// 🔥 バリデーション
    if (grade == null ||
        department == null ||
        subject == null ||
        noteType == null) {
      showError("未入力の項目があります");
      return;
    }

    if (noteType == NoteType.pastExam && term == null) {
      showError("期間を選択してください");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final postService = PostService(PostStorageService());

      final compressedFile = await ImageUtils.convertToJpg(widget.imageFile);

      if(!mounted) return;
      Navigator.pop(context,true);

       postService.createPost(
        imageFile: compressedFile,
        grade: grade!,
        department: department!,
        subject: subject!,
        noteType: noteType!,
        term: term,
      );

    } catch (e) {
      showError("投稿に失敗しました");
    } finally {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  
  Future<void> fetchSubjects() async{

    if(grade == null || department == null) return;

    setState(() {
      isLoadingSubjects = true;
    });

    try{
      final result = await SubjectService().getSubjects(grade!, department!);

      if(!mounted) return;

      setState(() {
        subjects = result;
        subject = null;
        isLoadingSubjects = false;
      });
    }

    catch(e){
      setState(() {
        subjects = [];
        isLoadingSubjects = false;
      });
    }
  }
  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            /// 🔥 画像エリア
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: Image.file(
                        widget.imageFile,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  /// 削除ボタン
                  Positioned(
                    bottom: MediaQuery.of(context).padding.bottom + 12,
                    right: 16,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// 🔥 下エリア
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    /// 上部情報
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "${department ?? ''}  ${grade ?? ''}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),

                              IconButton(
                                icon: const Icon(Icons.settings),
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const GradeDepartmentChangeWidget(),
                                    ),
                                  );

                                  if (!mounted || result == null) return;

                                  setState(() {
                                    grade = result['grade'];
                                    department = result['department'];
                                  });

                                  await fetchSubjects();
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          /// ノートタイプ
                          NoteTypeSelector(
                            selected: noteType ?? NoteType.lesson,
                            onChanged: (value) {
                              setState(() {
                                noteType = value;
                                term = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    const Divider(),

                    /// 🔥 フィルター
                    Expanded(
                      child: ListView(
                        children: [
                          if (grade != null && department != null)
                            SubjectSelector(
                              subjects: subjects,
                              selectedSubject: subject,
                              isLoading: isLoadingSubjects,
                              onSelect:  (value) {
                                setState(() {
                                  subject = value;
                                });
                              },
                            ),

                          const SizedBox(height: 12),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: TermSelector(
                              terms:["前期中間","前期末","後期中間","学年末"],
                              selectedTerm: term,
                              enabled: noteType == NoteType.pastExam,
                              onSelected: (value) {
                                setState(() {
                                  term = value;
                                });
                              },
                            )
                          ),
                        ],
                      ),
                    ),

                    /// 🔥 投稿ボタン（ここ追加）
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: CustomButton(
                        text: isLoading ? "投稿中..." : "投稿する",
                        onPressed: handlePost,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}