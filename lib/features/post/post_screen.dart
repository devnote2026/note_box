import 'dart:io';
import 'package:flutter/material.dart';

class PostScreen extends StatefulWidget {

  final File imageFile;

  const PostScreen({
    super.key,required,
    required this.imageFile
     });

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SafeArea(                                  //安全なエリア
        child: Column(
          children: [

            Expanded(
              child: Stack(
                children: [

            Positioned.fill(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.file(
                  widget.imageFile,
                  fit: BoxFit.contain, // 🔥 cover → contain に変更（トリミング防止）
                ),
              ),
            ),

                  //戻るボタン
                  Positioned(
                    bottom: MediaQuery.of(context).padding.bottom + 2,
                    right: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white, // 🔥 背景追加
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon:Icon(Icons.delete,color: Colors.black,size: 40,),
                        onPressed: (){
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),

            Padding(
              padding: EdgeInsetsGeometry.all(120),
              child: Container(
                color: Colors.black,
              ),
            )
          ],
        )
      )      
    );
  }
}