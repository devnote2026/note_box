import 'dart:io';
import 'package:flutter/material.dart';
import 'package:note_box/services/storage_service.dart';
import 'package:note_box/widgets/subjects_list.dart';

import '../../services/profile_service.dart';
import '../../widgets/grade_department_change_widget.dart';

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

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    final profileService = ProfileService(StorageService());
    final data = await profileService.getProfile();

    if (!mounted) return;

    setState(() {
      grade = data['grade'];
      department = data['department'];
    });

    debugPrint("学年: $grade,学科: $department");
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // 🔥 画像エリア
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

                  // 削除ボタン
                  Positioned(
                    bottom: MediaQuery.of(context).padding.bottom + 2,
                    right: 16,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.black,
                          size: 40,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 🔥 下の白エリア
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 学年・学科
                  Text(
                    "${department ?? ''}  ${grade ?? ''}",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),

                  // 設定ボタン
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () async {

                      //settingsがタップされた時の処理
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:(context) => const GradeDepartmentChangeWidget()
                        )
                      );

                      if(!mounted || result==null) return;

                      setState(() {
                        grade = result['grade'];
                        department = result['department'];
                      });

                      debugPrint("学年: $grade,学科: $department に変更");
                    },
                  ),
                ],
              ),
            ),

            if(grade != null && department != null)
             SubjectsList(
              key: UniqueKey(),
              grade: grade!,
              department: department!,
              onSubjectSelected: (selectedSubject){
                setState(() {
                  subject = selectedSubject;
                });
              },
             )
          ],
        ),
      ),
    );
  }
}