import 'package:flutter/material.dart';
import '../../services/auth_service.dart';


class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final _authService = AuthService(); 

    return Scaffold(
      appBar: AppBar(title: Text("")),

      body: Column(
        children: [

          Expanded(
            child: Center(
              child: Text("")
            )
          ),

          Padding(
            padding: EdgeInsets.all(24),
            child: OutlinedButton(
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
                  
                  SizedBox(width: 12),

                  const Flexible(
                    child: Text('Googleで続ける',overflow:  TextOverflow.ellipsis,)
                  )
                ],
              )



              
              )
            )
          
        ]
      )
    );
  }
}