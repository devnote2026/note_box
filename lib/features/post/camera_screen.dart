import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../main.dart';

import '../../widgets/shutter_button.dart';
import '../../widgets/bottom_navbar.dart';
import './post_screen.dart';
import '../../services/image_picker_service.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? controller;
  Future<void>? _initializeControllerFuture;
  bool _isTakingPicture = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      // 🔐 権限チェック
      final status = await Permission.camera.request();

      if (!status.isGranted) {
        if (status.isPermanentlyDenied) {
          setState(() => _error = "設定からカメラを許可してください。");
          await openAppSettings();
        } else {
          setState(() => _error = "カメラの許可が必要です。");
        }
        return;
      }

      // 📷 カメラ取得
      if (cameras.isEmpty) {
        setState(() => _error = "カメラが見つかりません。");
        return;
      }

      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      _initializeControllerFuture = controller!.initialize();
      await _initializeControllerFuture;

      if (!mounted) return;
      setState(() {});
    } catch (e) {
      setState(() => _error = "カメラの初期化に失敗しました。$e");
      debugPrint("カメラの初期化に失敗しました。$e");
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (controller == null) return;
    if (_isTakingPicture) return;

    try {
      setState(() => _isTakingPicture = true);

      await _initializeControllerFuture;
      final image = await controller!.takePicture();
      final file = File(image.path);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PostScreen(imageFile: file),
        ),
      );
    } catch (e) {
      debugPrint("撮影に失敗しました。");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("撮影に失敗しました")),
      );
    } finally {
      setState(() => _isTakingPicture = false);
    }
  }

  Future<void> _selectFromGallery() async {
    try {
      final pickerService = ImagePickerService();
      final imageFile = await pickerService.pickImage();

      if (!mounted) return;
      if (imageFile == null) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PostScreen(imageFile: imageFile),
        ),
      );
    } catch (e) {
      debugPrint("フォトライブラリが開けませんでした。$e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("画像の取得に失敗しました")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ❌ エラー表示（UI改善済み）
    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            _error!,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // ⏳ 初期化前
    if (_initializeControllerFuture == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                "カメラを起動中...",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    "カメラを起動中...",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              Positioned.fill(
                child: CameraPreview(controller!),
              ),

              // 📸 撮影中オーバーレイ（連打防止）
              if (_isTakingPicture)
                Container(
                  color: Colors.black54,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),

              ShutterButton(
                onTap: _takePicture,
                onGalleryTap: _selectFromGallery,
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavbar(),
    );
  }
}