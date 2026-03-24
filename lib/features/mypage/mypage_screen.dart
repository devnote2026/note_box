import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../widgets/profile_card.dart';
import '../../widgets/logout_button.dart';
import '../../widgets/bottom_navbar.dart';
import '../../widgets/delete_account_button.dart';
import '../../widgets/custom_button.dart';

// マイページを構成する
import '../../services/profile_service.dart';
import '../../services/profile_storage_service.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  /// URLを開く
  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);

    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('URLを開けませんでした');
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileService =
        ProfileService(ProfileStorageService());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white),
      bottomNavigationBar: BottomNavbar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ProfileCard(profileService: profileService),

            const SizedBox(height: 40),

            /// 利用規約
            CustomButton(
              text: "利用規約を確認",
              onPressed: () {
                _openUrl(
                    'https://www.notion.so/32c22870ba4a80589ad1e8436360d60c');
              },
            ),

            const SizedBox(height: 12),

            /// プライバシーポリシー
            CustomButton(
              text: "プライバシーポリシーを確認",
              onPressed: () {
                _openUrl(
                    'https://www.notion.so/32c22870ba4a80aaa96ecf88e82656d0');
              },
            ),

            const SizedBox(height: 140),

            const LogoutButton(),

            const SizedBox(height: 18),

            const DeleteAccountButton(),
          ],
        ),
      ),
    );
  }
}