import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/label_service.dart';

class LabelButton extends StatefulWidget {
  final String noteId;

  const LabelButton({
    super.key,
    required this.noteId,
  });

  @override
  State<LabelButton> createState() => _LabelButtonState();
}

class _LabelButtonState extends State<LabelButton> {
  bool isLabeled = false;
  bool isLoading = true;
  bool isProcessing = false;

  final _labelService = LabelService();
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadLabel();
  }

  Future<void> _loadLabel() async {
    final user = _auth.currentUser;

    if (user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('labeledNotes')
          .doc(widget.noteId)
          .get();

      if (!mounted) return;

      setState(() {
        isLabeled = doc.exists;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _toggleLabel() async {
    if (isProcessing) return;

    setState(() {
      isProcessing = true;
    });

    try {
      await _labelService.toggleLabel(widget.noteId);

      if (!mounted) return;

      setState(() {
        isLabeled = !isLabeled;
      });
    } catch (e) {
      debugPrint("ラベル操作失敗: $e");
    } finally {
      if (!mounted) return;

      setState(() {
        isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(width: 24, height: 24);
    }

    if (isProcessing) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return IconButton(
      icon: Icon(
        isLabeled ? Icons.bookmark : Icons.bookmark_border,
        color: isLabeled ? Colors.orange : Colors.black,
      ),
      onPressed: _toggleLabel,
    );
  }
}