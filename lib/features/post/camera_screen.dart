import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../main.dart';

import '../../widgets/shutter_button.dart';
import '../../widgets/bottom_navbar.dart';

//投稿画面の１画面目。カメラ画面。

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {

  CameraController? controller;                
  Future <void>? _initializeControllerFuture;  
  bool  _isTakingPicture = false;              
  String? _error;                              

  @override
  void initState(){
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      if(cameras.isEmpty){
        setState(() => _error = "カメラが見つかりません。");
        return;
      }
 
      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back, 
        orElse: () => cameras.first
      );

      controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false
      );

      _initializeControllerFuture = controller!.initialize();
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

  @override
  void dispose(){
    controller?.dispose();
    super.dispose();
  }
  
  Future<void> _takePicture() async {}

  Future<void> _selectFromGallery() async {}

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