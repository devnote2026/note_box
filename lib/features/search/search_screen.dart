// ノートを検索する画面

import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

import '../../widgets/bottom_navbar.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final _authService = AuthService();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ElevatedButton(
          child: Text("サインアウトする"),
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