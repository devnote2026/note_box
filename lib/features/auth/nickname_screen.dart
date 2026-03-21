import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:go_router/go_router.dart';

import '../../services/user_service.dart';


//ニックネームを入力・保存を行う画面。



class NicknameScreen extends StatefulWidget {
  const NicknameScreen({super.key});

  @override
  State<NicknameScreen> createState() => _NicknameScreenState();
}

class _NicknameScreenState extends State<NicknameScreen> {
  

  //テキストフィールドを監視する人。
  final _nicknameController = TextEditingController();

  //監視しなくて良くなったら殺す。
  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }
  

  //ニックネームを保存する関数を先につくっておく
  Future<void> _saveNickname () async{
    try{
      final nickname = _nicknameController.text.trim();

      if (nickname.isEmpty){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("ニックネームを入力してください",style:TextStyle(fontSize: 20)))
        );
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null){
        debugPrint('ユーザーがログインしていません。');
        return;
      }

      final uid = user.uid;

      await UserService().createUser(uid: uid, nickname: nickname);
      
      debugPrint('ニックネームの保存に成功しました: $nickname');
      context.go('/grade_department');
    }
    catch(e){
      debugPrint("ニックネームを保存できませんでした$e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("保存に失敗しました。もう一度試してください"))
      );
      return;
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    resizeToAvoidBottomInset: true,

    body: SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom, // ← キーボード対応
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            Text(
              "ニックネームを入力してください",
              style: TextStyle(
                height: 1.5,
                color: Colors.black,
              ),
            ),

            TextField(
              controller: _nicknameController,
              decoration: InputDecoration(
                labelText: '飯間 圭一郎',
                floatingLabelBehavior: FloatingLabelBehavior.never,

                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),

                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
              ),
            ),

            SizedBox(height: 20),

            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                await _saveNickname();
              },
              child: Text(
                "次へ",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}