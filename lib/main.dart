import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'package:camera/camera.dart';

late List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try{
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  catch(e){
    debugPrint("Firebase初期化失敗: $e");
    return;
  }

  try{
    cameras = await availableCameras();
  }

  catch(e){
    debugPrint("カメラ初期化失敗$e");
    return;
  }

  runApp(const MyApp());
}




 