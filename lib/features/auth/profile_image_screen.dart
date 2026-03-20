import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../services/profile_storage_service.dart';
import '../../services/profile_service.dart';
import '../../services/image_picker_service.dart';

import '../../widgets/custom_button.dart';


// 画像を選択してストレージにアップロード、Firestoreに画像のURLを保存する。
//[修正点あり] 130行当たり 遷移先の画面パス

class ProfileImageScreen extends StatefulWidget {
  const ProfileImageScreen({super.key});

  @override
  State<ProfileImageScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileImageScreen> {

  File? image;                                     //選択された画像を管理する変数。
  final ImagePicker picker = ImagePicker();       //写真ライブラリを操作するクラス。
  final profileService = ProfileService(ProfileStorageService());


Future<void> pickImage() async {
  try{

    final pickedImage = await ImagePickerService().pickImage();

    if (pickedImage == null) return;

    if(!mounted) return;

    setState(() {
      image = pickedImage;
    });

  }

  catch(e){
    debugPrint("フォトライブラリから画像の取得に失敗しました。$e");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("画像の保存に失敗しました"))
    );
  }
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
                        width: 2,
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
                    onPressed: pickImage
                  ),

                  const SizedBox(height: 20,),

                  CustomButton(
                    text:"プロフィール画像に設定",
                    onPressed: () async{

                      if (image == null){
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("プロフィール画像を選択してください。")),
                        );

                        debugPrint("プロフィール画像が選択されていません。");
                        return;
                      }
                      try{
                        await profileService.saveProfileImage(image!);
                        debugPrint("プロフィール画像の保存に成功しました。");


                        if(!mounted) return;
                        context.go('/search');     ////👈最初に標示する画面にする！
                      }

                      catch(e){
                        debugPrint("プロフィール画像の保存に失敗しました。$e");
                      }

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