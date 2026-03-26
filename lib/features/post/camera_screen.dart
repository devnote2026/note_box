import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../main.dart';

import '../../widgets/shutter_button.dart';
import '../../widgets/bottom_navbar.dart';
import './post_screen.dart';
import '../../services/image_picker_service.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {

  CameraController? controller;
  Future<void>? _initializeControllerFuture;
  bool _isTakingPicture = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    super.dispose();
  }

  // 🔥 復帰時のみ再初期化（安全）
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _initCamera();
    } else if (state == AppLifecycleState.inactive) {
      controller?.dispose();
    }
  }

  Future<void> _initCamera() async {
    try {
      setState(() {
        _error = null;
      });

      if (cameras.isEmpty) {
        setState(() => _error = "カメラが見つかりません");
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

      // 🔥 ここで権限ダイアログ出る（iOS/Android両対応）
      _initializeControllerFuture = controller!.initialize();
      await _initializeControllerFuture;

      if (!mounted) return;
      setState(() {});
    } catch (e) {
      final msg = e.toString();

      if (msg.contains("CameraAccessDenied")) {
        setState(() => _error = "カメラの許可が必要です。\n設定から許可してください");
      } else if (msg.contains("CameraAccessDeniedWithoutPrompt")) {
        setState(() => _error = "設定からカメラを許可してください");
      } else {
        setState(() => _error = "カメラ初期化エラー\n$msg");
      }
    }
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
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("画像の取得に失敗しました")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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

    if (_initializeControllerFuture == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
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
                "エラー: ${snapshot.error}",
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Stack(
            children: [
              Positioned.fill(
                child: CameraPreview(controller!),
              ),

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