import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';

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
    "5年",
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
    try {
      if (selectedGrade == null || selectedDepartment == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("学年と学科を選択してください")),
        );
        return;
      }

      // ここにFirestore保存や画面遷移を追加可能
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("選択: $selectedGrade / $selectedDepartment"),
        ),
      );

    } catch (e) {
      debugPrint("学年・学科の保存に失敗しました。$e");
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