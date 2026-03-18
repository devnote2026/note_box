import 'dart:io';
import 'package:flutter/material.dart';

class PostScreen extends StatefulWidget {

  final File imageFile;

  const PostScreen({
    super.key,required,
    required this.imageFile
     });

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}