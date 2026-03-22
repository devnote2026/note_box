import 'dart:io';
import 'package:flutter/material.dart';

class ProfileImagePicker extends StatelessWidget {
  final String? imageUrl;
  final File? imageFile;
  final VoidCallback onTap;

  const ProfileImagePicker({
    super.key,
    required this.imageUrl,
    required this.imageFile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider? image;

    /// 🔥 優先順位：File → Network → null
    if (imageFile != null) {
      image = FileImage(imageFile!);
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      image = NetworkImage(imageUrl!);
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[200],
            backgroundImage: image,
            child: image == null
                ? const Icon(Icons.person, size: 50, color: Colors.grey)
                : null,
          ),

          const SizedBox(height: 8),

          /// 👇 UX向上（地味に重要）
          const Text(
            "プロフィール画像を変更",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}