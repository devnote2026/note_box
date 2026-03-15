import 'package:flutter/material.dart';

class NicknameScreen extends StatefulWidget {
  const NicknameScreen({super.key});

  @override
  State<NicknameScreen> createState() => _NicknameScreenState();
}

class _NicknameScreenState extends State<NicknameScreen> {
  
  final _nicknameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Column(
        children: [

          Padding(
            padding: EdgeInsets.all(24),
            child: Column(

              // Padding 部分
              children: [
                Text("ニックネームを入力してください",style: TextStyle(height: 24,color: Colors.black),),

                TextField(
                  controller: _nicknameController,
                  decoration: InputDecoration(
                    labelText: '飯間 圭一郎',
                    floatingLabelBehavior: FloatingLabelBehavior.never,

                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide( color: Colors.grey)
                    ),

                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2)
                    )
                  ),
                ),

                SizedBox(height: 20,),

                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    )
                  ),

                  onPressed: (){
                    debugPrint(_nicknameController.text);
                  },

                  child: Text("次へ",style: TextStyle(color: Colors.black))

                )
              ],
            )
          ),

          Expanded(
            child:Spacer()
          )
        ],
      )
    );
  }
}