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
                    bottom: MediaQuery.of(context).padding.bottom + 12,
                    right: 16,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.black,
                          size: 32,
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

            // 🔥 下の白エリア（改善）
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // 👇 つまみ（ボトムシート感）
                    Container(
                      margin: const EdgeInsets.only(top: 8, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // 🔹 学年・学科 + 設定
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${department ?? ''}  ${grade ?? ''}",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
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

                                debugPrint("学年: $grade,学科: $department に変更");
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Divider(height: 1),

                    // 🔥 スクロールエリア
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        children: [
                          if (grade != null && department != null)
                            SubjectsList(
                              grade: grade!,
                              department: department!,
                              onSubjectSelected: (selectedSubject) {
                                setState(() {
                                  subject = selectedSubject;
                                  debugPrint(subject);
                                });
                              },
                            ),
                        ],
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