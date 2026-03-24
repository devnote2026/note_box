import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleGoogleLogin() async {
    if (_isLoading) return; // 念のため二重防止

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.signInWithGoogle();
      context.go('/nickname');
    } catch (e) {
      debugPrint("ログインエラー: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(""), backgroundColor: Colors.white),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Image.asset("assets/notebox_logo.png", height: 100),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isLoading ? null : () {
                    debugPrint('Appleログインは未実装');
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/apple_logo.png", height: 24),
                      const SizedBox(width: 12),
                      const Text('Appleで続ける', style: TextStyle(color: Colors.black)),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isLoading ? null : _handleGoogleLogin,
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("assets/google_logo.png", height: 24),
                            const SizedBox(width: 12),
                            const Text("Googleで続ける", style: TextStyle(color: Colors.black)),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}