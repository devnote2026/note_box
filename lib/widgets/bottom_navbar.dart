import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavbar extends StatelessWidget {
  const BottomNavbar({super.key});

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    debugPrint("現在のURL: $location");

    if (location.startsWith('/camera')) return 0;
    if (location.startsWith('/search')) return 1;
    if (location.startsWith('/library')) return 2;
    if (location.startsWith('/mypage')) return 3;

    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/camera');
        debugPrint("投稿画面に移動しました");
        break;

      case 1:
        context.go('/search');
        debugPrint("検索画面に移動しました");
        break;

      case 2:
        context.go('/library');
        debugPrint("ライブラリ画面に移動しました");
        break;

      case 3:
        context.go('/mypage');
        debugPrint("マイページ画面に移動しました");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getCurrentIndex(context);

    return Container(
      color: Colors.white, // ← 余白を埋めるために追加
      child: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) => _onTap(context, index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: "投稿",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "検索",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: "ライブラリ",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "マイページ",
          ),
        ],
      ),
    );
  }
}