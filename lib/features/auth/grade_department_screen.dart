import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';

import '../../services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:go_router/go_router.dart';


//学年・学科を登録する画面

class GradeDepartmentScreen extends StatefulWidget {
  const GradeDepartmentScreen({super.key});

  @override
  State<GradeDepartmentScreen> createState() => _GradeDepartmentScreenState();
}

class _GradeDepartmentScreenState extends State<GradeDepartmentScreen> {
  // 選択された学年・学科
  String? selectedGrade;
  String? selectedDepartment;

  final List<String> grades = [
    "1年",
    "2年",
    "3年",
    "4年",
  ];

  final List<String> departments = [
    "電子制御工学科",
    "電気工学科",
    "物質科学工学科",
    "機械工学科",
    "情報工学科",
  ];

  // 保存ボタンの処理（今はUIだけ）
Future<void> _saveGradeDepartment() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return; // 未ログインは処理中断

  if (selectedGrade == null || selectedDepartment == null) {   //未入力なら返す。
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("学年と学科を選択してください")),
    );
    return;
  }

  try {
    await UserService().saveGradeDepartment(    //選択された学年・学科を更新。
      uid: user.uid,
      grade: selectedGrade!,
      department: selectedDepartment!,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("選択: $selectedGrade / $selectedDepartment"),
      ),
    );

    // ここで画面遷移する場合は Navigator.push(...)
    debugPrint("学年・学科の保存に成功しました。");
    context.go("/profile_image");

  } catch (e) {
    debugPrint("学年・学科の保存に失敗しました: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("保存に失敗しました。もう一度試してください。")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [

              // 学年Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "学年",
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                initialValue: selectedGrade,
                dropdownColor: Colors.white,
                items: grades.map((grade) {
                  return DropdownMenuItem(
                    value: grade,
                    child: Text(
                      grade,
                      style: TextStyle(color: Colors.black),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedGrade = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              // 学科Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "学科",
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                initialValue: selectedDepartment,
                dropdownColor: Colors.white,
                items: departments.map((department) {
                  return DropdownMenuItem(
                    value: department,
                    child: Text(
                      department,
                      style: TextStyle(color: Colors.black),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDepartment = value;
                  });
                },
              ),

              const SizedBox(height: 40),

              // 保存ボタン
              SizedBox(
                width: double.infinity,
                height: 50,
                child: CustomButton(
                  text: "次へ",
                  onPressed: _saveGradeDepartment,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}