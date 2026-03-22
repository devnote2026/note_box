import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ViewerScreen extends StatelessWidget {
  final String noteId;
  final String subject;

  const ViewerScreen({
    super.key,
    required this.noteId,
    required this.subject,
  });

  @override
  Widget build(BuildContext context) {
    final postRef = FirebaseFirestore.instance
        .collection('notes')
        .doc(noteId)
        .collection('posts')
        .orderBy('createdAt');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        // ← 戻るボタン
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        actions: [
          // ⭐ 重要ラベルボタン
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              // TODO: 重要ラベル処理
            },
          ),

          // 🚨 通報ボタン
          IconButton(
            icon: const Icon(Icons.report_outlined),
            onPressed: () {
              // TODO: 通報処理
            },
          ),
        ],
      ),

      body: FutureBuilder<QuerySnapshot>(
        future: postRef.get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("ノートの取得中にエラーが発生しました"),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text("画像がありません"),
            );
          }

          final imageUrls =
              docs.map((doc) => doc['imageUrl'] as String).toList();

          return PhotoViewGallery.builder(
            itemCount: imageUrls.length,
            scrollPhysics: const ClampingScrollPhysics(),
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(imageUrls[index]),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
              );
            },
          );
        },
      ),
    );
  }
}