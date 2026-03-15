import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/custom_button.dart';


// 画像を選択してストレージにアップロード、Firestoreに画像のURLを保存する。

class ProfileImageScreen extends StatefulWidget {
  const ProfileImageScreen({super.key});

  @override
  State<ProfileImageScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileImageScreen> {

  File? image;                                     //選択された画像を管理する変数。
  final ImagePicker _picker = ImagePicker();       //写真ライブラリを操作するクラス。


  Future<void> pickImage() async {                 //写真ライブラリから画像を取得する関数
    try{

      final pickedFile = await _picker.pickImage(  //選択された画像を pickedFile に保存。
        source: ImageSource.gallery,
      );

      if (pickedFile == null) return;

      setState(() {
        image = File(pickedFile.path);
      });
    }

    catch(e){
      debugPrint("写真ライブラリから画像の取得に失敗: $e");
      rethrow;
    }
  }



  void next (){
    context.go("/search");
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),  // 画面に安全に収まるように調節。

            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,


                children: [

                  const SizedBox(height: 50,),

                  const Text("プロフィール画像を登録",style: TextStyle(fontSize: 20),),

                  const SizedBox(height: 50,),

                  //プロフィール画像
                  
                  Container(
                    padding: const EdgeInsets.all(3), // 枠線の太さ
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.black, // 枠線の色
                        width: 0,
                      ),
                   ),
                    child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.black,
                    backgroundImage:
                          image != null ? FileImage(image!) : null,
                    child: image == null
                          ? const Icon(Icons.person, size: 40, color: Colors.white)
                          : null,
                    ),
                  ),

                  const SizedBox(height: 120,),

                  CustomButton(
                    text: "画像を選択",
                    onPressed: () async{
                      await pickImage();
                    },
                  ),

                  const SizedBox(height: 20,),

                  CustomButton(
                    text:"次へ",
                    onPressed: (){
                      debugPrint("画像をストレージに保存します。");
                      //ストレージに保存して、FirestoreのURL更新、isProfileCompleted更新

                    },
                  ),


                ],
              ),
            )
            
          )
        ),
      )
    );


  }
}