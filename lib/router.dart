import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


//[修正点あり]  /post → /search  68行目当たり


//初回限定４画面
import './features/auth/login_screen.dart';    // ログイン画面
import './features/auth/nickname_screen.dart'; // ニックネーム入力画面
import './features/auth/grade_department_screen.dart'; //学年・学科登録画面
import './features/auth/profile_image_screen.dart';    //プロフィール画像登録画面
import './features/auth/terms_agreement_screen.dart';


//メイン４画面
import './features/library/library_screen.dart';       //ライブラリ画面
import './features/mypage/mypage_screen.dart';         //マイページ画面
import './features/search/search_screen.dart';         //検索画面
import './features/post/camera_screen.dart';           //カメラ画面



class AppRouter {

    // ログイン状態の変化を監視するストリーム
    static final _authNotifier =
      AuthStateNotifier(FirebaseAuth.instance.authStateChanges());

    
    static final router = GoRouter(
      initialLocation: '/login',
      refreshListenable: _authNotifier,

redirect: (context, state) async {
  final user = FirebaseAuth.instance.currentUser;
  final location = state.matchedLocation;

  // 未ログイン
  if (user == null) {
    return location == '/login' ? null : '/login';
  }

  try {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final data = doc.data();

    // 基本ここは存在する想定（createUserIfNotExistsのおかげ）
    if (data == null) {
      return '/login';
    }

    if (data["nickname"] == null) {
      return location == '/nickname' ? null : '/nickname';
    }

    if (data["gradeDepartmentSaved"] != true) {
      return location == '/grade_department'
          ? null
          : '/grade_department';
    }

    if (data["isProfileCompleted"] != true) {
      return location == '/profile_image'
          ? null
          : '/profile_image';
    }

    if (data["agreedToTerms"] != true) {
      return location == '/terms' ? null : '/terms';    
    }

    // 完了済みユーザー
    if (
      location == '/login' ||
      location == '/nickname' ||
      location == '/grade_department' ||
      location == '/profile_image' ||
      location == '/terms'
    ) {
      return '/search';
    }

    return null;

  } catch (e) {
    debugPrint("Router error: $e");
    return '/login';
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
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SearchScreen()
          ),
        ),

        GoRoute(
          path: '/grade_department',
          builder: (context, state) => const GradeDepartmentScreen(),
        ),

        GoRoute(
          path: '/profile_image',
          builder: (context, state) => ProfileImageScreen(),
        ),


        GoRoute(
          path: '/library',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: LibraryScreen()
          ),
        ),

        GoRoute(
          path: '/mypage',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: MyPageScreen()
          ),
        ),

        GoRoute(
          path: '/camera',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: CameraScreen()
          ),
        ),

        GoRoute(
          path: '/terms',
          builder: (context, state) => const TermsAgreementScreen(),
        ),
      ]
    );


    
}


// firebaseのログイン状態の変化を監視し、go_routerに渡せる形式にする。
class AuthStateNotifier extends ChangeNotifier {

  late final StreamSubscription<User?> _sub;

  AuthStateNotifier(Stream<User?> stream) {
    _sub = stream.listen((user) {
      debugPrint("AUTH STATE CHANGED: $user");
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}