import 'package:flutter/material.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {

  // ノート種類
  String type = "lecture"; // デフォルト講義

  // 年度
  int year = DateTime.now().year;

  // 試験種別
  String term = "mid";

  // 科目
  final TextEditingController subjectController = TextEditingController();

  // 画像リスト（今はダミー）
  List<String> images = [];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("ノート投稿"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              /// ノート種類
              const Text("種類", style: TextStyle(fontSize: 16)),

              const SizedBox(height: 8),

              Row(
                children: [

                  ChoiceChip(
                    label: const Text("講義"),
                    selected: type == "lecture",
                    onSelected: (_) {
                      setState(() {
                        type = "lecture";
                      });
                    },
                  ),

                  const SizedBox(width: 8),

                  ChoiceChip(
                    label: const Text("試験"),
                    selected: type == "exam",
                    onSelected: (_) {
                      setState(() {
                        type = "exam";
                      });
                    },
                  ),

                  const SizedBox(width: 8),

                  ChoiceChip(
                    label: const Text("演習"),
                    selected: type == "exercise",
                    onSelected: (_) {
                      setState(() {
                        type = "exercise";
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// 年度
              const Text("年度", style: TextStyle(fontSize: 16)),

              const SizedBox(height: 8),

              DropdownButton<int>(
                value: year,
                items: List.generate(
                  7,
                  (index) {
                    final y = DateTime.now().year - index;
                    return DropdownMenuItem(
                      value: y,
                      child: Text("$y"),
                    );
                  },
                ),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    year = value;
                  });
                },
              ),

              const SizedBox(height: 24),

              /// 科目入力
              const Text("科目", style: TextStyle(fontSize: 16)),

              const SizedBox(height: 8),

              TextField(
                controller: subjectController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "例：線形代数",
                ),
              ),

              const SizedBox(height: 24),

              /// 試験種別（type == exam の時だけ表示）
              if (type == "exam") ...[

                const Text("試験種別", style: TextStyle(fontSize: 16)),

                const SizedBox(height: 8),

                Row(
                  children: [

                    ChoiceChip(
                      label: const Text("中間"),
                      selected: term == "mid",
                      onSelected: (_) {
                        setState(() {
                          term = "mid";
                        });
                      },
                    ),

                    const SizedBox(width: 8),

                    ChoiceChip(
                      label: const Text("期末"),
                      selected: term == "final",
                      onSelected: (_) {
                        setState(() {
                          term = "final";
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],

              /// 画像アップロード
              const Text("ページ画像", style: TextStyle(fontSize: 16)),

              const SizedBox(height: 8),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: images.length + 1,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),

                itemBuilder: (context, index) {

                  /// ＋ボタン
                  if (index == images.length) {
                    return GestureDetector(
                      onTap: () {

                        // TODO:
                        // ここで image_picker を使って画像選択
                        // 選択した画像を images に追加
                      },

                      child: Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.add),
                      ),
                    );
                  }

                  /// 画像表示（今はダミー）
                  return Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.image),
                  );
                },
              ),

              const SizedBox(height: 40),

              /// 投稿ボタン
              SizedBox(
                width: double.infinity,

                child: ElevatedButton(
                  onPressed: () {

                    // TODO:
                    // 1. subject取得
                    // 2. images取得
                    // 3. noteSetId生成
                    // 4. Storageアップロード
                    // 5. Firestore保存

                  },

                  child: const Text("投稿"),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}