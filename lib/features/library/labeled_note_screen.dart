import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/label_notes_service.dart';
import '../../constants/labeled_note.dart';
import '../../widgets/note_card.dart';

class LabeledNotesScreen extends StatefulWidget {
  const LabeledNotesScreen({super.key});

  @override
  State<LabeledNotesScreen> createState() => _LabeledNotesScreenState();
}

class _LabeledNotesScreenState extends State<LabeledNotesScreen> {
  final _service = LabeledNotesService();

  final List<LabeledNote> _notes = [];
  DocumentSnapshot? _lastDoc;

  bool _isLoading = false;
  bool _hasMore = true;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchInitial();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        _fetchMore();
      }
    });
  }

  Future<void> _fetchInitial() async {
    setState(() => _isLoading = true);

    try {
      final result = await _service.fetchLabeledNotes();

      setState(() {
        _notes.clear();
        _notes.addAll(result);
        _lastDoc = result.isNotEmpty ? result.last.doc : null;
        _hasMore = result.length == 20;
      });
    } catch (e) {
      debugPrint(e.toString());
    }

    setState(() => _isLoading = false);
  }

  Future<void> _fetchMore() async {
    if (_lastDoc == null) return;

    setState(() => _isLoading = true);

    try {
      final result = await _service.fetchMoreLabeledNotes(
        lastDoc: _lastDoc!,
      );

      setState(() {
        _notes.addAll(result);
        _lastDoc = result.isNotEmpty ? result.last.doc : _lastDoc;
        _hasMore = result.length == 20;
      });
    } catch (e) {
      debugPrint(e.toString());
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _notes.isEmpty
                  ? const Center(
                      child: Text(
                        "保存したノートはありません。",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: _notes.length + 1,
                      itemBuilder: (context, index) {
                        if (index == _notes.length) {
                          return _isLoading
                              ? const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : const SizedBox();
                        }

                        final note = _notes[index];

                        return NoteCard(
                          noteId: note.id,
                          subject: note.subject,
                          noteType: note.noteType,
                          term: note.term ?? "",
                          nickname: note.nickname,
                          profileImageUrl: note.profileImageUrl,
                          updatedAt: note.createdAt,
                        );
                      },
                    ),
        ),
      ),
    );
  }
}