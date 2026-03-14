import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


//画面
import './features/auth/login_screen.dart';    // ログイン画面
import './features/auth/nickname_screen.dart'; // ニックネーム入力画面
import './features/search/search_screen.dart'; // 検索画面


class AppRouter {

    // ログイン状態の変化を監視するストリーム
    static final _authNotifier =
      AuthStateNotifier(FirebaseAuth.instance.authStateChanges());

    
    static final router = GoRouter(
      initialLocation: '/login',
      refreshListenable: _authNotifier,
      redirect:(context, state) {
        final user = FirebaseAuth.instance.currentUser;
        final isLogin = state.matchedLocation == '/login';

        if(user == null){
          return '/login';
        } 
        if (isLogin){
          return '/search';
        }
        else{
          return null;
        }
      },
      

      // 画面リスト

      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),

        GoRoute(
          path:'/nickname',
          builder: (context, state) => const NicknameScreen(),
        ),

        GoRoute(
          path: '/search',
          builder: (context, state) => const SearchScreen(),
        )

      ]
    );


    
}


// firebaseのログイン状態の変化を監視し、go_routerに渡せる形式にする。
class AuthStateNotifier extends ChangeNotifier {
  AuthStateNotifier(Stream<User?> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<User?> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}