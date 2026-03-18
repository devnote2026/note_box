import 'package:flutter/material.dart';

//カメラ画面で表示するアイコンウィジェット。

class ShutterButton extends StatelessWidget {

  final VoidCallback onTap;
  final VoidCallback onGalleryTap;

  const ShutterButton({
    super.key,
    required this.onTap,
    required this.onGalleryTap
    });

  @override
  Widget build(BuildContext context) {


    return Positioned(
      bottom: 40,
      left: 20,
      right: 20,


      child:Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [

          //ライブラリから画像を選ぶためのボタン
          IconButton(
            onPressed: onGalleryTap,
            icon: Icon(Icons.photo_library,color: Colors.white,size: 42,)),

          //シャッターボタン
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 70,
              height: 70,

              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white,width: 4)
              ),
            )
          ),

          const SizedBox(width: 48,)
        ],
      )
      
    );
  }
}