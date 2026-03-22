import 'package:flutter/material.dart';

class LabeledNotesScreen extends StatelessWidget {
  const LabeledNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("保存したノート"),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: const Center(
        child: Text("ここにラベル付きノート一覧が表示される"),
      ),
    );
  }
}