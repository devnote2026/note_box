import 'package:flutter/material.dart';
import '../../services/auth_service.dart';


// Googleログイン、Appleログインを行う。

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final _authService = AuthService(); 

    return Scaffold(
      appBar: AppBar(title: Text(""),backgroundColor: Colors.white,),
      backgroundColor: Colors.white,

      body: Column(
        children: [

          Expanded(
            child: Center(
              child: Image.asset("assets/notebox_logo.png",height: 100,),
            )
          ),

          Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: (){
                    debugPrint('Appleログインは未実装');
                  },
                  
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/apple_logo.png",height: 24,),

                      SizedBox(width: 12,),

                      Text('Appleで続ける',style: TextStyle(color: Colors.black))
                    ]
                  )
                ),

                SizedBox(height: 12,),

                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                   ),
                  
                  onPressed: (){
                    _authService.signInWithGoogle();
                  },

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/google_logo.png",height: 24,),

                      SizedBox(width: 12,),

                      Text("Googleで続ける",style: TextStyle(color: Colors.black))
                    ],
                  )
                )
              ]
            )
            )
          
        ]
      )
    );
  }
}