import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';


class ViewerScreen extends StatefulWidget {
  final String noteId;
  final String subject;

  const ViewerScreen({
    super.key,
    required this.noteId,
    required this.subject,
  });

  @override
  State<ViewerScreen> createState() => _ViewerScreenState();
}

class _ViewerScreenState extends State<ViewerScreen> {

  int currentIndex = 0;
  List<Map<String,dynamic>> posts = [];

  Future<void> report() async {                            //通報処理
    try{ 
      final post = posts[currentIndex];
      final user = FirebaseAuth.instance.currentUser;

      if(user == null) return;

      final reportId = "${post['postId']}_${user.uid}";

      await FirebaseFirestore.instance
              .collection("reports")
              .doc(reportId)
              .set({
                'noteId': widget.noteId,
                'postId': post['postId'],
                'reportedBy': user.uid,
                'createdAt': FieldValue.serverTimestamp()
              });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("通報しました"))
      );
    }

    catch(e){
      debugPrint("通報に失敗しました: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final postRef = FirebaseFirestore.instance
        .collection('notes')
        .doc(widget.noteId)
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
          Text("通報する"),

          // 🚨 通報ボタン
          IconButton(
            icon: const Icon(Icons.report_outlined),
            onPressed: report
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

          final newPosts = docs.map((doc){
            return {
              'postId': doc.id,
              'imageUrl': doc['imageUrl'] 
            };
          }).toList();

          posts = newPosts;

          return PhotoViewGallery.builder(
            itemCount: posts.length,
            scrollPhysics: const ClampingScrollPhysics(),
            onPageChanged: (index){
              setState(() {
                currentIndex = index;
              });
            },
            builder: (context, index) {
              final post = posts[index];

              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(post['imageUrl']),
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