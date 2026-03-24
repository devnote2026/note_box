import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../services/user_service.dart';
import '../../widgets/custom_button.dart';
import 'package:url_launcher/url_launcher.dart';



class TermsAgreementScreen extends StatefulWidget {
  const TermsAgreementScreen({super.key});

  @override
  State<TermsAgreementScreen> createState() => _TermsAgreementScreenState();
}

class _TermsAgreementScreenState extends State<TermsAgreementScreen> {
  bool isChecked = false;
  bool isLoading = false; // ← 連打防止フラグ
  final userService = UserService();

  /// 共通：連打防止ラッパー
  Future<void> _runWithLoading(Future<void> Function() action) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      await action();
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  /// SnackBar表示
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
  final uri = Uri.parse(url);

  if (!await launchUrl(
    uri,
    mode: LaunchMode.externalApplication, // ← これ重要
  )) {
    throw Exception('URLを開けませんでした');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("利用規約の同意"),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 20),

                            const Text(
                              "NoteBoxを利用するには\n利用規約とプライバシーポリシーへの同意が必要です",
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 30),

                            /// 利用規約
                            CustomButton(
                              text: "利用規約を確認",
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      _runWithLoading(() async {
                                        _openUrl('https://www.notion.so/32c22870ba4a80589ad1e8436360d60c');
                                      });
                                    },
                            ),

                            const SizedBox(height: 12),

                            /// プライバシーポリシー
                            CustomButton(
                              text: "プライバシーポリシーを確認",
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      _runWithLoading(() async {
                                        _openUrl('https://www.notion.so/32c22870ba4a80aaa96ecf88e82656d0');
                                      });
                                    },
                            ),

                            const SizedBox(height: 30),

                            /// チェックボックス
                            Row(
                              children: [
                                Checkbox(
                                  checkColor: Colors.black,
                                  activeColor: Colors.white,
                                  value: isChecked,
                                  onChanged: isLoading
                                      ? null
                                      : (value) {
                                          setState(() {
                                            isChecked = value!;
                                          });
                                        },
                                ),
                                const Expanded(
                                  child: Text("利用規約とプライバシーポリシーに同意します"),
                                ),
                              ],
                            ),

                            const Spacer(),

                            /// 開始ボタン（常に押せる）
                            CustomButton(
                              text: "NoteBoxを始める",
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      if (!isChecked) {
                                        _showSnackBar(
                                            "利用規約とプライバシーポリシーに同意してください");
                                        return;
                                      }

                                      _runWithLoading(() async {
                                        final user =
                                            FirebaseAuth.instance.currentUser;

                                        if (user == null) return;

                                        await userService.agreeToTerms(
                                          uid: user.uid,
                                          termsVersion: "1.0",
                                        );

                                        context.go('/search');
                                      });
                                    },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            /// ローディング中の画面カバー（完全連打防止）
            if (isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}