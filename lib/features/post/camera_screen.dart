import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../main.dart';

import '../../widgets/shutter_button.dart';
import '../../widgets/bottom_navbar.dart';

import '../../services/image_picker_service.dart';

//投稿画面の１画面目。カメラ画面。

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {

  CameraController? controller;                      //カメラをコントロールするプログラム。
  Future <void>? _initializeControllerFuture;        //カメラの準備完了しているか
  bool  _isTakingPicture = false;                    //撮影中か
  String? _error;                                    //エラーの内容

  @override                                          //初期化で行うこと。
  void initState(){
    super.initState();
    _initCamera();
  }
 
  Future<void> _initCamera() async {                 //カメラの初期化
    try {
      if(cameras.isEmpty){                           //使用可能なカメラがあるかチェック
        setState(() => _error = "カメラが見つかりません。");
        return;
      }
 
      final camera = cameras.firstWhere(             //背面カメラを取得
        (c) => c.lensDirection == CameraLensDirection.back, 
        orElse: () => cameras.first
      );
 
      controller = CameraController(                  //コントローラーに取得したカメラと設定を登録
        camera,
        ResolutionPreset.high,                        //解像度高め
        enableAudio: false                            //音無効化
      );

      _initializeControllerFuture = controller!.initialize();  //初期化開始
      await _initializeControllerFuture;        

      if(!mounted) return;
      setState(() {});
    }

    catch(e){
      setState(() => _error = "カメラの初期化に失敗しました。$e");
      debugPrint("カメラの初期化に失敗しました。$e");
      return;
    }
  }

  @override                                      //メモリ解放
  void dispose(){
    controller?.dispose();
    super.dispose();
  }
  
  Future<void> _takePicture() async {            //撮影された時の処理
    

  }

  Future<void> _selectFromGallery() async {      //フォトライブラリから選択するための処理

    try{
      final pickerService = ImagePickerService();
      final imageFile = await pickerService.pickImage();

      if (!mounted) return;
      if (imageFile == null) return;
    }

    catch(e){
      debugPrint("フォトライブラリが開けませんでした。$e");
      if(!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("画像の取得に失敗しました")),
      );
    }
  }


  Widget build(BuildContext context) {
    if (_error!= null){
      return Center(child:Text("$_error"));
    }

    if (_initializeControllerFuture == null){
      return const Center(child: Text("読み込み中..."));
    }

    return Scaffold(
      backgroundColor: Colors.black,

      body: FutureBuilder(
        future: _initializeControllerFuture,
        builder: (context,snapshot){
          if(snapshot.hasError){
            return Center(child: Text("${snapshot.error.toString()}"));
          }

          if (snapshot.connectionState != ConnectionState.done){
            return Center(child: Text("読み込み中..."));
          }

          // 🔥 ここだけ変更（Scaffold削除）
          return Stack(
            children: [

              Positioned.fill(
                child: CameraPreview(controller!),
              ),

              ShutterButton(
                onTap: _takePicture,
                onGalleryTap: _selectFromGallery,
              ),
            ],
          );
        },
      ),

      // 🔥 これを外に出す
      bottomNavigationBar: BottomNavbar(),
    );
  }
}