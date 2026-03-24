import 'package:flutter/material.dart';
import '../../widgets/profile_card.dart';
import '../../widgets/logout_button.dart';
import '../../widgets/bottom_navbar.dart';
import '../../widgets/delete_account_button.dart';

// マイページを構成する
import '../../services/profile_service.dart';
import '../../services/profile_storage_service.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileService = ProfileService(ProfileStorageService());  //プロフィールを取得するクラスのインスタンスを生成

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white),
      bottomNavigationBar: BottomNavbar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ProfileCard(profileService: profileService), //プロフィールカードにインスタンスを渡す。
            const SizedBox(height: 180),
            const LogoutButton(),
            const SizedBox(height: 18,),
            const DeleteAccountButton()
          ],
        ),
      ),
    );
  }
}