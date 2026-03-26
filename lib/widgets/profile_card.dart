import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import '../features/mypage/edit_profile_screen.dart';

class ProfileCard extends StatelessWidget {
  final ProfileService profileService;

  const ProfileCard({
    super.key,
    required this.profileService,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: profileService.getProfile(),
      builder: (context, snapshot) {
        // ローディング
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // エラー
        if (snapshot.hasError) {
          return const Text('エラーが発生しました');
        }

        final data = snapshot.data ?? {};

        final name = data['nickname'] ?? '未設定';
        final department = data['department'] ?? '';
        final grade = data['grade'] ?? '';
        final imageUrl = data['profileImageUrl'];

        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditProfileScreen(
                  currentNickname: name,
                  currentGrade: grade,
                  currentDepartment: department,
                  currentImageUrl: imageUrl,
                ),
              ),
            );
          },
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  blurRadius: 8,
                  color: Colors.black12,
                )
              ],
            ),

            /// 🔥 ここが超重要
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// アイコン
                CircleAvatar(
                  radius: 32,
                  backgroundImage: imageUrl != null
                      ? NetworkImage(imageUrl)
                      : null,
                  child: imageUrl == null
                      ? const Icon(Icons.person)
                      : null,
                ),

                const SizedBox(width: 16),

                /// 🔥 ここをExpandedで囲う
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// 名前
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      /// 学科 + 学年
                      Text(
                        '$department  $grade',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                /// 🔥 右アイコン（潰れないよう固定）
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        );
      },
    );
  }
}