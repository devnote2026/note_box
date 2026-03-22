import 'package:flutter/material.dart';
import '../services/profile_service.dart';

//マイページのプロフィールカード

class ProfileCard extends StatelessWidget {
  final ProfileService profileService;

  const ProfileCard({
    super.key,
    required this.profileService,       //プロフィールを取得するためのインスタンスは親から受け取る
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(         
      future: profileService.getProfile(),         //ログイン中のユーザーの情報を取得する
      builder: (context, snapshot) {       
        // ローディング
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // エラー
        if (snapshot.hasError) {
          return const Text('エラーが発生しました');
        }

        // データ取得
        final data = snapshot.data ?? {};

        final name = data['nickname'] ?? '未設定';
        final department = data['department'] ?? '';
        final grade = data['grade'] ?? '';
        final imageUrl = data['profileImageUrl'];

        return InkWell(
          onTap: () {
            // プロフィール編集画面へ
          },
          borderRadius: BorderRadius.circular(16),
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
            child: Row(
              children: [
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

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text('$department  $grade'),
                  ],
                ),

                const Spacer(),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        );
      },
    );
  }
}