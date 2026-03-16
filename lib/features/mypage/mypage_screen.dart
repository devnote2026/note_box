// ノートを検索する画面

import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

import '../../widgets/bottom_navbar.dart';

class MypageScreen extends StatelessWidget {
  const MypageScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final _authService = AuthService();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ElevatedButton(
          child: Text("(マイページ) サインアウトする"),
          onPressed: () async{
            try{
               _authService.signOut();
            }

            catch(e){
              debugPrint("サインアウトできませんでした。$e");
            }
          },
        )
      ),

      bottomNavigationBar: BottomNavbar(),
    );
  }
}